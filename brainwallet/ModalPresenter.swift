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

	let store: Store
    let window: UIWindow
    let alertHeight: CGFloat = 260.0
    let modalTransitionDelegate: ModalTransitionDelegate
    let messagePresenter = MessageUIPresenter()
    let securityCenterNavigationDelegate = SecurityCenterNavigationDelegate()
    let verifyPinTransitionDelegate = TransitioningDelegate()
    let noAuthApiClient: BWAPIClient
    var currentRequest: PaymentRequest?
    var reachability = ReachabilityMonitor()
    var notReachableAlert: InAppAlert?
    let wipeNavigationDelegate: StartNavigationDelegate
    var receiveHostingController: ReceiveHostingController?
    var buyReceiveHostingController: BuyReceiveHostingController?

    func newBuyOrReceiveView() -> UIViewController? {

        guard let walletManager = walletManager else { return nil }
        var root : ModalViewController?

        var canUserBuy = UserDefaults
            .standard
                .object(forKey: userCurrentLocaleMPApprovedKey) as? Bool ?? false

        receiveHostingController = nil
        buyReceiveHostingController = nil

        if canUserBuy {
            buyReceiveHostingController = BuyReceiveHostingController(store: self.store, walletManager: walletManager, isModalMode: true)
            if let buyReceiveVC = buyReceiveHostingController {
                buyReceiveVC.view.translatesAutoresizingMaskIntoConstraints = false
                root = ModalViewController(childViewController: buyReceiveVC, store: store)

                let heightFactor: CGFloat = 0.8
                NSLayoutConstraint.activate([
                    buyReceiveVC.view.heightAnchor
                        .constraint(equalToConstant:
                                        window.frame.height * heightFactor)
                ])

                buyReceiveVC.dismissBuyReceiveModal = strongify(self) { _ in
                    guard let root = root else { return }
                    root.dismiss(animated: true, completion: nil)
                }
            }
        } else {
            receiveHostingController = ReceiveHostingController(store: self.store, walletManager: walletManager, isModalMode: true)
            if let receiveVC = receiveHostingController {
                receiveVC.view.translatesAutoresizingMaskIntoConstraints = false
                root = ModalViewController(childViewController: receiveVC, store: store)

                let heightFactor: CGFloat = 0.4
                NSLayoutConstraint.activate([
                    receiveVC.view.heightAnchor
                        .constraint(equalToConstant:
                                        window.frame.height * heightFactor)
                ])

                receiveVC.dismissReceiveModal = strongify(self) { _ in
                    guard let root = root else { return }
                    root.dismiss(animated: true, completion: nil)
                }
            }
        }

        return root
    }

    func presentSettings() {
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
                                delay(3.0) {
                                    _ = walletManager.wipeWallet(pin: "forceWipe")
                                    group.leave()
                                }
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
				Setting(title: LAContext.biometricType() == .face ? String(localized: "Face ID Spending Limit") : String(localized: "Touch ID Spending Limit") , accessoryText: { [weak self] in
					guard let myself = self else { return "" }
					guard let rate = myself.store.state.currentRate else { return "" }
					let amount = Amount(amount: walletManager.spendingLimit, rate: rate, maxDigits: myself.store.state.maxDigits)
					return amount.localCurrency
				}, callback: {
					self.pushBiometricsSpendingLimit(onNc: settingsNav)
				}),
				Setting(title: String(localized: "Currency") , accessoryText: {
					let code = self.store.state.userPreferredCurrencyCode
					let components: [String: String] = [NSLocale.Key.currencyCode.rawValue: code]
					let identifier = Locale.identifier(fromComponents: components)
                    return Locale(identifier: identifier).currency?.identifier ?? ""
				}, callback: {
					guard let wm = self.walletManager else { debugPrint(":::NO WALLET MANAGER!"); return }
					settingsNav.pushViewController(UserPreferredCurrencyViewController(walletManager: wm, store: self.store), animated: true)
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

    func presentScan(parent: UIViewController) -> PresentScan {
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

    func presentSecurityCenter() {
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

    func pushBiometricsSpendingLimit(onNc: UINavigationController) {
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

    func presentWritePaperKey(fromViewController vc: UIViewController) {
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
									myself.store.perform(action: HideStartFlow()) })))
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
		start.navigationItem.title = String(localized: "Paper Key")

		if UserDefaults.writePaperPhraseDate != nil {
			start.addCloseNavigationItem(tintColor: .lightGray)
		} else {
			start.hideCloseNavigationItem()
		}

		paperPhraseNavigationController.viewControllers = [start]
		vc.present(paperPhraseNavigationController, animated: true, completion: nil)
	}

    func receiveView(isRequestAmountVisible: Bool) -> UIViewController? {
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

    func copyAllAddressesToClipboard() {
		guard let wallet = walletManager?.wallet else { return }
		let addresses = wallet.allAddresses.filter { wallet.addressIsUsed($0) }
		UIPasteboard.general.string = addresses.joined(separator: "\n")
	}

    var topViewController: UIViewController? {
		var viewController = window.rootViewController
		while viewController?.presentedViewController != nil {
			viewController = viewController?.presentedViewController
		}
		return viewController
	}

    func showNotReachable() {
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

    func hideNotReachable() {
		UIView.animate(withDuration: C.animationDuration, animations: {
			self.notReachableAlert?.bottomConstraint?.constant = 0.0
			self.notReachableAlert?.superview?.layoutIfNeeded()
		}, completion: { _ in
			self.notReachableAlert?.removeFromSuperview()
			self.notReachableAlert = nil
		})
	}

    func showLightWeightAlert(message: String) {
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
