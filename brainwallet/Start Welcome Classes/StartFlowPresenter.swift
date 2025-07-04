import UIKit

class StartFlowPresenter: Subscriber {
	// MARK: - Public

	// MARK: - Private

	private let store: Store
	private let rootViewController: UIViewController
	private var navigationController: ModalNavigationController?
	private let navigationControllerDelegate: StartNavigationDelegate
	private let walletManager: WalletManager
	private var loginViewController: UIViewController?
	private let loginTransitionDelegate = LoginTransitionDelegate()

	init(store: Store, walletManager: WalletManager, rootViewController: UIViewController) {
		self.store = store
		self.walletManager = walletManager
		self.rootViewController = rootViewController
		navigationControllerDelegate = StartNavigationDelegate(store: store)
		addSubscriptions()
	}

	private func addSubscriptions() {
		store.subscribe(self,
		                selector: { $0.isStartFlowVisible != $1.isStartFlowVisible },
		                callback: { self.handleStartFlowChange(state: $0) })
		store.lazySubscribe(self,
		                    selector: { $0.isLoginRequired != $1.isLoginRequired },
		                    callback: { self.handleLoginRequiredChange(state: $0) })
		store.subscribe(self, name: .lock,
		                callback: { [weak self] _ in
		                	Task { @MainActor in
		                		self?.presentLoginFlow(isPresentedForLock: true)
		                	}
		                })

        NotificationCenter.default.addObserver(self,
                         selector: #selector(relaunchStartFlow),
                         name: .walletDidWipeNotification,
                         object: nil)
	}

    @objc private func relaunchStartFlow() {
        loginViewController = nil
       // self.presentStartFlow()
//    
//        let startHostingController = StartHostingController(store: store,
//                                                            walletManager: walletManager)
//
//    startHostingController.startViewModel.userWantsToCreate {
//            self.pushPinCreationViewControllerForNewWallet()
//        }
//
//        startHostingController.startViewModel.userWantsToRecover {
//            let recoverIntro = RecoverWalletIntroViewController(didTapNext: self.pushRecoverWalletView)
//            self.navigationController?.setClearNavbar()
//            self.navigationController?.modalPresentationStyle = .fullScreen
//            self.navigationController?.setNavigationBarHidden(false, animated: false)
//            self.navigationController?.pushViewController(recoverIntro, animated: true)
//        }
//
//        navigationController = ModalNavigationController(rootViewController: startHostingController)
//        navigationController?.delegate = navigationControllerDelegate
//        navigationController?.modalPresentationStyle = .fullScreen
//    
//
//    if let startFlow = navigationController {
//        startFlow.setNavigationBarHidden(true, animated: false)
//        rootViewController.present(startFlow, animated: false, completion: nil)
//    }
    }

	private func handleStartFlowChange(state: ReduxState) {
		if state.isStartFlowVisible {
			guardProtected(queue: DispatchQueue.main) { [weak self] in
				self?.presentStartFlow()
			}
		} else {
			dismissStartFlow()
		}
	}

	private func handleLoginRequiredChange(state: ReduxState) {
		if state.isLoginRequired {
			presentLoginFlow(isPresentedForLock: false)
		} else {
			dismissLoginFlow()
		}
	}

	// MARK: - SwiftUI Start Flow

    private func presentStartFlow() {

            let startHostingController = StartHostingController(store: store,
                                                                walletManager: walletManager)

        startHostingController.startViewModel.userWantsToCreate {
                self.pushPinCreationViewControllerForNewWallet()
            }

            startHostingController.startViewModel.userWantsToRecover {
                let recoverIntro = RecoverWalletIntroViewController(didTapNext: self.pushRecoverWalletView)
                self.navigationController?.setClearNavbar()
                self.navigationController?.modalPresentationStyle = .fullScreen
                self.navigationController?.setNavigationBarHidden(false, animated: false)
                self.navigationController?.pushViewController(recoverIntro, animated: true)
            }

            navigationController = ModalNavigationController(rootViewController: startHostingController)
            navigationController?.delegate = navigationControllerDelegate
            navigationController?.modalPresentationStyle = .fullScreen

        if let startFlow = navigationController {
            startFlow.setNavigationBarHidden(true, animated: false)
            rootViewController.present(startFlow, animated: false, completion: nil)
        }
    }

	private var pushRecoverWalletView: () -> Void {
		return { [weak self] in
			guard let myself = self else { return }
			let recoverWalletViewController = EnterPhraseViewController(store: myself.store, walletManager: myself.walletManager, reason: .setSeed(myself.pushPinCreationViewForRecoveredWallet))
			myself.navigationController?.pushViewController(recoverWalletViewController, animated: true)
		}
	}

