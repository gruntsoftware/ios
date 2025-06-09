import LocalAuthentication
import SafariServices
import SwiftUI
import UIKit

class ModalPresenter: Subscriber, Trackable {
	var walletManager: WalletManager?
	init(store: Store, walletManager: WalletManager, window: UIWindow, apiClient: BWAPIClient) {
		self.store = store
		self.window = window
		self.walletManager = walletManager
		modalTransitionDelegate = ModalTransitionDelegate(type: .regular, store: store)
		wipeNavigationDelegate = StartNavigationDelegate(store: store)
		noAuthApiClient = apiClient
		addSubscriptions()
	}

	private let store: Store
	private let window: UIWindow
	private let alertHeight: CGFloat = 260.0
	private let modalTransitionDelegate: ModalTransitionDelegate
	private let messagePresenter = MessageUIPresenter()
	private let securityCenterNavigationDelegate = SecurityCenterNavigationDelegate()
	private let verifyPinTransitionDelegate = TransitioningDelegate()
	private let noAuthApiClient: BWAPIClient

	private var currentRequest: PaymentRequest?
	private var reachability = ReachabilityMonitor()
	private var notReachableAlert: InAppAlert?
	private let wipeNavigationDelegate: StartNavigationDelegate

	private func addSubscriptions() {
		store.subscribe(self, selector: { $0.rootModal != $1.rootModal }, callback: { state in
		                	Task { @MainActor in
		                		self.presentModal(state.rootModal)
		                	}
		                })
		store.subscribe(self,
		                selector: { $0.alert != $1.alert && $1.alert != nil },
		                callback: { self.handleAlertChange($0.alert) })

		store.subscribe(self, name: .promptUpgradePin, callback: { [weak self] _ in
			self?.presentUpgradePin()
		})
		store.subscribe(self, name: .promptPaperKey, callback: { [weak self]  _ in
            self?.presentWritePaperKey()
		})
		store.subscribe(self, name: .promptBiometrics, callback: { [weak self] _ in
            self?.presentBiometricsSetting()
		})
		store.subscribe(self, name: .promptShareData, callback: { [weak self] _ in
            self?.promptShareData()
		})
		store.subscribe(self, name: .recommendRescan, callback: { [weak self] _ in
            self?.presentRescan()
		})

		store.subscribe(self, name: .scanQr, callback: { [weak self]  _ in
            self?.handleScanQrURL()
		})
		store.subscribe(self, name: .copyWalletAddresses(nil, nil), callback: { [weak self] in
			guard let trigger = $0 else { return }
			if case let .copyWalletAddresses(success, error) = trigger {
				self?.handleCopyAddresses(success: success, error: error)
			}
		})
		reachability.didChange = { isReachable in
			if isReachable {
				self.hideNotReachable()
			} else {
				self.showNotReachable()
			}
		}
		store.subscribe(self, name: .lightWeightAlert(""), callback: {
			guard let trigger = $0 else { return }
			if case let .lightWeightAlert(message) = trigger {
				self.showLightWeightAlert(message: message)
			}
		})
		store.subscribe(self, name: .showAlert(nil), callback: {
			guard let trigger = $0 else { return }
			if case let .showAlert(alert) = trigger {
				if let alert = alert {
					self.topViewController?.present(alert, animated: true, completion: nil)
				}
			}
		})
	}

	private func presentRescan() {
		let vc = ReScanViewController(store: store)
		let nc = UINavigationController(rootViewController: vc)
		nc.setClearNavbar()
		vc.addCloseNavigationItem()
		topViewController?.present(nc, animated: true, completion: nil)
	}

	func presentBiometricsSetting() {
		guard let walletManager = walletManager else { return }
		let biometricsSettings = BiometricsSettingsViewController(walletManager: walletManager, store: store)
        biometricsSettings.addCloseNavigationItem(tintColor: BrainwalletUIColor.content)
		let nc = ModalNavigationController(rootViewController: biometricsSettings)
		biometricsSettings.presentSpendingLimit = strongify(self) { myself in
			myself.pushBiometricsSpendingLimit(onNc: nc)
		}
		nc.setDefaultStyle()
		nc.isNavigationBarHidden = true
		nc.delegate = securityCenterNavigationDelegate
		topViewController?.present(nc, animated: true, completion: nil)
	}

