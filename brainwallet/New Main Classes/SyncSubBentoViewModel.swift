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

class SyncSubBentoViewModel: ObservableObject, Subscriber {
    // MARK: - Combine Variables

    @Published
    var formattedTimestamp = ""

    @Published
    var blockHeightString = ""

    // MARK: - Public Variables

    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.setLocalizedDateFormatFromTemplate("MMM d, yyyy h a")
        return dateFormatter
    }()

    var isRescanning: Bool = false
    var headerMessage: SyncState = .success
    var userCannotSend: Bool = false
    var dateTimestamp: UInt32 = 0 {
        didSet {
            formattedTimestamp = dateFormatter.string(from: Date(timeIntervalSince1970: Double(dateTimestamp)))
        }
    }

    var store: Store?
    var walletManager: WalletManager?

//    private let dateFormatter: DateFormatter = {
//        let df = DateFormatter()
//        df.setLocalizedDateFormatFromTemplate("MMM d, yyyy h a")
//        return df
//    }()

    var progress: CGFloat = 0.0

//    var progress: CGFloat = 0.0 {
//        didSet {
//            progressView.alpha = 1.0
//            progressView.progress = Float(progress)
//            progressView.setNeedsDisplay()
//        }
//    }

//    var headerMessage: SyncState = .success {
//        didSet {
//            switch headerMessage {
//            case .connecting:
//                headerLabel.text = String(localized: "Connecting...", bundle: .main)
//                headerLabel.textColor = BrainwalletUIColor.warn
//            case .syncing: headerLabel.text = String(localized: "Syncing...", bundle: .main)
//                headerLabel.textColor = BrainwalletUIColor.content
//            case .success:
//                headerLabel.text = ""
//                headerLabel.textColor = BrainwalletUIColor.content
//            }
//            headerLabel.setNeedsDisplay()
//        }
//    }
//
//    var timestamp: UInt32 = 0 {
//        didSet {
//            timestampLabel.text = dateFormatter.string(from: Date(timeIntervalSince1970: Double(timestamp)))
//            timestampLabel.textColor = BrainwalletUIColor.content
//            timestampLabel.setNeedsDisplay()
//        }
//    }
//
//    var blockNumberString = "" {
//        didSet {
//            blockheightLabel.text = blockNumberString
//            blockheightLabel.textColor = BrainwalletUIColor.content
//            blockheightLabel.setNeedsDisplay()
//        }
//    }
//
//    var isRescanning: Bool = false {
//        didSet {
//            if isRescanning {
//                headerLabel.text = String(localized: "Rescanning...", bundle: .main)
//                timestampLabel.text = ""
//                blockheightLabel.text = ""
//                progressView.alpha = 0.0
//                noSendImageView.alpha = 1.0
//            } else {
//                headerLabel.text = ""
//                timestampLabel.text = ""
//                blockheightLabel.text = ""
//                progressView.alpha = 1.0
//                noSendImageView.alpha = 0.0
//            }
//        }
//    }

    init(store: Store? = nil, walletManager: WalletManager? = nil) {
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

        guard let store = self.store else { return }

        store.subscribe(self, selector: { $0.walletState.syncProgress != $1.walletState.syncProgress },
                        callback: { _ in

        })
    }
}
