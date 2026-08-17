import AVFoundation
import Foundation
import UIKit
import UserNotifications
import FirebaseAnalytics

private let lastBlockHeightKey = "LastBlockHeightKey"
private let progressUpdateInterval: TimeInterval = 0.5
private let updateDebounceInterval: TimeInterval = 1.0

/// Sync is considered "done" for the foreground-sync-duration metric once
/// block-height-based progress crosses this fraction — not 1.0, since the
/// final progress tick and the syncState -> .success transition are two
/// separate events and the last tick before completion can land anywhere
/// below full completion.
private let kSyncDurationThreshold = 0.98

/// Sanity ceiling for the foreground-sync-duration metric, in seconds (24
/// hours). foregroundSyncDurationSeconds only accumulates time while the app
/// is active and syncState == .syncing, so this should rarely if ever bite —
/// it's a backstop against clock skew or a pathologically bad connection,
/// not the normal background-time case that motivated using accumulated
/// segments over a single wall-clock diff in the first place.
private let kMaxSyncDurationSeconds: TimeInterval = 24 * 60 * 60

class WalletCoordinator: Subscriber {
	var kvStore: BRReplicatedKVStore? {
		didSet {
			requestTxUpdate()
		}
	}

	private let walletManager: WalletManager
	private let store: Store
	private var progressTimer: Timer?
	private var updateTimer: Timer?
	private let defaults = UserDefaults.standard
	private var backgroundTaskId: UIBackgroundTaskIdentifier?
	private var reachability = ReachabilityMonitor()
	private var retryTimer: RetryTimer?

	/// Start time of the currently-open active-foreground-sync segment, if
	/// any. nil whenever we're not both syncing and in the foreground.
	private var activeSyncSegmentStart: Date?

	init(walletManager: WalletManager, store: Store) {
		self.walletManager = walletManager
		self.store = store
		addWalletObservers()
		addSubscriptions()
		updateBalance()
        updateTransactions()
		reachability.didChange = { [weak self] isReachable in
			self?.reachabilityDidChange(isReachable: isReachable)
		}
	}

	private var lastBlockHeight: UInt32 {
		set {
			defaults.set(newValue, forKey: lastBlockHeightKey)
		}
		get {
			return UInt32(defaults.integer(forKey: lastBlockHeightKey))
		}
	}

	@objc private func updateProgress() {
		DispatchQueue.walletQueue.async {
			guard let progress = self.walletManager.peerManager?.syncProgress(fromStartHeight: self.lastBlockHeight),
                    let timestamp = self.walletManager.peerManager?.lastBlockTimestamp else { return }
			DispatchQueue.main.async {
				self.store.perform(action: WalletChange.setProgress(progress: progress, timestamp: timestamp))
				self.logSyncDurationIfNeeded(progress: progress)
			}
		}
		updateBalance()

	}