	private func promptShareData() {
		let shareData = ShareDataViewController(store: store)
		let nc = ModalNavigationController(rootViewController: shareData)
		nc.setDefaultStyle()
		nc.isNavigationBarHidden = true
		nc.delegate = securityCenterNavigationDelegate
		shareData.addCloseNavigationItem()
		topViewController?.present(nc, animated: true, completion: nil)
	}

	func presentWritePaperKey() {
		guard let vc = topViewController else { return }
		presentWritePaperKey(fromViewController: vc)
	}

	func presentUpgradePin() {
		guard let walletManager = walletManager else { return }
		let updatePin = UpdatePinViewController(store: store, walletManager: walletManager, type: .update)
		let nc = ModalNavigationController(rootViewController: updatePin)
		nc.setDefaultStyle()
		nc.isNavigationBarHidden = true
		nc.delegate = securityCenterNavigationDelegate
		updatePin.addCloseNavigationItem()
		topViewController?.present(nc, animated: true, completion: nil)
	}

	private func presentModal(_ type: RootModal, configuration: ((UIViewController) -> Void)? = nil) {
		guard type != .loginScan else { return presentLoginScan() }
		guard let vc = rootModalViewController(type)
		else {
			store.perform(action: RootModalActions.Present(modal: .none))
			return
		}
		vc.transitioningDelegate = modalTransitionDelegate
		vc.modalPresentationStyle = .overFullScreen
		vc.modalPresentationCapturesStatusBarAppearance = true
		configuration?(vc)
		topViewController?.present(vc, animated: true, completion: {
			self.store.perform(action: RootModalActions.Present(modal: .none))
			self.store.trigger(name: .hideStatusBar)
		})
	}

	private func handleAlertChange(_ type: AlertType?) {
		guard let type = type else { return }
		presentAlert(type, completion: {
			self.store.perform(action: SimpleReduxAlert.Hide())
		})
	}

	private func presentAlert(_ type: AlertType, completion: @escaping () -> Void) {
		let alertView = AlertView(type: type)
		guard let window = UIApplication.shared.windows.filter({ $0.isKeyWindow }).first
		else {
			return
		}

		let size = window.bounds.size
		window.addSubview(alertView)

		let topConstraint = alertView.constraint(.top, toView: window, constant: size.height)
		alertView.constrain([
			alertView.constraint(.width, constant: size.width),
			alertView.constraint(.height, constant: alertHeight + 25.0),
			alertView.constraint(.leading, toView: window, constant: nil),
			topConstraint
		])
		window.layoutIfNeeded()

		UIView.spring(0.6, animations: {
			topConstraint?.constant = size.height - self.alertHeight
			window.layoutIfNeeded()
		}, completion: { _ in
			alertView.animate()
			UIView.spring(0.6, delay: 3.0, animations: {
				topConstraint?.constant = size.height
				window.layoutIfNeeded()
			}, completion: { _ in
				// TODO: - Make these callbacks generic
				if case let .paperKeySet(callback) = type {
					callback()
				}
				if case let .pinSet(callback) = type {
					callback()
				}
				if case let .sweepSuccess(callback) = type {
					callback()
				}
				completion()
				alertView.removeFromSuperview()
			})
		})
	}

	private func rootModalViewController(_ type: RootModal) -> UIViewController? {
		switch type {
		case .none:
			return nil
		case .send:
			return makeSendView()
		case .receive:
			return receiveView(isRequestAmountVisible: true)
		case .menu:
			return menuViewController()
		case .loginScan:
			return nil // The scan view needs a custom presentation
		case .loginAddress:
			return receiveView(isRequestAmountVisible: false)
		case .wipeEmptyWallet:
			return wipeEmptyView()
		case .requestAmount:
			guard let wallet = walletManager?.wallet else { return nil }
			let requestVc = RequestAmountViewController(wallet: wallet, store: store)
			requestVc.presentEmail = { [weak self] bitcoinURL, image in
				self?.messagePresenter.presenter = self?.topViewController
				self?.messagePresenter.presentMailCompose(bitcoinURL: bitcoinURL, image: image)
			}
			requestVc.presentText = { [weak self] bitcoinURL, image in
				self?.messagePresenter.presenter = self?.topViewController
				self?.messagePresenter.presentMessageCompose(bitcoinURL: bitcoinURL, image: image)
			}
			return ModalViewController(childViewController: requestVc, store: store)
		}
	}

