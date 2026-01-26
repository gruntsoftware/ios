import LocalAuthentication
import SafariServices
import SwiftUI
import UIKit

class ModalPresenter: Subscriber {
	var walletManager: WalletManager?
	init(store: Store, walletManager: WalletManager, window: UIWindow, apiClient: BWAPIClient) {
		self.store = store
		self.window = window
		self.walletManager = walletManager
		modalTransitionDelegate = ModalTransitionDelegate(type: .regular, store: store)
		noAuthApiClient = apiClient
		addSubscriptions()
	}

	let store: Store
    let window: UIWindow
    let alertHeight: CGFloat = 260.0
    let modalTransitionDelegate: ModalTransitionDelegate
    let messagePresenter = MessageUIPresenter()
    let verifyPinTransitionDelegate = TransitioningDelegate()
    let noAuthApiClient: BWAPIClient
    var currentRequest: PaymentRequest?
    var reachability = ReachabilityMonitor()
    var notReachableAlert: InAppAlert?
    var receiveHostingController: ReceiveHostingController?

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
                let sfvc = SFSafariViewController(url: url)
                settingsNav.pushViewController(sfvc, animated: true)})],
			"Wallet":
				[
					Setting(title:  String(localized: "Delete my data") , callback: { [weak self] in
						guard let myself = self else { return }
						guard let walletManager = myself.walletManager else { return }
                        let alert = UIAlertController(title: String(localized: "Delete my data"), message: String(localized: "Are you sure you want to delete this wallet & all its data?"), preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title:  String(localized: "Cancel")  , style: .default, handler: { _ in
                            alert.dismiss(animated: true)
                        }))
                        alert.addAction(UIAlertAction(title: String(localized: "Delete all") , style: .default, handler: { _ in
                            let group = DispatchGroup()

                            _ = walletManager.peerManager?.disconnect()
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

    func pushBiometricsSpendingLimit(onNc: UINavigationController) {
		guard let walletManager = walletManager else { return }

		let verify = VerifyPinViewController(bodyText: String(localized: "Please enter your PIN to continue."), pinLength: store.state.pinLength, callback: { [weak self] pin, vc in
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
		guard let window = UIApplication.shared.connectedScenes
                               .compactMap({ $0 as? UIWindowScene })
                               .flatMap({ $0.windows })
                               .first(where: { $0.isKeyWindow })
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
