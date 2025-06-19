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

    let currencies: [SupportedFiatCurrency] = SupportedFiatCurrency.allCases

    init(store: Store, walletManager: WalletManager) {
        self.store = store
        self.walletManager = walletManager
        setSubscriptions()
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
    private func setSubscriptions() {
        self.store.subscribe(self, selector: { $0.walletState.syncProgress != $1.walletState.syncProgress },
                        callback: { _ in

        })
    }
}