	private func pushPinCreationViewControllerForNewWallet() {
		let pinCreationViewController = UpdatePinViewController(store: store, walletManager: walletManager, type: .creationNoPhrase, showsBackButton: true, phrase: nil)
		pinCreationViewController.setPinSuccess = { [weak self] pin in
			autoreleasepool {
				guard self?.walletManager.setRandomSeedPhrase() != nil else { self?.handleWalletCreationError(); return }
				self?.store.perform(action: WalletChange.setWalletCreationDate(Date()))
				DispatchQueue.walletQueue.async {
					self?.walletManager.peerManager?.connect()
					DispatchQueue.main.async {
						self?.pushStartPaperPhraseCreationViewController(pin: pin)
						self?.store.trigger(name: .didCreateOrRecoverWallet)
					}
				}
			}
		}

		navigationController?.setNavigationBarHidden(false, animated: false)
		navigationController?.setTintableBackArrow()
		navigationController?.setClearNavbar()
		navigationController?.pushViewController(pinCreationViewController, animated: true)
	}

	private var pushPinCreationViewForRecoveredWallet: (String) -> Void {
		return { [weak self] phrase in
			guard let myself = self else { return }
			let pinCreationView = UpdatePinViewController(store: myself.store, walletManager: myself.walletManager, type: .creationWithPhrase, showsBackButton: false, phrase: phrase)
			pinCreationView.setPinSuccess = { [weak self] _ in
				DispatchQueue.walletQueue.async {
					self?.walletManager.peerManager?.connect()
					DispatchQueue.main.async {
						self?.store.trigger(name: .didCreateOrRecoverWallet)
					}
				}
			}
			myself.navigationController?.pushViewController(pinCreationView, animated: true)
		}
	}

	private func pushStartPaperPhraseCreationViewController(pin: String) {
		let paperPhraseViewController = StartPaperPhraseViewController(store: store, callback: { [weak self] in
			self?.pushWritePaperPhraseViewController(pin: pin)
		})
		paperPhraseViewController.title = String(localized: "Paper Key", bundle: .main)
		paperPhraseViewController.navigationItem.setHidesBackButton(true, animated: false)
		paperPhraseViewController.hideCloseNavigationItem() // Forces user to confirm paper-key

		navigationController?.navigationBar.titleTextAttributes = [
			NSAttributedString.Key.foregroundColor: BrainwalletUIColor.content,
			NSAttributedString.Key.font: UIFont.customBold(size: 17.0)
		]
		navigationController?.pushViewController(paperPhraseViewController, animated: true)
	}

	private func pushWritePaperPhraseViewController(pin: String) {
		let writeViewController = WritePaperPhraseViewController(store: store, walletManager: walletManager, pin: pin, callback: { [weak self] in
			self?.pushConfirmPaperPhraseViewController(pin: pin)
		})
		writeViewController.title = String(localized: "Paper Key", bundle: .main)
		writeViewController.hideCloseNavigationItem()
		navigationController?.pushViewController(writeViewController, animated: true)
	}

	private func pushConfirmPaperPhraseViewController(pin: String) {
		let confirmVC = UIStoryboard(name: "Phrase", bundle: nil)
                .instantiateViewController(withIdentifier: "ConfirmPaperPhraseViewController")
                   as? ConfirmPaperPhraseViewController
		confirmVC?.store = store
		confirmVC?.walletManager = walletManager
		confirmVC?.pin = pin
		confirmVC?.didCompleteConfirmation = { [weak self] in
			guard let myself = self else { return }

            confirmVC?.dismiss(animated: true, completion: {
                myself.store.perform(action: SimpleReduxAlert.Show(.paperKeySet(callback: {
                    myself.store.perform(action: HideStartFlow())
                })))
            })
		}

		navigationController?.navigationBar.tintColor = BrainwalletUIColor.surface
		if let confirmVC = confirmVC {
			navigationController?.pushViewController(confirmVC, animated: true)
		}
	}

	private func presentLoginFlow(isPresentedForLock: Bool) {
		let loginView = LoginViewController(store: store, isPresentedForLock: isPresentedForLock, walletManager: walletManager)
		if isPresentedForLock {
			loginView.shouldSelfDismiss = true
		}
		loginView.transitioningDelegate = loginTransitionDelegate
		loginView.modalPresentationStyle = .overFullScreen
		loginView.modalPresentationCapturesStatusBarAppearance = true
		loginViewController = loginView
		rootViewController.present(loginView, animated: false, completion: nil)
	}

	private func handleWalletCreationError() {
		let alert = UIAlertController(title: String(localized: "Error", bundle: .main), message: String(localized: "Could not create wallet", bundle: .main), preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: String(localized: "Ok", bundle: .main), style: .default, handler: nil))
		navigationController?.present(alert, animated: true, completion: nil)
	}

	private func dismissStartFlow() {
		navigationController?.dismiss(animated: true) { [weak self] in
			self?.navigationController = nil
		}
	}

	private func dismissLoginFlow() {
		loginViewController?.dismiss(animated: true, completion: { [weak self] in
			self?.loginViewController = nil
		})
	}
}
