import LocalAuthentication
import SwiftUI
import UIKit
import FirebaseAnalytics

let kNormalTransactionCellHeight: CGFloat = 65.0
let kProgressHeaderHeight: CGFloat = 75.0
let kDormantHeaderHeight: CGFloat = 1.0
let kPromptCellHeight: CGFloat = 120.0
let kQRImageSide: CGFloat = 110.0
let kFiveYears: Double = 157_680_000.0
let kTodaysEpochTime: TimeInterval = Date().timeIntervalSince1970

class TransactionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, Subscriber, Trackable {
	@IBOutlet var tableView: UITableView!

	var store: Store?
	var walletManager: WalletManager?
    var shouldBeSyncing: Bool = false
    var newSyncingHeaderView: NewSyncHostingController?
    var syncStartTime = Date()

	private var transactions: [Transaction] = []
	private var allTransactions: [Transaction] = [] {
		didSet {
			transactions = allTransactions
		}
	}

	private var rate: Rate? {
		didSet { reload() }
	}

	private var currentPromptType: PromptType? {
		didSet {
			if currentPromptType != nil, oldValue == nil {
				DispatchQueue.main.async { [weak self] in
					guard let self = self else { return }
					self.tableView.beginUpdates()
					self.tableView.reloadSections(IndexSet(integer: 0), with: .automatic)
					self.tableView.endUpdates()
				}
			}
		}
	}

	var isLtcSwapped: Bool? {
		didSet { reload() }
	}

	override func viewDidLoad() {
		setup()
		addSubscriptions()
	}

	private func setup() {
		guard let _ = walletManager
		else {
			debugPrint("::: ERROR: Wallet manager Not initialized")
			return
		}

		guard let reduxState = store?.state
		else {
            debugPrint("::: ERROR: reduxState Not initialized")
			return
		}

		tableView.register(HostingCell<TransactionCellView>.self, forCellReuseIdentifier: "HostingCell<TransactionCellView>")
        tableView.register(PromptHostingCell<PromptCellView>.self, forCellReuseIdentifier: "PromptHostingCell<PromptCellView>")

		transactions = TransactionManager.sharedInstance.transactions
		rate = TransactionManager.sharedInstance.rate
		tableView.backgroundColor = BrainwalletUIColor.surface
		initSyncingHeaderView(reduxState: reduxState, completion: {})
		attemptShowPrompt()

        NotificationCenter.default.addObserver(self, selector: #selector(userTappedPromptClose), name: .userTapsClosePromptNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(userTappedPromptContinue), name: .userTapsContinuePromptNotification, object: nil)
	}

	/// Calls the Syncing HeaderView
	/// - Parameters:
	///   - reduxState: Current ReduxState
	///   - completion: Signals the initialzation of the view
	private func initSyncingHeaderView(reduxState: ReduxState, completion: @escaping () -> Void) {

        guard let walletManager = walletManager,
        let store = store else {
            NSLog("::: ERROR: WalletManager or Store not initialized")
            return
        }

        newSyncingHeaderView = NewSyncHostingController(store: store, walletManager: walletManager)
        newSyncingHeaderView?.viewModel.isRescanning = reduxState.walletState.isRescanning
        newSyncingHeaderView?.viewModel.progress = 0.02
        newSyncingHeaderView?.viewModel.headerMessage = reduxState.walletState.syncState
        newSyncingHeaderView?.viewModel.dateTimestamp = reduxState.walletState.lastBlockTimestamp
        newSyncingHeaderView?.viewModel.blockHeightString = reduxState.walletState.transactions.first?.blockHeight ?? ""
		completion()
	}

    @objc
    private func userTappedPromptClose() {
        /// do close
        self.currentPromptType = nil
        self.reload()
    }

    @objc
    private func userTappedPromptContinue() {
        /// do continue
         if let store = self.store,
            let trigger = self.currentPromptType?.trigger {
                store.trigger(name: trigger)
            }

        self.currentPromptType = nil
        self.reload()
    }

	private func attemptShowPrompt() {
		guard let walletManager = walletManager,
        let store = store else {
			NSLog("::: ERROR: WalletManager or Store not initialized")
			return
		}

		let types = PromptType.defaultOrder
		if let type = types.first(where: { $0.shouldPrompt(walletManager: walletManager, state: store.state) }) {
			saveEvent("prompt.\(type.name).displayed")
			currentPromptType = type
			if type == .biometrics {
				UserDefaults.hasPromptedBiometrics = true
			}
			if type == .shareData {
				UserDefaults.hasPromptedShareData = true
			}
		} else {
			currentPromptType = nil
		}
	}

	/// Update displayed transactions. Used mainly when the database needs an update
	/// - Parameter txHash: String reprsentation of the TX
	private func updateTransactions(txHash: String) {
		for (i, tx) in transactions.enumerated() {

			if tx.hash == txHash {
				DispatchQueue.main.async {
					self.tableView.beginUpdates()
					self.tableView.reloadRows(at: [IndexPath(row: i, section: 1)], with: .automatic)
					self.tableView.endUpdates()
				}
			}
		}
	}

	/// Empty Message View as a placeholder
	/// - Returns: a UILabel
    private func emptyMessageView() -> UILabel {
		let rect = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: tableView.bounds.size.width, height: tableView.bounds.size.height))
		let messageLabel = UILabel(frame: rect)
        var messageString = "www.brainwallet.co"
        if let walletManager = walletManager {
            if walletManager.wallet?.balance != UInt64(0) {
                messageString =  String(localized: "Fetching your transaction history...")
            }
        }

