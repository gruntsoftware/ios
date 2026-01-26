//
//  ModalPresenter+Extension.swift
//  brainwallet
//
//  Created by Kerry Washington on 09/06/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//
import LocalAuthentication
import SafariServices
import SwiftUI
import UIKit

extension ModalPresenter {
    func rootModalViewController(_ type: RootModal) -> UIViewController? {
        switch type {
        case .none:
            return nil
        case .send:
            return nil // DEPRECATED return makeSendView()
        case .receive:
            return nil
        case .menu:
            return menuViewController()
        case .loginScan:
            return nil // The scan view needs a custom presentation
        case .loginAddress:
            return nil
        case .wipeEmptyWallet:
            return nil
        case .requestAmount:
            return nil
        }
    }

    func presentModal(_ type: RootModal, configuration: ((UIViewController) -> Void)? = nil) {
        guard type != .loginScan else { return presentLoginScan() }
        guard let viewC = rootModalViewController(type)
        else {
            store.perform(action: RootModalActions.Present(modal: .none))
            return
        }
        viewC.transitioningDelegate = modalTransitionDelegate
        viewC.modalPresentationStyle = .overFullScreen
        viewC.modalPresentationCapturesStatusBarAppearance = true
        configuration?(viewC)
        topViewController?.present(viewC, animated: true, completion: {
            self.store.perform(action: RootModalActions.Present(modal: .none))
            self.store.trigger(name: .hideStatusBar)
        })
    }

    func handleAlertChange(_ type: AlertType?) {
        guard let type = type else { return }
        presentAlert(type, completion: {
            self.store.perform(action: SimpleReduxAlert.Hide())
        })
    }

    func presentAlert(_ type: AlertType, completion: @escaping () -> Void) {
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
            SoundsHelper().play(filename: "bloop", type: "mp3")
            alertView.animate()
            UIView.spring(0.6, delay: 0.7, animations: {
                topConstraint?.constant = size.height
                window.layoutIfNeeded()
            }, completion: { _ in
                if case let .paperKeySet(callback) = type { callback() }
                if case let .pinSet(callback) = type { callback() }
                if case let .sweepSuccess(callback) = type { callback() }
                completion()
                alertView.removeFromSuperview()
            })
        })
    }

    func handleScanQrURL() {
        guard !store.state.isLoginRequired else { presentLoginScan(); return }

        if topViewController is MainViewController || topViewController is LoginViewController {
            presentLoginScan()
        } else {
            if let presented = UIApplication
                .shared.windows.filter({ $0.isKeyWindow })
                .first?.rootViewController?.presentedViewController {
                presented.dismiss(animated: true, completion: { self.presentLoginScan() })
            }
        }
    }

    func wipeWallet() {
        let group = DispatchGroup()
        let alert = UIAlertController(title: String(localized: "Delete my wallet & data?"),
                                      message: String(localized: "Are you sure you want to delete this wallet & all its data? You will not be able to recover your seed words or any other data."), preferredStyle: .alert)
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

    func menuViewController() -> UIViewController? {
        let menu = MenuViewController()
        let root = ModalViewController(childViewController: menu, store: store)
        menu.didTapSecurity = { [weak self, weak menu] in
            self?.modalTransitionDelegate.reset()
        }

        menu.didTapSupport = { [weak self, weak menu] in
            menu?.dismiss(animated: true, completion: {
                let urlString = BrainwalletSupport.dashboard

                guard let url = URL(string: urlString) else { return }

                let vc = SFSafariViewController(url: url)
                self?.topViewController?.present(vc, animated: true, completion: nil)
            })
        }
        menu.didTapLock = { [weak self, weak menu] in
            menu?.dismiss(animated: true) { self?.store.trigger(name: .lock) }
        }
        menu.didTapSettings = { [weak self, weak menu] in
            menu?.dismiss(animated: true) { self?.presentSettings() }
        }
        return root
    }

    func presentLoginScan() {
        /// DEPRECATED WITH new Bento Style
    }

    func handleCopyAddresses(success: String?, error _: String?) {
        guard let walletManager = walletManager else { return }
        let alert = UIAlertController(title: String(localized: "Copy Wallet Addresses") , message: String(localized: "Copy wallet addresses to clipboard?") , preferredStyle: .alert)
        alert.addAction(UIAlertAction(title:  String(localized: "Cancel")  , style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: String(localized: "Copy") , style: .default, handler: { [weak self] _ in
            guard let myself = self else { return }
            let verify = VerifyPinViewController(bodyText: String(localized: "Authorize to copy wallet address to clipboard"),
                                                 pinLength: myself.store.state.pinLength, callback: { [weak self] pinString, view in
                if walletManager.authenticate(pin: pinString) {
                    self?.copyAllAddressesToClipboard()
                    view.dismiss(animated: true, completion: {
                        self?.store.perform(action: SimpleReduxAlert.Show(.addressesCopied))
                        if let success = success,
                            let urlObj = URL(string: success) {
                            UIApplication.shared.open(urlObj, options: [:],
                                                      completionHandler: nil)
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

    func addSubscriptions() {
        store.subscribe(self, selector: { $0.rootModal != $1.rootModal }, callback: { state in
                            Task { @MainActor in
                                self.presentModal(state.rootModal)
                            }
                        })
        store.subscribe(self,
                        selector: { $0.alert != $1.alert && $1.alert != nil },
                        callback: { self.handleAlertChange($0.alert) })

        store.subscribe(self, triggerName: .scanQr, callback: { [weak self]  _ in
            self?.handleScanQrURL()
        })
        store.subscribe(self, triggerName: .copyWalletAddresses(nil, nil), callback: { [weak self] in
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
        store.subscribe(self, triggerName: .lightWeightAlert(""), callback: {
            guard let trigger = $0 else { return }
            if case let .lightWeightAlert(message) = trigger {
                self.showLightWeightAlert(message: message)
            }
        })
        store.subscribe(self, triggerName: .showAlert(nil), callback: {
            guard let trigger = $0 else { return }
            if case let .showAlert(alert) = trigger {
                if let alert = alert {
                    self.topViewController?.present(alert, animated: true, completion: nil)
                }
            }
        })
    }
}
