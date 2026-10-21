import FirebaseAnalytics
import StoreKit
import SwiftUI
import UIKit
#if !targetEnvironment(simulator)
import BWIOSGdx
#endif

/// Owns the wallet, store and root view controllers. The window is handed in by SceneDelegate.
class ApplicationController: Subscriber {
    var window: UIWindow?
    fileprivate let store = Store()
    private var modalPresenter: ModalPresenter?
    fileprivate var walletManager: WalletManager?
    private var walletCoordinator: WalletCoordinator?
    private var exchangeUpdater: ExchangeUpdater?
    private var transitionDelegate: ModalTransitionDelegate
    private var kvStoreCoordinator: KVStoreCoordinator?
    private var mainViewController: MainViewController?
    private var urlController: URLController?
    private var defaultsUpdater: UserDefaultsUpdater?
    private var reachability = ReachabilityMonitor()
    private let noAuthApiClient = BWAPIClient(authenticator: NoAuthAuthenticator())
    private var launchURL: URL?
    private var hasPerformedWalletDependentInitialization = false
    private var didInitWallet = false
    var gameController: GameContainerViewController?
    /// The window libGDX creates for the game; see adoptGameWindow(_:)
    private weak var gameWindow: UIWindow?
    // Injectable so tests can substitute a spy instead of hitting the real StoreKit prompt.
    var reviewRequester: AppStoreReviewRequesting.Type = SKStoreReviewController.self
    #if !targetEnvironment(simulator)
        var bwGameSDK: BwGameSdk?
    #endif

    init() {

        // Game: initialize once, paused + hidden, host window stays key
        #if !targetEnvironment(simulator)
            bwGameSDK = BwGameSdkInstance()
        #else
            debugPrint(":::: game disabled on simulator (device-only natives)")
        #endif

        transitionDelegate = ModalTransitionDelegate(type: .transactionDetail,
                                                     store: store)
        DispatchQueue.walletQueue.async {
            guardProtected(queue: DispatchQueue.walletQueue) {
                self.initWallet()
            }
        }
    }

    func initWallet() {

        guard let tempWalletManager = try? WalletManager(store: store,
                                                         dbPath: nil) else {
            assertionFailure("WalletManager no initialized")
            return
        }

        walletManager = tempWalletManager

        _ = walletManager?.wallet

        /// Update fiat rate
        let preferredCurrencyCode = UserDefaults.userPreferredCurrencyCode

        NetworkHelper.init().exchangeRates({ rates, _ in
            guard let currentRate = rates.first(where: { $0.code ==
                preferredCurrencyCode }) else {
                return
            }
            self.store
                .perform(action: ExchangeRates
                    .setRates(currentRate: currentRate, rates: rates))
        })

        DispatchQueue.main.async {
            self.didInitWallet = true
            if !self.hasPerformedWalletDependentInitialization {
                self.didInitWalletManager()
            }
        }
    }

