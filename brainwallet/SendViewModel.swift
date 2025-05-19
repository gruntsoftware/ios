//
//  SendViewModel.swift
//  brainwallet
//
//  Created by Kerry Washington on 17/05/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//
 
import Foundation
import SwiftUI
import BRCore
import FirebaseAnalytics
import KeychainAccess
//import LocalAuthentication
import SwiftUI
//import UIKit


class SendViewModel: ObservableObject, Subscriber {
    // MARK: - Combine Variables
    @Published
    var sendAddress: String = ""
    
    @Published
    var sendAmount: Double = 0.0

    @Published
    var memo: String = ""
    
    @Published
    var currencyButtonTitle: String = ""
      
    let store: Store
    let sender: Sender
    let walletManager: WalletManager
    private var balance: UInt64 = 0
    private var amount: Satoshis?
    var initialAddress: String?
    private let initialRequest: PaymentRequest?
    private var feeType: FeeType?


    init(store: Store, sender: Sender, walletManager: WalletManager, initialAddress: String? = nil, initialRequest: PaymentRequest? = nil) {
        self.store = store
        self.sender = sender
        self.walletManager = walletManager
        self.initialAddress = initialAddress
        self.initialRequest = initialRequest
        
        currencyButtonTitle = ""
        switch store.state.maxDigits {
        case 2: currencyButtonTitle = "photons (mł)"
        case 5: currencyButtonTitle = "lites (ł)"
        case 8: currencyButtonTitle = "LTC (Ł)"
        default: currencyButtonTitle = "lites (ł)"
        }
    }
    
    func userDidTapPaste() {
        if let pasteboard = UIPasteboard.general.string, !pasteboard.utf8.isEmpty {
            sendAddress = pasteboard
        }
        else {
            sendAddress = ""
        }
    }
}

/////ViewModel Candidates
//private let keyValueStore: BRReplicatedKVStore
//private var feeType: FeeType?
//private let initialRequest: PaymentRequest
////    private var balance: UInt64 = 0
////    private var amount: Satoshis?
////    self.initialRequest = initialRequest
////
////    initialAddress: String? = nil,
////    initialRequest: PaymentRequest? = nil

 