	private func onSyncStart() {
		endBackgroundTask()
		startBackgroundTask()
		progressTimer = Timer.scheduledTimer(timeInterval: progressUpdateInterval, target: self, selector: #selector(WalletCoordinator.updateProgress), userInfo: nil, repeats: true)
		store.perform(action: WalletChange.setSyncingState(.syncing))
		startActivity()
		resumeSyncSegmentIfNeeded()
	}

	private func onSyncStop(notification: Notification) {
		pauseSyncSegment()
		if UIApplication.shared.applicationState != .active {
			DispatchQueue.walletQueue.async {
				self.walletManager.peerManager?.disconnect()
			}
		}
		endBackgroundTask()
		if notification.userInfo != nil {
			store.perform(action: WalletChange.setSyncingState(.connecting))
			endActivity()

			if retryTimer == nil, reachability.isReachable {
				retryTimer = RetryTimer()
				retryTimer?.callback = strongify(self) { myself in
					myself.store.trigger(name: .retrySync)
				}
				retryTimer?.start()
			}

			return
		}
		retryTimer?.stop()
		retryTimer = nil
		if let height = walletManager.peerManager?.lastBlockHeight {
			lastBlockHeight = height
		}
		progressTimer?.invalidate()
		progressTimer = nil
		store.perform(action: WalletChange.setSyncingState(.success))
		endActivity()
	}

	// MARK: - Foreground Sync Duration Metric

	/// Starts (or resumes) timing an active-foreground-sync segment. No-op
	/// unless a segment isn't already open, we're actually syncing, the app
	/// is in the foreground, and the metric hasn't already been sent for
	/// this wallet.
	private func resumeSyncSegmentIfNeeded() {
		guard activeSyncSegmentStart == nil,
		      !UserDefaults.hasLoggedInitialSyncDuration,
		      store.state.walletState.syncState == .syncing,
		      UIApplication.shared.applicationState == .active
		else { return }
		activeSyncSegmentStart = Date()
	}

	/// Closes the current active-foreground-sync segment (if any), folding
	/// its elapsed time into the persisted running total. Called whenever
	/// something ends the segment: sync stops/pauses (onSyncStop), the app
	/// leaves the foreground (willResignActive), or the completion threshold
	/// is reached (logSyncDurationIfNeeded, to fold in the final partial tick).
	private func pauseSyncSegment() {
		guard let start = activeSyncSegmentStart else { return }
		activeSyncSegmentStart = nil
		let elapsed = Date().timeIntervalSince(start)
		guard elapsed > 0 else { return }
		UserDefaults.foregroundSyncDurationSeconds += elapsed
	}

	/// Logs the one-time "foreground time to sync" metric once block-height
	/// progress first crosses kSyncDurationThreshold: the accumulated
	/// wall-clock seconds spent actively syncing while the app was in the
	/// foreground (UserDefaults.foregroundSyncDurationSeconds), deliberately
	/// excluding any time spent backgrounded or closed mid-sync so it
	/// reflects actual sync speed rather than how long the user took to
	/// reopen the app.
	///
	/// Guarded so it fires at most once ever per wallet, not once per app
	/// launch -- every launch re-syncs a few incremental blocks from the
	/// persisted last-synced height, which would otherwise cross the
	/// threshold almost immediately on every relaunch.
	private func logSyncDurationIfNeeded(progress: Double) {
		guard !UserDefaults.hasLoggedInitialSyncDuration,
		      progress >= kSyncDurationThreshold
		else { return }

		// Fold in the currently-open segment so the final tick that crosses
		// the threshold is counted, then mark this wallet as evaluated either
		// way -- don't keep re-checking on every subsequent progress tick.
		pauseSyncSegment()
		UserDefaults.hasLoggedInitialSyncDuration = true

		let syncDurationSeconds = Int(UserDefaults.foregroundSyncDurationSeconds)

		// Discard anything past the sanity ceiling rather than logging it --
		// this metric only accumulates active foreground time, so this should
		// rarely trigger; it's a backstop, not the normal case.
		guard syncDurationSeconds >= 0, TimeInterval(syncDurationSeconds) <= kMaxSyncDurationSeconds else { return }

		Analytics.logEvent("user_did_complete_sync",
		                    parameters: ["sync_duration_seconds": syncDurationSeconds])
	}

	private func endBackgroundTask() {
		if let taskId = backgroundTaskId {
			UIApplication.shared.endBackgroundTask(taskId)
			backgroundTaskId = nil
		}
	}

	private func startBackgroundTask() {
		backgroundTaskId = UIApplication.shared.beginBackgroundTask(expirationHandler: {
			DispatchQueue.walletQueue.async {
				self.walletManager.peerManager?.disconnect()
			}
		})
	}

	private func requestTxUpdate() {
		if updateTimer == nil {
			updateTimer = Timer.scheduledTimer(timeInterval: updateDebounceInterval, target: self, selector: #selector(updateTransactions), userInfo: nil, repeats: false)
		}
	}

	@objc private func updateTransactions() {
		updateTimer?.invalidate()
		updateTimer = nil

        Task(priority: .userInitiated) {

			do {
                let walletManager = self.walletManager
                guard let currentRate = self.store.state.currentRate,
                    let kvStore = self.kvStore,
                    let wallet = walletManager.wallet else {
                    debugPrint("Wallet not found!")
                    return
                }

				let transactions = try await self
                    .makeTransactionViewModels(transactions: wallet.transactions,
				        walletManager: walletManager,
				        kvStore: kvStore,
                        rate: currentRate)

				if !transactions.isEmpty {
                    await MainActor.run {
                        self.store.perform(action: WalletChange.setTransactions(transactions))
                    }
				}
			} catch let error {
                debugPrint("::: ERROR \(error)")

			}
		}
	}

	func makeTransactionViewModels(transactions: [BRTxRef?], walletManager: WalletManager, kvStore: BRReplicatedKVStore?, rate: Rate?) async throws -> [Transaction] {

        precondition(kvStore != nil, "KVStore must be valid")
        precondition(rate != nil, "rate must be valid")

		guard let kvStore = kvStore else {
			throw MakeTransactionError.replicatedKVStoreNotFound
		}

		guard let rate = rate else {
			throw MakeTransactionError.rateNotFound
		}

		return transactions.compactMap { $0 }.sorted {
			$0.pointee.timestamp > $1.pointee.timestamp
		}
		.compactMap {
			Transaction($0, walletManager: walletManager, kvStore: kvStore, rate: rate)
		}
	}

	private func addWalletObservers() {
		NotificationCenter.default.addObserver(forName: .walletBalanceChangedNotification, object: nil, queue: nil, using: { [weak self]
			_ in
			self?.updateBalance()
			self?.requestTxUpdate()
		})

		NotificationCenter.default.addObserver(forName: .walletTxStatusUpdateNotification, object: nil, queue: nil, using: { [weak self] _ in
			self?.requestTxUpdate()
		})

		NotificationCenter.default.addObserver(forName: .walletTxRejectedNotification, object: nil, queue: nil, using: { [weak self] note in
			guard let recommendRescan = note.userInfo?["recommendRescan"] as? Bool else { return }
			self?.requestTxUpdate()
			if recommendRescan {
				self?.store.perform(action: RecommendRescan.set(recommendRescan))
			}
		})

		NotificationCenter.default.addObserver(forName: .walletSyncStartedNotification, object: nil, queue: nil, using: { [weak self] _ in
			self?.onSyncStart()
            self?.updateTransactions()
		})

		NotificationCenter.default.addObserver(forName: .walletSyncStoppedNotification, object: nil, queue: nil, using: { [weak self] note in
			self?.onSyncStop(notification: note)
		})

		NotificationCenter.default.addObserver(forName: .languageChangedNotification, object: nil, queue: nil, using: { [weak self] _ in
			self?.updateTransactions()
		})

		// Foreground/background transitions bound the foreground-sync-duration
		// metric's segments independently of syncState: the peer manager can
		// keep syncing for a few seconds into the background (until the
		// background task's expiration handler disconnects it), and we don't
		// want that grace period counted as "foreground" time.
		NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: nil, using: { [weak self] _ in
			self?.resumeSyncSegmentIfNeeded()
		})

		NotificationCenter.default.addObserver(forName: UIApplication.willResignActiveNotification, object: nil, queue: nil, using: { [weak self] _ in
			self?.pauseSyncSegment()
		})
	}

	deinit {
		NotificationCenter.default.removeObserver(self)
	}

	private func updateBalance() {
		DispatchQueue.walletQueue.async {
			guard let newBalance = self.walletManager.wallet?.balance else { return }
			DispatchQueue.main.async {
				self.checkForReceived(newBalance: newBalance)
				self.store.perform(action: WalletChange.setBalance(newBalance))
			}
		}
	}

	private func checkForReceived(newBalance: UInt64) {
		if let oldBalance = store.state.walletState.balance {
			if newBalance > oldBalance {
				if store.state.walletState.syncState == .success {
					showReceived(amount: newBalance - oldBalance)
				}
			}
		}
	}

	private func showReceived(amount: UInt64) {
		if let rate = store.state.currentRate {
			let amount = Amount(amount: amount, rate: rate, maxDigits: store.state.maxDigits)
			let primary = store.state.isLTCValueShown ? amount.localCurrency : amount.bits
			let secondary = store.state.isLTCValueShown ? amount.bits : amount.localCurrency
			let message = String(format: "Received %@ from the network" , "\(primary) (\(secondary))")
			store.trigger(name: .lightWeightAlert(message))
			showLocalNotification(message: message)
			playPingSound()
		}
	}

	private func playPingSound() {
		if let url = Bundle.main.url(forResource: "coinflip", withExtension: "aiff") {
			var id: SystemSoundID = 0
			AudioServicesCreateSystemSoundID(url as CFURL, &id)
			AudioServicesAddSystemSoundCompletion(id, nil, nil, { soundId, _ in
				AudioServicesDisposeSystemSoundID(soundId)
			}, nil)
			AudioServicesPlaySystemSound(id)
		}
	}

	private func showLocalNotification(message: String) {
		guard UIApplication.shared.applicationState == .background || UIApplication.shared.applicationState == .inactive else { return }
		guard store.state.isPushNotificationsEnabled else { return }
		UIApplication.shared.applicationIconBadgeNumber = UIApplication.shared.applicationIconBadgeNumber + 1

        // Create and schedule the notification
        let content = UNMutableNotificationContent()
        content.body = message
        content.sound = UNNotificationSound(named: UNNotificationSoundName("coinflip.aiff"))

        let request = UNNotificationRequest(identifier: "localNotification", content: content, trigger: nil)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
	}

	private func reachabilityDidChange(isReachable: Bool) {
		if !isReachable {
			DispatchQueue.walletQueue.async {
				self.walletManager.peerManager?.disconnect()
				DispatchQueue.main.async {
					self.store.perform(action: WalletChange.setSyncingState(.connecting))
				}
			}
		}
	}

	private func addSubscriptions() {
		store.subscribe(self, triggerName: .retrySync, callback: { [weak self] _ in
			DispatchQueue.walletQueue.async {
				self?.walletManager.peerManager?.connect()
			}
		})

		store.subscribe(self, triggerName: .rescan, callback: { [weak self] _ in
			self?.store.perform(action: RecommendRescan.set(false))
			// In case rescan is called while a sync is in progess
			// we need to make sure it's false before a rescan starts
			// self.store.perform(action: WalletChange.setIsSyncing(false))
			DispatchQueue.walletQueue.async {
				self?.walletManager.peerManager?.rescan()
			}
		})

		store.subscribe(self, triggerName: .rescan, callback: { [weak self] _ in
			self?.store.perform(action: WalletChange.setIsRescanning(true))
		})
	}

	private func startActivity() {
		UIApplication.shared.isIdleTimerDisabled = true
	}

	private func endActivity() {
		UIApplication.shared.isIdleTimerDisabled = false
	}
}