	func launch(window: UIWindow?) {
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
		store.subscribe(self, triggerName: .reinitWalletManager(nil), callback: {
			guard let trigger = $0 else { return }
			if case let .reinitWalletManager(callback) = trigger {
				if let callback = callback {
					self.store.removeAllSubscriptions()
					self.store.perform(action: Reset())
					self.setup()
					DispatchQueue.walletQueue.async {
						do {
							self.walletManager = try WalletManager(store:
                                                                    self.store,
                                                                   dbPath: nil)
							_ = self.walletManager?.wallet
						} catch {
							assertionFailure("::: Error creating wallet: \(error)")
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

    func shouldShowGameSDK(address: String) {
        guard let window = self.window else {
            assertionFailure("shouldHideGameSDK: window is nil")
            return
        }
        let currentLocaleLanguage = Bundle.main.preferredLocalizations.first ?? "en"

        guard let walletManager = walletManager,
        let emojiResult = walletManager.emojiStringResult() else { return }

        let emojiArray = emojiResult.map { String($0) }

        let launchParameters: [String: Any] = [
            "language": currentLocaleLanguage,
            "address": address,
            "timestamp": Int(Date().timeIntervalSince1970),
            "emojis": emojiArray
        ]

        let jsonObject: [String: Any] = [
            "launchParameters": launchParameters
        ]

        do {
            let jsonData = try JSONSerialization
                .data(withJSONObject: jsonObject, options: [])
            if let jsonString = String(data: jsonData, encoding: .utf8) {


                #if !targetEnvironment(simulator)
                DispatchQueue.main.async {
                    self.gameController = GameContainerViewController()

                    // The game window draws black until libGDX finishes create() and renders a frame,
                    // so keep it transparent over the main UI and fade it in once it has content.
                    self.gameWindow?.alpha = 0.0
                    self.bwGameSDK?
                        .startGame(withLaunchParams: window,
                                   launchParams: jsonString)
                    self.gameController?.isGameActive = true

                    UIView.animate(withDuration: 0.4, delay: 0.8, animations: {
                        self.gameWindow?.alpha = 1.0
                    }, completion: { _ in
                        // Swap the root while the game window covers it
                        window.rootViewController = self.gameController
                    })
                }
                #endif
            }
        } catch {
            print("Error converting to JSON: \(error)")
        }
    }


    func shouldHideGameSDK(dictionary: [AnyHashable: Any]) {

        //Either exit game or post to social after decoding dictionary
        var userIsPostingToSocial = false
        guard gameController != nil else {
            assertionFailure("shouldHideGameSDK: called with no gameController")
            return
        }

        guard let payload = dictionary["jsonString"] as? String,
              let data = payload.data(using: .utf8) else {
            return
        }

        do {
            let decodedPayload = try JSONDecoder().decode(GameExitPayload.self, from: data)
            let decodedObject = decodedPayload.exitData   // was: the whole decoded object
            
            userIsPostingToSocial = decodedObject.socialNetwork == "twitter"
            || decodedObject.socialNetwork == "instagram"
            
            // Forward every game event recorded during this session to Firebase.
            for event in decodedPayload.events {
                let params = event.params.compactMapValues { $0.firebaseValue }
                Analytics.logEvent(event.name, parameters: params.isEmpty ? nil : params)
            }
            DispatchQueue.main.async {

                guard let window = self.window else {
                    return
                }
                // The game window sits above the host window; hide it so the main UI is visible again
                self.gameWindow?.isHidden = true

                let outgoingView = window.rootViewController?.view
                let incomingVC = self.mainViewController

                outgoingView?.alpha = 1.0
                UIView.animate(withDuration: 0.3, animations: {
                    outgoingView?.alpha = 0.0
                }, completion: { [weak self] _ in
                    window.rootViewController = incomingVC
                    outgoingView?.alpha = 1.0
                    self?.gameController = nil
                })


                //Reset the toggle
                self.mainViewController?.newMainViewModel?.shouldShowGameSDK = false

                //POST GAME DATA TRANSITION
                if userIsPostingToSocial {
                    self.mainViewController?.newMainViewModel?.gameExitDictionary = dictionary
                    self.mainViewController?.newMainViewModel?.gameExitUpdated = true
                }

                //Game finished, prompt for a review after the transition settles
                self.requestReviewAfterGameFinished()

            }
        } catch {
            print("Failed to decode payload: \(error)")
        }
    }

    /// libGDX creates its game UIWindow without a scene and hands it to `UIApplicationDelegate.window`.
    /// Under the UIScene lifecycle a scene-less window is never shown, so attach it to the host scene.
    /// The host window stays the app's window.
    func adoptGameWindow(_ newWindow: UIWindow?) {
        guard let newWindow, newWindow !== window else { return }
        if newWindow.windowScene == nil {
            newWindow.windowScene = window?.windowScene
        }
        // Attaching to the scene shows it at once, black until the game renders; shouldShowGameSDK fades it in
        newWindow.alpha = 0.0
        gameWindow = newWindow
    }

    // Extracted so tests can trigger the post-game review prompt directly,
    // without driving the full window-transition/animation pipeline above.
    func requestReviewAfterGameFinished() {
        let reviewRequester = self.reviewRequester
        delay(3.0) {
            Analytics.logEvent("did_play_game", parameters: nil)
            reviewRequester.requestReviewInCurrentScene()
        }
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
			UserDefaults.standard.set(Date().timeIntervalSince1970,
                                      forKey: timeSinceLastExitKey)
		}
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
            assertionFailure("WalletManager must be init before ApplicationController")
            return
        }
		guard let window = window else { return }
        NotificationCenter.default.post(name: .walletDidIntializeNotification,
                                        object: nil, userInfo: nil)

		hasPerformedWalletDependentInitialization = true
		walletCoordinator = WalletCoordinator(walletManager: walletManager, store: store)
		modalPresenter = ModalPresenter(store: store,
                                        walletManager: walletManager,
                                        window: window, apiClient: noAuthApiClient)
		exchangeUpdater = ExchangeUpdater(store: store, walletManager: walletManager)
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
                mainViewController?.startOnboarding()
			} else {
				modalPresenter?.walletManager = walletManager
				DispatchQueue.walletQueue.async {
					walletManager.peerManager?.connect()
                    self.startDataFetchers()
				}
			}

			// For when watch app launches app in background
		} else {
			DispatchQueue.walletQueue.async {
				walletManager.peerManager?.connect()
			}
		}
	}

	private func setupDefaults() {
		if UserDefaults.standard.object(forKey: shouldRequireLoginTimeoutKey) == nil {
			UserDefaults.standard.set(60.0 * 3.0, forKey: shouldRequireLoginTimeoutKey) // Default 3 min timeout
		}

        if UserDefaults.standard.object(forKey: userDidPreferDarkModeKey) == nil {
            UserDefaults.standard.set(false, forKey: userDidPreferDarkModeKey)
        }

        if UserDefaults.standard.object(forKey: userCurrentLocaleMPApprovedKey) == nil {
            UserDefaults.standard.set(false, forKey: userCurrentLocaleMPApprovedKey)
        }
	}

	func countLaunches() {
		if var launchNumber = UserDefaults.standard.object(forKey: numberOfBrainwalletLaunches) as? Int {
			launchNumber += 1
			UserDefaults.standard.set(NSNumber(value: launchNumber), forKey: numberOfBrainwalletLaunches)
            if launchNumber == 3 {
                reviewRequester.requestReviewInCurrentScene()
                debugPrint("did_request_rating")
            }
		} else {
			UserDefaults.standard.set(NSNumber(value: 1), forKey: numberOfBrainwalletLaunches)
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
	}

	private func addWalletCreationListener() {
		store.subscribe(self, triggerName: .didCreateOrRecoverWallet, callback: { [weak self] _ in
			self?.modalPresenter?.walletManager = self?.walletManager
			self?.startDataFetchers()
			self?.mainViewController?.didUnlock()
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
}
