//
//  NewSyncProgressViewModel.swift
//  brainwallet
//
//  Created by Kerry Washington on 27/05/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

import AVFoundation
import Foundation
import SwiftUI
import UIKit

class NewSyncProgressViewModel: ObservableObject, Subscriber {
    // MARK: - Combine Variables

    @Published
    var formattedTimestamp = ""
    
    @Published
    var blockHeightString = "--"

    // MARK: - Public Variables

    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.setLocalizedDateFormatFromTemplate("MMM d, yyyy h a")
        return df
    }()
    
    var isRescanning: Bool = false
    var headerMessage: SyncState = .success
    var progress: CGFloat = 0.0
    var userCannotSend: Bool = false
    var dateTimestamp: UInt32 = 0 {
        didSet {
            formattedTimestamp = dateFormatter.string(from: Date(timeIntervalSince1970: Double(dateTimestamp)))
        }
    }
    
    var store: Store
    var walletManager: WalletManager
    
    let currencies: [SupportedFiatCurrencies] = SupportedFiatCurrencies.allCases

    init(store: Store, walletManager: WalletManager) {
        self.store = store
        self.walletManager = walletManager
        setSubscriptions()
    }

///    dateFormatter.string(from: Date(timeIntervalSince1970: Double(timestamp)))

    /// DEV: For checking wallet
//    private func checkForWalletAndSync() {
//        /// Test seed count
//        guard seedWords.count == 12 else { return }
//
//        /// Set for default.  This model needs a initial value
//        walletManager.forceSetPin(newPin: Partner.partnerKeyPath(name: .brainwalletStart))
//
//        guard walletManager.setRandomSeedPhrase() != nil else {
//            walletCreationDidFail = true
//            let properties = ["error_message": "wallet_creation_fail"]
//            LWAnalytics.logEventWithParameters(itemName: ._20200112_ERR, properties: properties)
//            return
//        }
//
//        store.perform(action: WalletChange.setWalletCreationDate(Date()))
//        DispatchQueue.walletQueue.async {
//            self.walletManager.peerManager?.connect()
//            DispatchQueue.main.async {
//                self.store.trigger(name: .didCreateOrRecoverWallet)
//            }
//        }
//    }
    
    func setCurrency(code: String) {
        UserDefaults.defaultCurrencyCode = code
        UserDefaults.standard.synchronize()
        Bundle.setLanguage(code)

        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .preferredCurrencyChangedNotification,
                                            object: nil,
                                            userInfo: nil)
        }
    }
    private func setSubscriptions() {
        
    }
}
