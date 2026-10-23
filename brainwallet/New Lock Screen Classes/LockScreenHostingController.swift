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
    var userDidPreferDarkMode: ((Bool) -> Void)?
    var shouldSelfDismiss = false
    var delegate: LockScreenHostingDelegate?
    private var unlockTimer: Timer?

    init(store: Store?, walletManager: WalletManager? = nil) {
        guard let validStore = store else {
            preconditionFailure("LockScreenHostingController requires a non-nil store.")
        }

        self.store = validStore
        self.walletManager = walletManager

        viewModel = LockScreenViewModel(store: validStore)
        lockScreenView = LockScreenView(viewModel: viewModel)
        super.init(rootView: lockScreenView)

        viewModel.userSubmittedPIN = { [weak self] enteredPIN in
            self?.authenticate(pin: enteredPIN)
        }

        viewModel.didTapWipeWallet = { [weak self] userWantsToDelete in
             if userWantsToDelete {
                 self?.wipeWallet()
            }
        }
    }

    deinit {
        store.unsubscribe(self)
        unlockTimer?.invalidate()
        unlockTimer = nil
    }

    func walletWiped() {
        viewModel.didCompleteWipingWallet = true
    }

    private func wipeWallet() {
        guard let walletManager = walletManager else {
            viewModel.wipeWalletDidFail = true
            return
        }

        DispatchQueue.walletQueue.async {
            walletManager.peerManager?.disconnect()
            let didWipeWallet = walletManager.wipeWallet(pin: "forceWipe")
            let didDeleteDatabase = walletManager.deleteWalletDatabase(pin: "forceWipe")

            var didWipeKeychainAccess = true
            do {
                try UserDefaults.wipeTrustedNodeKeychain()
                try RemoteConfigHelper.sharedInstance.wipeEnvironmentKeychain()
            } catch let error as NSError {
                debugPrint("Error | wipeWallet: Failed to wipe keychain: \(error.localizedDescription)")
                didWipeKeychainAccess = false
            }

            DispatchQueue.main.async {
                guard didWipeWallet, didDeleteDatabase, didWipeKeychainAccess else {
                    self.viewModel.wipeWalletDidFail = true
                    return
                }

                self.walletWiped()
                self.store.trigger(name: .reinitWalletManager {
                    NotificationCenter.default.post(name: .walletDidWipeNotification, object: nil)
                })
            }
        }
    }

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

    @objc func updateTheme(shouldBeDark: Bool) {
        UserDefaults.userPreferredDarkTheme = shouldBeDark
        NotificationCenter
            .default
            .post(name: .changedThemePreferenceNotification,
                object: nil)
    }

    private var isWalletDisabled: Bool {
        guard let walletManager = walletManager else { return false }
        let now = Date().timeIntervalSince1970
        return walletManager.walletDisabledUntil > now
    }

    @objc private func unlock() {
        delegate?.didUnlock()
        unlockTimer?.invalidate()
        unlockTimer = nil
        
        Analytics.logEvent("did_unlock",
                           parameters: nil)
        
    }

    @available(*, unavailable)
    @MainActor dynamic required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
