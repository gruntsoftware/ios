import BackgroundTasks
import StoreKit
import SwiftUI
import UIKit

class ApplicationController: Subscriber, Trackable {
    // Ideally the window would be private, but is unfortunately required
    // by the UIApplicationDelegate Protocol

    var window: UIWindow?
    fileprivate let store = Store()
    private var startFlowController: StartFlowPresenter?
    private var modalPresenter: ModalPresenter?
    fileprivate var walletManager: WalletManager?
    private var walletCoordinator: WalletCoordinator?
    private var exchangeUpdater: ExchangeUpdater?
    private var transitionDelegate: ModalTransitionDelegate
    private var kvStoreCoordinator: KVStoreCoordinator?
    private var mainViewController: MainViewController?
    fileprivate var application: UIApplication?
    private var urlController: URLController?
    private var defaultsUpdater: UserDefaultsUpdater?
    private var reachability = ReachabilityMonitor()
    private let noAuthApiClient = BWAPIClient(authenticator: NoAuthAuthenticator())
    var fetchCompletionHandler: ((UIBackgroundFetchResult) -> Void)?
    private var launchURL: URL?
    private var hasPerformedWalletDependentInitialization = false
    private var didInitWallet = false

    init() {
        transitionDelegate = ModalTransitionDelegate(type: .transactionDetail, store: store)
        DispatchQueue.walletQueue.async {
            guardProtected(queue: DispatchQueue.walletQueue) {
                self.initWallet()
            }
        }
    }

    func initWallet() {

        guard let tempWalletManager = try? WalletManager(store: store, dbPath: nil) else {
            assertionFailure("WalletManager no initialized")
            return
        }

        walletManager = tempWalletManager

        _ = walletManager?.wallet // attempt to initialize wallet

        /// Update fiat rate
        let preferredCurrencyCode = UserDefaults.userPreferredCurrencyCode

        NetworkHelper.init().exchangeRates({ rates, _ in
            guard let currentRate = rates.first(where: { $0.code ==
                preferredCurrencyCode }) else {
                return
            }
            self.store.perform(action: ExchangeRates.setRates(currentRate: currentRate, rates: rates))
        })

        DispatchQueue.main.async {
            self.didInitWallet = true
            if !self.hasPerformedWalletDependentInitialization {
                self.didInitWalletManager()
            }
        }
    }

	func launch(application: UIApplication, window: UIWindow?) {
		self.application = application
		self.window = window
		setup()
		reachability.didChange = { isReachable in
			if !isReachable {
				self.reachability.didChange = { isReachable in
					if isReachable {
						self.retryAfterIsReachable()
					}
				}
			}
		}

		if !hasPerformedWalletDependentInitialization, didInitWallet {
			didInitWalletManager()
		}
	}

	private func setup() {
		setupDefaults()
		countLaunches()
        setupRootViewController()
		window?.makeKeyAndVisible()
		offMainInitialization()
		store.subscribe(self, name: .reinitWalletManager(nil), callback: {
			guard let trigger = $0 else { return }
			if case let .reinitWalletManager(callback) = trigger {
				if let callback = callback {
					self.store.removeAllSubscriptions()
					self.store.perform(action: Reset())
					self.setup()
					DispatchQueue.walletQueue.async {
						do {
							self.walletManager = try WalletManager(store: self.store, dbPath: nil)
							_ = self.walletManager?.wallet // attempt to initialize wallet
						} catch {
							assertionFailure("::: Error creating new wallet: \(error)")
						}
						DispatchQueue.main.async {
							self.didInitWalletManager()
							callback()
						}
					}
				}
			}
		})

		TransactionManager.sharedInstance.fetchTransactionData(store: store)
	}

	func willEnterForeground() {
		guard let walletManager = walletManager else { return }
		guard !walletManager.noWallet else { return }
		if shouldRequireLogin() {
			store.perform(action: RequireLogin())
		}
        resetLaunchObjectsAndRates()
	}

	func retryAfterIsReachable() {
		guard let walletManager = walletManager else { return }
		guard !walletManager.noWallet else { return }
        resetLaunchObjectsAndRates()
	}

    private func resetLaunchObjectsAndRates() {
        guard let walletManager = walletManager else { return }
        guard !walletManager.noWallet else { return }
        DispatchQueue.walletQueue.async {
            walletManager.peerManager?.connect()
        }
        exchangeUpdater?.refresh(completion: {

        })
        if modalPresenter?.walletManager == nil {
            modalPresenter?.walletManager = walletManager
        }
    }

	func didEnterBackground() {
		if store.state.walletState.syncState == .success {
			DispatchQueue.walletQueue.async {
				self.walletManager?.peerManager?.disconnect()
			}
		}
		// Save the backgrounding time if the user is logged in
		if !store.state.isLoginRequired {
			UserDefaults.standard.set(Date().timeIntervalSince1970, forKey: timeSinceLastExitKey)
		}
	}

