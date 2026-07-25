//
//  SyncSubBentoViewModel.swift
//  brainwallet
//
//  Created by Kerry Washington on 27/10/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

import AVFoundation
import Foundation
import SwiftUI
import UIKit
import FirebaseAnalytics

let kTodaysEpochTime: TimeInterval = Date().timeIntervalSince1970

class SyncSubBentoViewModel: ObservableObject, Subscriber {
    // MARK: - Combine Variables

    @Published
    var formattedTimestamp = ""

    @Published
    var lastFoundBlockHeightString = ""

    @Published
    var currentBlockHeightString = ""

    @Published
    var currentBlockHeight: UInt32 = 0

    @Published
    var syncStartTime = Date()

    @Published
    var isSyncing: Bool = false

    @Published
    var currentPromptType: PromptType = .noPrompt

    @Published
    var progress: CGFloat = 0.0

    @Published
    var isRescanning: Bool = false

    @Published
    var syncStateMessage = ""

    @Published
    var syncStateMessageColor: Color = BrainwalletColor.content

    @Published
    var syncState: SyncState = .success {
        didSet {
              switch syncState {
                 case .connecting:
                  syncStateMessage = String(localized: "Connecting...")
                  syncStateMessageColor = BrainwalletColor.warn
                case .syncing:
                  syncStateMessage = String(localized: "Syncing...")
                  syncStateMessageColor = BrainwalletColor.content
                        case .success:
                  syncStateMessage = ""
                  syncStateMessageColor = BrainwalletColor.content
                }
        }
    }

    @Published
    var dateTimestamp: UInt32 = 0 {
        didSet {
            formattedTimestamp = dateFormatter.string(from: Date(timeIntervalSince1970: Double(dateTimestamp)))
        }
    }

    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate("MMM dd, yyyy hh:mm a")
        return dateFormatter
    }()

    var userCannotSend: Bool = false

    var store: Store?
    var walletManager: WalletManager?

    init(store: Store? = nil, walletManager: WalletManager? = nil) {
        self.store = store
        self.walletManager = walletManager
        addSubscriptions()
    }

    func setCurrency(code: String) {
        UserDefaults.userPreferredCurrencyCode = code
        UserDefaults.standard.synchronize()
        Bundle.setLanguage(code)

        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .preferredCurrencyChangedNotification,
                                            object: nil,
                                            userInfo: nil)
        }
    }

    // MARK: - Prompt Types / Methods

    @objc
    private func userTappedPromptClose() {
        /// do close
        self.currentPromptType = .noPrompt
    }

    @objc
    private func userTappedPromptContinue() {
        /// do continue
         if let store = self.store,
            let trigger = currentPromptType.trigger {
                store.trigger(name: trigger)
            }

        self.currentPromptType = .noPrompt
    }

    private func attemptShowPrompt() {
        guard let walletManager = walletManager,
        let store = store else {
            NSLog("::: ERROR: WalletManager or Store not initialized")
            return
        }

        let types = PromptType.defaultOrder
        if let type = types.first(where: { $0.shouldPrompt(walletManager: walletManager, state: store.state) }) {
            currentPromptType = type

//            switch type {
//            case .biometrics:
//
//            case .shareData:
//
//            case .paperKey:
//                <#code#>
//            case .noPasscode:
//                <#code#>
//            case .upgradePin:
//                <#code#>
//            case .recommendRescan:
//                <#code#>
//            case .noPrompt:
//                <#code#>
//            }

            if type == .biometrics {
                UserDefaults.hasPromptedBiometrics = true
            }
            if type == .shareData {
                UserDefaults.hasPromptedShareData = true
            }
        } else {
            currentPromptType = .noPrompt
        }
    }
    // MARK: - Subscription Methods

    private func addSubscriptions() {
        guard let store = store
        else {
            NSLog("::: ERROR: Store not initialized")
            return
        }

        // MARK: - Wallet State:  Sync Progress

        store.subscribe(
        self,
        selector: { $0.walletState.lastBlockTimestamp != $1.walletState.lastBlockTimestamp },
        callback: { [weak self] reduxState in
            guard let self = self else { return }

            let walletState = reduxState.walletState

            // Debug logging 

            self.isRescanning = walletState.isRescanning

            let isSyncing = self.isRescanning || walletState.syncState == .syncing

            if isSyncing {
                self.progress = CGFloat(walletState.syncProgress)
                self.syncState = walletState.syncState
                self.dateTimestamp = walletState.lastBlockTimestamp
                self.lastFoundBlockHeightString = walletState.transactions.first?.blockHeight ?? " -- "
                self.isSyncing = true

                // Check if sync is complete
                if walletState.syncProgress >= 0.999 {
                    self.isSyncing = false
                    Analytics.logEvent("user_did_complete_sync",
                                  parameters: nil)
                }
            }
        }
        )
        // MARK: - Wallet State:  Sync State

        store.subscribe(self, selector: { $0.walletState.syncState != $1.walletState.syncState },
                        callback: { [self] reduxState in

                            guard let peerManager = self.walletManager?.peerManager
                            else {
                                return
                            }

                            if reduxState.walletState.syncState == .syncing {
                                self.isSyncing = true

                                self.currentBlockHeightString = "\(peerManager.lastBlockHeight)"

                                self.currentBlockHeight = peerManager.lastBlockHeight
                            }

                            if reduxState.walletState.syncState == .success {
                                self.isSyncing = false
                            }

                        })

        // MARK: - Subscription:  Recommend Rescan

        store.subscribe(self, selector: { $0.recommendRescan != $1.recommendRescan },
                        callback: { [weak self] _ in
            self?.attemptShowPrompt()
        })

        // MARK: - Subscription:  Did Upgrade PIN

        store.subscribe(self, triggerName: .didUpgradePin, callback: { [weak self] triggerName in

            print(":::\(String(describing: triggerName))")
            if self?.currentPromptType == .upgradePin {
                self?.currentPromptType = .noPrompt
            }
        })

        // MARK: - Subscription:  Did Enable Share Data

        store.subscribe(self, triggerName: .didEnableShareData, callback: { [weak self] _ in
            if self?.currentPromptType == .shareData {
                self?.currentPromptType = .noPrompt
            }
        })

        // MARK: - Subscription:  Did Write Paper Key

        store.subscribe(self, triggerName: .didWritePaperKey, callback: { [weak self] _ in
            if self?.currentPromptType == .paperKey {
                self?.currentPromptType = .noPrompt
            }
        })

        // MARK: - Subscription:  Memo Updated

        store.subscribe(self, triggerName: .txMemoUpdated(""), callback: { [weak self] _ in

            if self?.currentPromptType == .paperKey {
                self?.currentPromptType = .noPrompt
            }
//            guard let trigger = triggerName else { return }
//
//            if case let .txMemoUpdated(txHash) = trigger {
//                self?.updateTransactions(txHash: txHash)
//            }
        })
    }
}
