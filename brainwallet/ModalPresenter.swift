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
        guard let view = UIApplication.shared.currentKeyWindow else { return }
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