        messageLabel.text = messageString
		messageLabel.textColor = BrainwalletUIColor.content
		messageLabel.numberOfLines = 0
		messageLabel.textAlignment = .center
		messageLabel.font = UIFont.barlowMedium(size: 20)
		messageLabel.sizeToFit()
		tableView.backgroundView = messageLabel
		tableView.separatorStyle = .none
		return messageLabel
	}

	/// Dyanmic Update Progress View: Advances the progress bar
	/// - Parameters:
	///   - syncProgress: The state of the initial Sync Progress
	///   - lastBlockTimestamp: Corresponding timestamp
	/// - Returns: CGFloat value
	private func updateProgressView(syncProgress: CGFloat, lastBlockTimestamp: Double) -> CGFloat {
		/// DEV:  HACK if the previous value is the same add a ration
		/// The problem is the progress needs to go to o to 1 .
		var progressValue: CGFloat = 0.0
		let num = lastBlockTimestamp - kFiveYears
		let den = kTodaysEpochTime - kFiveYears
        if  syncProgress < 0.02 {
			progressValue = abs(CGFloat(num) / CGFloat(den))
            syncStartTime = Date()
		} else {
			progressValue = syncProgress
		}

		return progressValue
	}

	// MARK: - Table view data / delegate source

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		switch indexPath.section {
		case 0:
			if currentPromptType != nil {
				return configurePromptCell(promptType: currentPromptType, indexPath: indexPath)
			}
			return EmptyTableViewCell()

		default:
			let transaction = transactions[indexPath.row]
            debugPrint("::: TransactionViewController tableView transaction blockHeight: \(transaction.blockHeight)")

			guard let cell = tableView.dequeueReusableCell(withIdentifier: "HostingCell<TransactionCellView>", for: indexPath) as? HostingCell<TransactionCellView>
			else {
				debugPrint("::: ERROR No cell found")
				return UITableViewCell()
			}

			if let rate = rate,
			   let store = store,
			   let isLtcSwapped = isLtcSwapped {
				let viewModel = TransactionCellViewModel(transaction: transaction, isLtcSwapped: isLtcSwapped, rate: rate, maxDigits: store.state.maxDigits, isSyncing: store.state.walletState.syncState != .success)
				cell.set(rootView: TransactionCellView(viewModel: viewModel), parentController: self)
				cell.selectionStyle = .default
			} else {
                debugPrint("::: ERROR Rate, Store, isLtcSwapped not set")
            }

			return cell
		}
	}

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if indexPath.section == 1 {
			let transaction = transactions[indexPath.row]

			if let rate = rate,
			   let store = store,
			   let isLtcSwapped = isLtcSwapped {
				let viewModel = TransactionCellViewModel(transaction: transaction, isLtcSwapped: isLtcSwapped, rate: rate, maxDigits: store.state.maxDigits, isSyncing: store.state.walletState.syncState != .success)

				let hostingController = UIHostingController(rootView: TransactionModalView(viewModel: viewModel))

				hostingController.modalPresentationStyle = .formSheet

				present(hostingController, animated: true) {
                    if indexPath.row < self.transactions.count {
						tableView.cellForRow(at: indexPath)?.isSelected = false
					}
				}
			}
		}
	}

	func tableView(_: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		if indexPath.section == 0 {
			return currentPromptType != nil ? kPromptCellHeight : kDormantHeaderHeight
		} else {
			return kNormalTransactionCellHeight
		}
	}

	func tableView(_: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		if shouldBeSyncing, section == 0 {
            return newSyncingHeaderView?.view
		}
		return nil
	}

	func tableView(_: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        var sectionHeight = 0.0
		switch section {
		case 0:
			sectionHeight = CGFloat(shouldBeSyncing ? kProgressHeaderHeight : kDormantHeaderHeight)
			return sectionHeight
		default: return 0.0
		}
	}

	func numberOfSections(in _: UITableView) -> Int {
		return 2
	}

	func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
		if section == 0 {
			return 1
		} else {
			if !transactions.isEmpty {
				tableView.backgroundView = nil
				return transactions.count
			} else {
				tableView.backgroundView = emptyMessageView()
				tableView.separatorStyle = .none

				return 0
			}
		}
	}

	// MARK: - UITableView Legacy Prompt

	private func configurePromptCell(promptType: PromptType?, indexPath: IndexPath) -> UITableViewCell {

        guard let promptCell = tableView.dequeueReusableCell(withIdentifier: "PromptHostingCell<PromptCellView>",
                                                             for: indexPath) as? PromptHostingCell<PromptCellView>
		else {
			NSLog("ERROR No cell found")
			return UITableViewCell()
		}

        guard (promptType != nil)  else {
            return UITableViewCell()
        }

		return promptCell
	}

	private func reload() {
		DispatchQueue.main.async {
			self.tableView.reloadData()
		}
	}

    // MARK: - Sync Measurement

    private func measureSyncTimes(startSync: Date, endSync: Date) {
        let duration = endSync.timeIntervalSince(startSync)
        let uuid = UUID().uuidString
        Analytics.logEvent("user_did_complete_sync",
            parameters: [
            "start_timestamp": startSync,
            "end_timestamp": endSync,
            "duration_seconds": duration,
            "uuid": uuid
        ])
    }
    // MARK: - Subscription Methods

	private func addSubscriptions() {
		guard let store = store
		else {
			NSLog("::: ERROR: Store not initialized")
			return
		}

		// MARK: - Wallet State: Transactions

		store.subscribe(self, selector: { $0.walletState.transactions != $1.walletState.transactions },
		                callback: { state in
		                	self.allTransactions = state.walletState.transactions
		                	self.reload()
		                })

		// MARK: - Wallet State: isLTCSwapped

		store.subscribe(self, selector: { $0.isLtcSwapped != $1.isLtcSwapped },
		                callback: { self.isLtcSwapped = $0.isLtcSwapped })

		// MARK: - Wallet State:  CurrentRate

		store.subscribe(self, selector: { $0.currentRate != $1.currentRate },
		                callback: { self.rate = $0.currentRate })

		// MARK: - Wallet State:  Max Digits

		store.subscribe(self, selector: { $0.maxDigits != $1.maxDigits }, callback: { [weak self] _ in
			self?.reload()
		})

		// MARK: - Wallet State:  Sync Progress

		store.subscribe(self, selector: { $0.walletState.lastBlockTimestamp != $1.walletState.lastBlockTimestamp },
		                callback: { reduxState in

		                	guard let syncView = self.newSyncingHeaderView else { return }

            syncView.viewModel.isRescanning = reduxState.walletState.isRescanning
		                	if syncView.viewModel.isRescanning || (reduxState.walletState.syncState == .syncing) {
                                syncView.viewModel.progress = CGFloat(self.updateProgressView(syncProgress:
		                			CGFloat(reduxState.walletState.syncProgress),lastBlockTimestamp: Double(reduxState.walletState.lastBlockTimestamp)))
                                syncView.viewModel.headerMessage = reduxState.walletState.syncState
                                syncView.viewModel.dateTimestamp = reduxState.walletState.lastBlockTimestamp
                                syncView.viewModel.blockHeightString = reduxState.walletState.transactions.first?.blockHeight ?? ""

		                		self.shouldBeSyncing = true

		                		if reduxState.walletState.syncProgress == 0.999 {
		                			self.shouldBeSyncing = false
		                			self.newSyncingHeaderView = nil

                                    self.measureSyncTimes(startSync: self.syncStartTime, endSync: Date())
		                		}
		                	}

		                	self.reload()
		                })

		// MARK: - Wallet State:  Show Status Bar

		store.subscribe(self, name: .showStatusBar) { _ in
			self.reload()
		}

		// MARK: - Wallet State:  Sync State

		store.subscribe(self, selector: { $0.walletState.syncState != $1.walletState.syncState },
		                callback: { reduxState in

		                	guard let _ = self.walletManager?.peerManager
		                	else {
		                		return
		                	}

		                	if reduxState.walletState.syncState == .syncing {
		                		self.shouldBeSyncing = true
		                	}

		                	if reduxState.walletState.syncState == .success {
		                		self.shouldBeSyncing = false
		                	}
		                	self.reload()
		                })

		// MARK: - Subscription:  Recommend Rescan

		store.subscribe(self, selector: { $0.recommendRescan != $1.recommendRescan },
                        callback: { [weak self] _ in
			self?.attemptShowPrompt()
		})

		// MARK: - Subscription:  Did Upgrade PIN

		store.subscribe(self, name: .didUpgradePin, callback: {  [weak self] _ in
			if self?.currentPromptType == .upgradePin {
				self?.currentPromptType = nil
			}
		})

		// MARK: - Subscription:  Did Enable Share Data

		store.subscribe(self, name: .didEnableShareData, callback: { [weak self] _ in
			if self?.currentPromptType == .shareData {
				self?.currentPromptType = nil
			}
		})

		// MARK: - Subscription:  Did Write Paper Key

		store.subscribe(self, name: .didWritePaperKey, callback: { [weak self] _ in
			if self?.currentPromptType == .paperKey {
				self?.currentPromptType = nil
			}
		})

		// MARK: - Subscription:  Memo Updated

		store.subscribe(self, name: .txMemoUpdated(""), callback: { [weak self] in

			guard let trigger = $0 else { return }

			if case let .txMemoUpdated(txHash) = trigger {
				self?.updateTransactions(txHash: txHash)
			}
		})

		reload()
	}
}