	private func wipeEmptyView() -> UIViewController? {
		guard let walletManager = walletManager else { return nil }

		let wipeEmptyvc = WipeEmptyWalletViewController(walletManager: walletManager, store: store, didTapYesDelete: ({ [weak self] in
			guard let myself = self else { return }
			myself.wipeWallet()
		}))
		return ModalViewController(childViewController: wipeEmptyvc, store: store)
	}

	private func makeSendView() -> UIViewController? {
		guard !store.state.walletState.isRescanning
		else {
			let alert = UIAlertController(title:  "Error" , message: "Rescanning" , preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: "Ok" , style: .cancel, handler: nil))
			topViewController?.present(alert, animated: true, completion: nil)
			return nil
		}
		guard let walletManager = walletManager else { return nil }
		guard let kvStore = walletManager.apiClient?.kv else { return nil }

		let sendVC = SendViewController(store: store, sender: Sender(walletManager: walletManager, kvStore: kvStore, store: store), walletManager: walletManager, initialRequest: currentRequest)
		currentRequest = nil

		if store.state.isLoginRequired {
			sendVC.isPresentedFromLock = true
		}

		let root = ModalViewController(childViewController: sendVC, store: store)
		sendVC.presentScan = presentScan(parent: root)
		sendVC.presentVerifyPin = { [weak self, weak root] bodyText, callback in
			guard let myself = self else { return }
			guard let myroot = root else { return }

			let vc = VerifyPinViewController(bodyText: bodyText, pinLength: myself.store.state.pinLength, callback: callback)
			vc.transitioningDelegate = myself.verifyPinTransitionDelegate
			vc.modalPresentationStyle = .overFullScreen
			vc.modalPresentationCapturesStatusBarAppearance = true
			myroot.view.isFrameChangeBlocked = true
			myroot.present(vc, animated: true, completion: nil)
		}
		sendVC.onPublishSuccess = { [weak self] in
			self?.presentAlert(.sendSuccess, completion: {})
		}
		return root
	}

	private func receiveView(isRequestAmountVisible: Bool) -> UIViewController? {
		guard let wallet = walletManager?.wallet else { return nil }
		let receiveVC = ReceiveViewController(wallet: wallet, store: store, isRequestAmountVisible: isRequestAmountVisible)
		let root = ModalViewController(childViewController: receiveVC, store: store)
		receiveVC.presentEmail = { [weak self, weak root] address, image in
			guard let root = root else { return }
			self?.messagePresenter.presenter = root
			self?.messagePresenter.presentMailCompose(litecoinAddress: address, image: image)
		}
		receiveVC.presentText = { [weak self, weak root] address, image in
			guard let root = root else { return }
			self?.messagePresenter.presenter = root
			self?.messagePresenter.presentMessageCompose(address: address, image: image)
		}
		return root
	}

	private func menuViewController() -> UIViewController? {
		let menu = MenuViewController()
		let root = ModalViewController(childViewController: menu, store: store)
		menu.didTapSecurity = { [weak self, weak menu] in
			self?.modalTransitionDelegate.reset()
			menu?.dismiss(animated: true) {
				self?.presentSecurityCenter()
			}
		}

		menu.didTapSupport = { [weak self, weak menu] in
			menu?.dismiss(animated: true, completion: {
				let urlString = BrainwalletSupport.dashboard

				guard let url = URL(string: urlString) else { return }

				BWAnalytics.logEventWithParameters(itemName: ._20201118_DTS)

				let vc = SFSafariViewController(url: url)
				self?.topViewController?.present(vc, animated: true, completion: nil)
			})
		}
		menu.didTapLock = { [weak self, weak menu] in
			menu?.dismiss(animated: true) {
				self?.store.trigger(name: .lock)
			}
		}
		menu.didTapSettings = { [weak self, weak menu] in
			menu?.dismiss(animated: true) {
				self?.presentSettings()
			}
		}
		return root
	}

	private func presentLoginScan() {
		guard let top = topViewController else { return }
		let present = presentScan(parent: top)
		store.perform(action: RootModalActions.Present(modal: .none))
		present { paymentRequest in
			self.currentRequest = paymentRequest
			self.presentModal(.send)
		}
	}

	private func presentSettings() {
		guard let topVC = topViewController,
              let walletManager = walletManager else { return }
		let settingsNav = UINavigationController()
		let sections = ["About", "Wallet", "Manage"]

		let rows = [
			"About": [Setting(title: "Social links" ,
                              accessoryText: {
                return "linktr.ee/brainwallet"
            }, callback: {
                let urlString = BrainwalletSocials.linktree
                guard let url = URL(string: urlString) else { return }
                BWAnalytics.logEventWithParameters(itemName: ._20250504_DTSM)
                let vc = SFSafariViewController(url: url)
                settingsNav.pushViewController(vc, animated: true)})],
			"Wallet":
				[
					Setting(title: "Delete my data" , callback: { [weak self] in
						guard let myself = self else { return }
						guard let walletManager = myself.walletManager else { return }
                        let alert = UIAlertController(title: String(localized: "Delete my data"), message: String(localized: "Are you sure you want to delete this wallet & all its data?"), preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title:  String(localized: "Cancel")  , style: .default, handler: { _ in
                            alert.dismiss(animated: true)
                        }))
                        alert.addAction(UIAlertAction(title: String(localized: "Delete all") , style: .default, handler: { _ in
                            let group = DispatchGroup()
                            
                            _ = walletManager.peerManager?.disconnect()
                            BWAnalytics.logEventWithParameters(itemName: ._20250522_DDAD)
                            group.enter()
                            DispatchQueue.walletQueue.async {
                                _ = walletManager.wipeWallet(pin: "forceWipe")
                                group.leave()
                            }
                            group.enter()
                            DispatchQueue.walletQueue.asyncAfter(deadline: .now() + 1.0) {
                                _ = walletManager.deleteWalletDatabase(pin: "forceWipe")
                                group.leave()
                            }
                            group.notify(queue: .main) {
                                NotificationCenter.default.post(name: .walletDidWipeNotification, object: nil)
                            }
                        }))
                        self?.topViewController?.present(alert, animated: true)
						 
					}),
					Setting(title: String(localized: "Show seed words") , callback: { [weak self] in

						guard let myself = self else { return }
						guard let walletManager = myself.walletManager else { return }
						let showSeedsView = UIHostingController(rootView:
							SeedWordContainerView(walletManager: walletManager))
						settingsNav.pushViewController(showSeedsView, animated: true)
					})
				],
			"Manage": [
				Setting(title: LAContext.biometricType() == .face ?String(localized: "Face ID Spending Limit")  : String(localized: "Touch ID Spending Limit") , accessoryText: { [weak self] in
					guard let myself = self else { return "" }
					guard let rate = myself.store.state.currentRate else { return "" }
					let amount = Amount(amount: walletManager.spendingLimit, rate: rate, maxDigits: myself.store.state.maxDigits)
					return amount.localCurrency
				}, callback: {
					self.pushBiometricsSpendingLimit(onNc: settingsNav)
				}),
				Setting(title: String(localized: "Currency") , accessoryText: {
					let code = self.store.state.defaultCurrencyCode
					let components: [String: String] = [NSLocale.Key.currencyCode.rawValue: code]
					let identifier = Locale.identifier(fromComponents: components)
                    return Locale(identifier: identifier).currency?.identifier ?? ""
				}, callback: {
					guard let wm = self.walletManager else { debugPrint(":::NO WALLET MANAGER!"); return }
					settingsNav.pushViewController(DefaultCurrencyViewController(walletManager: wm, store: self.store), animated: true)
				}),
				Setting(title: String(localized: "Sync") , callback: { [weak self] in
					let alert = UIAlertController(title: String(localized: "Sync with Blockchain?") , message: String(localized: "You will not be able to send money while syncing."), preferredStyle: .alert)
					alert.addAction(UIAlertAction(title:  String(localized: "Cancel")  , style: .default, handler: { _ in
						alert.dismiss(animated: true)
					}))
					alert.addAction(UIAlertAction(title: String(localized: "Sync") , style: .default, handler: {  [weak self] _ in
						self?.store.trigger(name: .rescan)
						BWAnalytics.logEventWithParameters(itemName: ._20200112_DSR)
						alert.dismiss(animated: true)
						self?.topViewController?.dismiss(animated: true)
					}))
					self?.topViewController?.present(alert, animated: true)
				}),
				Setting(title: String(localized: "Update PIN") , callback: strongify(self) { myself in
					let updatePin = UpdatePinViewController(store: myself.store, walletManager: walletManager, type: .update)
					settingsNav.pushViewController(updatePin, animated: true)
				}),
                Setting(title: String(localized: "Share data")  , callback: strongify(self) { myself in
                    settingsNav.pushViewController(ShareDataViewController(store: myself.store), animated: true)
                })
			]
		]

		let settings = SettingsViewController(sections: sections, rows: rows)
		settings.addCloseNavigationItem()
		settingsNav.viewControllers = [settings]
        topVC.present(settingsNav, animated: true, completion: nil)
	}

    private func presentScan(parent: UIViewController) -> PresentScan {
        return { [weak parent] scanCompletion in
            guard let parent = parent else { return }
            guard ScanViewController.isCameraAllowed else {
                ScanViewController.presentCameraUnavailableAlert(fromRoot: parent)
                return
            }
            
            let vc = ScanViewController(completion: { paymentRequest in
                
                guard let request = paymentRequest else {
                    assertionFailure("Invalid payment request type: \(String(describing: paymentRequest))")
                    return
                }
                scanCompletion(request)
                parent.view.isFrameChangeBlocked = false
                
            }, isValidURI: { address in
                return address.isValidAddress
            })
            
            parent.view.isFrameChangeBlocked = true
            parent.present(vc, animated: true, completion: {})
        }
    }

	private func presentSecurityCenter() {
		guard let walletManager = walletManager else { return }
		let securityCenter = SecurityCenterViewController(store: store, walletManager: walletManager)
		let nc = ModalNavigationController(rootViewController: securityCenter)
		nc.setDefaultStyle()
		nc.isNavigationBarHidden = true
		nc.delegate = securityCenterNavigationDelegate
		securityCenter.didTapPin = { [weak self] in
			guard let myself = self else { return }
			let updatePin = UpdatePinViewController(store: myself.store, walletManager: walletManager, type: .update)
			nc.pushViewController(updatePin, animated: true)
		}
		securityCenter.didTapBiometrics = strongify(self) { myself in
			let biometricsSettings = BiometricsSettingsViewController(walletManager: walletManager, store: myself.store)
			biometricsSettings.presentSpendingLimit = {
				myself.pushBiometricsSpendingLimit(onNc: nc)
			}
			nc.pushViewController(biometricsSettings, animated: true)
		}
		securityCenter.didTapPaperKey = { [weak self] in
			self?.presentWritePaperKey(fromViewController: nc)
		}

		window.rootViewController?.present(nc, animated: true, completion: nil)
	}

	private func pushBiometricsSpendingLimit(onNc: UINavigationController) {
		guard let walletManager = walletManager else { return }

		let verify = VerifyPinViewController(bodyText: String(localized: "Please enter your PIN to continue.") , pinLength: store.state.pinLength, callback: { [weak self] pin, vc in
			guard let myself = self else { return false }
			if walletManager.authenticate(pin: pin) {
				vc.dismiss(animated: true, completion: {
					let spendingLimit = BiometricsSpendingLimitViewController(walletManager: walletManager, store: myself.store)
					onNc.pushViewController(spendingLimit, animated: true)
				})
				return true
			} else {
				return false
			}
		})
		verify.transitioningDelegate = verifyPinTransitionDelegate
		verify.modalPresentationStyle = .overFullScreen
		verify.modalPresentationCapturesStatusBarAppearance = true
		onNc.present(verify, animated: true, completion: nil)
	}

	private func presentWritePaperKey(fromViewController vc: UIViewController) {
		guard let walletManager = walletManager else { return }
		let paperPhraseNavigationController = UINavigationController()
		paperPhraseNavigationController.setClearNavbar()
		paperPhraseNavigationController.setWhiteStyle()
		paperPhraseNavigationController.modalPresentationStyle = .overFullScreen
		let start = StartPaperPhraseViewController(store: store, callback: { [weak self] in
			guard let myself = self else { return }
			let verify = VerifyPinViewController(bodyText: String(localized: "Please enter your PIN to continue."), pinLength: myself.store.state.pinLength, callback: { pin, vc in
				if walletManager.authenticate(pin: pin) {
					var write: WritePaperPhraseViewController?
					write = WritePaperPhraseViewController(store: myself.store, walletManager: walletManager, pin: pin, callback: { [weak self] in
						guard let myself = self else { return }
						let confirmVC = UIStoryboard(name: String(localized: "Phrase"), bundle: nil).instantiateViewController(withIdentifier: "ConfirmPaperPhraseViewController") as? ConfirmPaperPhraseViewController
						confirmVC?.store = myself.store
						confirmVC?.walletManager = myself.walletManager
						confirmVC?.pin = pin
						confirmVC?.didCompleteConfirmation = {
							confirmVC?.dismiss(animated: true, completion: {
								myself.store.perform(action: SimpleReduxAlert.Show(.paperKeySet(callback: {
									myself.store.perform(action: HideStartFlow())

								})))
							})
						}
						if let confirm = confirmVC {
							paperPhraseNavigationController.pushViewController(confirm, animated: true)
						}
					})
					write?.hideCloseNavigationItem()
					vc.dismiss(animated: true, completion: {
						guard let write = write else { return }
						paperPhraseNavigationController.pushViewController(write, animated: true)
					})
					return true
				} else {
					return false
				}
			})
			verify.transitioningDelegate = self?.verifyPinTransitionDelegate
			verify.modalPresentationStyle = .overFullScreen
			verify.modalPresentationCapturesStatusBarAppearance = true
			paperPhraseNavigationController.present(verify, animated: true, completion: nil)
		})
		start.navigationItem.title = "Paper Key"

		if UserDefaults.writePaperPhraseDate != nil {
			start.addCloseNavigationItem(tintColor: .lightGray)
		} else {
			start.hideCloseNavigationItem()
		}

		paperPhraseNavigationController.viewControllers = [start]
		vc.present(paperPhraseNavigationController, animated: true, completion: nil)
	}

	private func wipeWallet() {
		let group = DispatchGroup()
		let alert = UIAlertController(title: String(localized: "Delete my wallet & data?"), message: String(localized: "Are you sure you want to delete this wallet & all its data? You will not be able to recover your seed words or any other data."), preferredStyle: .alert)
		alert.addAction(UIAlertAction(title:  String(localized: "Cancel")  , style: .default, handler: nil))
		alert.addAction(UIAlertAction(title: String(localized: "Delete All") , style: .default, handler: { _ in
			self.topViewController?.dismiss(animated: true, completion: {
				let activity = BRActivityViewController(message: String(localized: "Deleting...") )
				self.topViewController?.present(activity, animated: true, completion: nil)

				group.enter()
				DispatchQueue.walletQueue.async {
					self.walletManager?.peerManager?.disconnect()
					group.leave()
				}

				group.enter()
				DispatchQueue.walletQueue.asyncAfter(deadline: .now() + 2.0) {
					group.leave()
				}

				group.notify(queue: .main) {
					if let canForceWipeWallet = (self.walletManager?.wipeWallet(pin: "forceWipe")),
					   canForceWipeWallet {
						self.store.trigger(name: .reinitWalletManager {
							activity.dismiss(animated: true, completion: {
							})
						})
					} else {
						let failure = UIAlertController(title: String(localized: "Failed") , message: String(localized: "Failed to wipe wallet."), preferredStyle: .alert)
						failure.addAction(UIAlertAction(title: String(localized: "Ok") , style: .default, handler: nil))
						self.topViewController?.present(failure, animated: true, completion: nil)
					}
				}
			})
		}))
		topViewController?.present(alert, animated: true, completion: nil)
	}

	private func handleScanQrURL() {
		guard !store.state.isLoginRequired else { presentLoginScan(); return }

		if topViewController is MainViewController || topViewController is LoginViewController {
			presentLoginScan()
		} else {
			BWAnalytics.logEventWithParameters(itemName: ._20210427_HCIEEH)
			if let presented = UIApplication.shared.windows.filter({ $0.isKeyWindow }).first?.rootViewController?.presentedViewController {
				presented.dismiss(animated: true, completion: { self.presentLoginScan() })
			}
		}
	}

	private func handleCopyAddresses(success: String?, error _: String?) {
		guard let walletManager = walletManager else { return }
		let alert = UIAlertController(title: String(localized: "Copy Wallet Addresses") , message: String(localized: "Copy wallet addresses to clipboard?") , preferredStyle: .alert)
		alert.addAction(UIAlertAction(title:  String(localized: "Cancel")  , style: .cancel, handler: nil))
		alert.addAction(UIAlertAction(title: String(localized: "Copy") , style: .default, handler: { [weak self] _ in
			guard let myself = self else { return }
			let verify = VerifyPinViewController(bodyText: String(localized: "Authorize to copy wallet address to clipboard") , pinLength: myself.store.state.pinLength, callback: { [weak self] pin, view in
				if walletManager.authenticate(pin: pin) {
					self?.copyAllAddressesToClipboard()
					view.dismiss(animated: true, completion: {
						self?.store.perform(action: SimpleReduxAlert.Show(.addressesCopied))
						if let success = success, let url = URL(string: success) {
							UIApplication.shared.open(url, options: [:], completionHandler: nil)
						}
					})
					return true
				} else {
					return false
				}
			})
			verify.transitioningDelegate = self?.verifyPinTransitionDelegate
			verify.modalPresentationStyle = .overFullScreen
			verify.modalPresentationCapturesStatusBarAppearance = true
			self?.topViewController?.present(verify, animated: true, completion: nil)
		}))
		topViewController?.present(alert, animated: true, completion: nil)
	}

	private func copyAllAddressesToClipboard() {
		guard let wallet = walletManager?.wallet else { return }
		let addresses = wallet.allAddresses.filter { wallet.addressIsUsed($0) }
		UIPasteboard.general.string = addresses.joined(separator: "\n")
	}

	private var topViewController: UIViewController? {
		var viewController = window.rootViewController
		while viewController?.presentedViewController != nil {
			viewController = viewController?.presentedViewController
		}
		return viewController
	}

	private func showNotReachable() {
		guard notReachableAlert == nil else { return }
		let alert = InAppAlert(message: String(localized: "No internet connection found. Check your connection and try again.") , image: #imageLiteral(resourceName: "BrokenCloud"))
		notReachableAlert = alert
		guard let window = UIApplication.shared.windows.filter({ $0.isKeyWindow }).first
		else {
			return
		}
		let size = window.bounds.size
		window.addSubview(alert)
		let bottomConstraint = alert.bottomAnchor.constraint(equalTo: window.topAnchor, constant: 0.0)
		alert.constrain([
			alert.constraint(.width, constant: size.width),
			alert.constraint(.height, constant: InAppAlert.height),
			alert.constraint(.leading, toView: window, constant: nil),bottomConstraint
		])
		window.layoutIfNeeded()
		alert.bottomConstraint = bottomConstraint
		alert.hide = {
			self.hideNotReachable()
		}
		UIView.spring(C.animationDuration, animations: {
			alert.bottomConstraint?.constant = InAppAlert.height
			window.layoutIfNeeded()
		}, completion: { _ in })
	}

	private func hideNotReachable() {
		UIView.animate(withDuration: C.animationDuration, animations: {
			self.notReachableAlert?.bottomConstraint?.constant = 0.0
			self.notReachableAlert?.superview?.layoutIfNeeded()
		}, completion: { _ in
			self.notReachableAlert?.removeFromSuperview()
			self.notReachableAlert = nil
		})
	}

	private func showLightWeightAlert(message: String) {
		let alert = LightWeightAlert(message: message)

		guard let view = UIApplication.shared.windows.filter({ $0.isKeyWindow }).first
		else {
			return
		}

		view.addSubview(alert)
		alert.constrain([
			alert.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			alert.centerYAnchor.constraint(equalTo: view.centerYAnchor)
		])
		alert.background.effect = nil
		UIView.animate(withDuration: 0.6, animations: {
			alert.background.effect = alert.effect
		}, completion: { _ in
			UIView.animate(withDuration: 0.6, delay: 1.0, options: [], animations: {
				alert.background.effect = nil
			}, completion: { _ in
				alert.removeFromSuperview()
			})
		})
	}
}
