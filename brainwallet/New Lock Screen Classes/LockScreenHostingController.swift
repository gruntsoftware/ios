//
//  LockScreenHostingController.swift
//  brainwallet
//
//  Created by Kerry Washington on 28/05/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

import Foundation
import SwiftUI
import Firebase
import Combine
import LocalAuthentication
import UIKit

protocol LockScreenHostingDelegate {
    func didUnlock()
}

class LockScreenHostingController: UIHostingController<LockScreenView>, Subscriber {

    var viewModel: LockScreenViewModel
    var lockScreenView: LockScreenView
    let store: Store
    var walletManager: WalletManager?

    var didTapWipeWallet: ((Bool) -> Void)?

    var userDidPreferDarkMode: ((Bool) -> Void)?

     var shouldSelfDismiss = false
     var delegate: LockScreenHostingDelegate?
    //    private var backgroundView = UIView()
    private var unlockTimer: Timer?

    init(store: Store?, walletManager: WalletManager? = nil) {
        guard let validStore = store else {
            preconditionFailure("LockScreenHostingController requires a non-nil store.")
        }

        self.store = validStore
        self.walletManager = walletManager

        // lockScreenView.backgroundColor = BrainwalletUIColor.surface

        viewModel = LockScreenViewModel(store: validStore)
        lockScreenView = LockScreenView(viewModel: viewModel)
        super.init(rootView: lockScreenView)

        viewModel.userSubmittedPIN = { [weak self] enteredPIN in
            self?.authenticate(pin: enteredPIN)
        }

        viewModel.userDidTapQR = { [weak self] in

        }

        viewModel.didTapWipeWallet = { [weak self] userWantsToDelete in

            if userWantsToDelete {
                self?.didTapWipeWallet?(userWantsToDelete)
            }
        }

        viewModel.userDidPreferDarkMode = { [weak self] userPrefersDarkMode in
            self?.userDidPreferDarkMode?(userPrefersDarkMode)
        }
    }

        deinit {
            store.unsubscribe(self)
        }

    func walletWiped() {
        viewModel.didCompleteWipingWallet = true
    }

    //    private func addLockScreenHostingControllerCallbacks() {
    //        lockScreenView.didEnterPIN = { [weak self] pin in
    //            guard let myself = self else { return }
    //            if pin.count == myself.store.state.pinLength {
    //                self?.authenticate(pin: pin)
    //            }
    //        }
    //
    //        lockScreenView.didTapQR = { [weak self]  in
    //            guard let myself = self else { return }
    //            myself.showLTCAddress()
    //        }
    //
    //        lockScreenView.didTapWipeWallet = { [weak self] userWantsToDelete in
    //            guard let myself = self else { return }
    //
    //            if userWantsToDelete {
    //                myself.wipeWallet()
    //            }
    //        }
    //
    //        lockScreenView.userDidPreferDarkMode = { [weak self] userDidPreferDarkMode in
    //            guard let myself = self else { return }
    //            myself.updateTheme(shouldBeDark: userDidPreferDarkMode)
    //        }
    //    }
    //
    //    private func addSubviews() {
    //        view.addSubview(backgroundView)
    //        view.addSubview(lockScreenView.view)
    //    }
    //
    //    private func addConstraints() {
    //        backgroundView.constrain(toSuperviewEdges: nil)
    //        lockScreenView.view.constrain([
    //            lockScreenView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
    //            lockScreenView.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
    //            lockScreenView.view.topAnchor.constraint(equalTo: backgroundView.topAnchor),
    //            lockScreenView.view.heightAnchor.constraint(equalToConstant: view.frame.height)
    //        ])
    //    }
    //
    //    private func wipeWallet() {
    //                guard let walletManager = walletManager else {
    //                    return
    //                }
    //
    //                let group = DispatchGroup()
    //
    //                group.enter()
    //                DispatchQueue.walletQueue.async {
    //                    _ = walletManager.peerManager?.disconnect()
    //                    group.leave()
    //                }
    //
    //                group.enter()
    //                DispatchQueue.walletQueue.async {
    //                    _ = walletManager.wipeWallet(pin: "forceWipe")
    //                    group.leave()
    //                }
    //
    //                group.enter()
    //                DispatchQueue.walletQueue.asyncAfter(deadline: .now() + 1.0) {
    //                    _ = walletManager.deleteWalletDatabase(pin: "forceWipe")
    //                    group.leave()
    //                }
    //
    //                group.notify(queue: .main) {
    //                    self.lockScreenView.walletWiped()
    //                    NotificationCenter.default.post(name: .walletDidWipeNotification, object: nil)
    //                }
    //    }
    //
        private func authenticate(pin: String) {
            guard let walletManager = walletManager else { return }
            guard walletManager.authenticate(pin: pin) else {
                return authenticationFailed()
            }
            authenticationSucceded()
        }

        private func authenticationSucceded() {
            UIView.spring(0.6, delay: 0.4, animations: {
                self.view.layoutIfNeeded()
            }) { _ in
                self.delegate?.didUnlock()
                if self.shouldSelfDismiss {
                    self.dismiss(animated: true, completion: nil)
                }
                self.store.perform(action: LoginSuccess())
                self.store.trigger(name: .showStatusBar)
            }
        }

        private func authenticationFailed() {
            lockScreenView.viewModel.authenticationFailed = true
        }
    //
    //    private var shouldUseBiometrics: Bool {
    //        guard let walletManager = walletManager else { return false }
    //        return LAContext.canUseBiometrics && !walletManager.pinLoginRequired && store.state.isBiometricsEnabled
    //    }
    //
    //    @objc func biometricsTapped() {
    //        guard !isWalletDisabled else { return }
    //        walletManager?.authenticate(biometricsPrompt: "Unlock your Brainwallet." , completion: { result in
    //            if result == .success {
    //                self.authenticationSucceded()
    //            }
    //        })
    //    }
    //
    //    @objc func updateTheme(shouldBeDark: Bool) {
    //        UserDefaults.userPreferredDarkTheme = shouldBeDark
    //        NotificationCenter
    //            .default
    //            .post(name: .changedThemePreferenceNotification,
    //                object: nil)
    //    }
    //
    //    @objc func showLTCAddress() {
    //        store.perform(action: RootModalActions.Present(modal: .loginAddress))
    //        self.lockScreenView.viewModel.shouldShowQR = false
    //    }
    //
    //    private var isWalletDisabled: Bool {
    //        guard let walletManager = walletManager else { return false }
    //        let now = Date().timeIntervalSince1970
    //        return walletManager.walletDisabledUntil > now
    //    }
    //
        @objc private func unlock() {
            delegate?.didUnlock()
            unlockTimer?.invalidate()
            unlockTimer = nil
        }

    @available(*, unavailable)
    @MainActor dynamic required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