	func performFetch(_ completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
		fetchCompletionHandler = completionHandler
	}

	func open(url: URL) -> Bool {
		if let urlController = urlController {
			return urlController.handleUrl(url)
		} else {
			launchURL = url
			return false
		}
	}

	private func didInitWalletManager() {
        guard let walletManager = walletManager else {
            assertionFailure("WalletManager must be initialized before ApplicationController")
            return
        }
		guard let rootViewController = window?.rootViewController else { return }
		guard let window = window else { return }

		hasPerformedWalletDependentInitialization = true
		walletCoordinator = WalletCoordinator(walletManager: walletManager, store: store)
		modalPresenter = ModalPresenter(store: store, walletManager: walletManager, window: window, apiClient: noAuthApiClient)
		exchangeUpdater = ExchangeUpdater(store: store, walletManager: walletManager)

		guard let exchangeUpdaterWithFee = exchangeUpdater else { return }
		startFlowController = StartFlowPresenter(store: store, walletManager: walletManager, rootViewController: rootViewController)
		mainViewController?.walletManager = walletManager
		defaultsUpdater = UserDefaultsUpdater(walletManager: walletManager)
		urlController = URLController(store: store, walletManager: walletManager)
		if let url = launchURL {
			_ = urlController?.handleUrl(url)
			launchURL = nil
		}

		if UIApplication.shared.applicationState != .background {
			if walletManager.noWallet {
				addWalletCreationListener()
				store.perform(action: ShowStartFlow())
			} else {
				modalPresenter?.walletManager = walletManager
				DispatchQueue.walletQueue.async {
					walletManager.peerManager?.connect()
                    self.startDataFetchers()
				}
			}

			// For when watch app launches app in background
		} else {
			DispatchQueue.walletQueue.async { [weak self] in
				walletManager.peerManager?.connect()
				if self?.fetchCompletionHandler != nil {
					self?.performBackgroundFetch()
				}
			}
		}
	}

	func shouldRequireLogin() -> Bool {
		let then = UserDefaults.standard.double(forKey: timeSinceLastExitKey)
		let timeout = UserDefaults.standard.double(forKey: shouldRequireLoginTimeoutKey)
		let nowTime = Date().timeIntervalSince1970
		return nowTime - then > timeout
	}

	private func setupRootViewController() {
		mainViewController = MainViewController(store: store)
		window?.rootViewController = mainViewController
	}

	private func startDataFetchers() {
		initKVStoreCoordinator()
		defaultsUpdater?.refresh()
		walletManager?.apiClient?.events?.up()
	}

	private func addWalletCreationListener() {
		store.subscribe(self, name: .didCreateOrRecoverWallet, callback: { [weak self] _ in
			self?.modalPresenter?.walletManager = self?.walletManager
			self?.startDataFetchers()
			self?.mainViewController?.didUnlockLogin()
		})
	}

	private func initKVStoreCoordinator() {
		guard let kvStore = walletManager?.apiClient?.kv
		else {
			return
		}

		guard kvStoreCoordinator == nil
		else {
			return
		}

		kvStore.syncAllKeys { _ in
			self.walletCoordinator?.kvStore = kvStore
			self.kvStoreCoordinator = KVStoreCoordinator(store: self.store, kvStore: kvStore)
			self.kvStoreCoordinator?.retreiveStoredWalletInfo()
			self.kvStoreCoordinator?.listenForWalletChanges()
		}
	}

	private func offMainInitialization() {
		Task(priority: .background) {
			_ = Rate.symbolMap // Initialize currency symbol map
		}
	}

	func performBackgroundFetch() {
		saveEvent("appController.performBackgroundFetch")
		let group = DispatchGroup()
		if let peerManager = walletManager?.peerManager, peerManager.syncProgress(fromStartHeight: peerManager.lastBlockHeight) < 1.0 {
			group.enter()
			store.lazySubscribe(self, selector: { $0.walletState.syncState != $1.walletState.syncState }, callback: { state in
				if self.fetchCompletionHandler != nil {
					if state.walletState.syncState == .success {
						DispatchQueue.walletConcurrentQueue.async {
							peerManager.disconnect()
							self.saveEvent("appController.peerDisconnect")
							DispatchQueue.main.async {
								group.leave()
							}
						}
					}
				}
			})
		}

		group.enter()
		Async.parallel(callbacks: [
			{ self.exchangeUpdater?.refresh(completion: $0) }
		], completion: {
			group.leave()
		})

		DispatchQueue.global(qos: .utility).async {
			if group.wait(timeout: .now() + 25.0) == .timedOut {
				self.saveEvent("appController.backgroundFetchFailed")
				self.fetchCompletionHandler?(.failed)
			} else {
				self.saveEvent("appController.backgroundFetchNewData")
				self.fetchCompletionHandler?(.newData)
			}
			self.fetchCompletionHandler = nil
		}
	}
}
