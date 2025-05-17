//
//  SendViewModel.swift
//  brainwallet
//
//  Created by Kerry Washington on 17/05/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//
 
import AVFoundation
import Foundation
import SwiftUI
import UIKit
 
class SendViewModel: ObservableObject, Subscriber {
    // MARK: - Combine Variables
    @Published
    var sendAddress: String = ""
    
    @Published
    var sendAmount: Double = 0.0

    @Published
    var memo: String = ""
      
    var store: Store?

    init(store: Store) {
        self.store = store
    }
    
    func userDidTapPaste() {
        if let pasteboard = UIPasteboard.general.string, !pasteboard.utf8.isEmpty {
            sendAddress = pasteboard
        }
        else {
            sendAddress = ""
        }
    }
    
    func validateSendAddress() -> Bool {
        let isSegwitValid = NSPredicate(format: "SELF MATCHES %@", "^ltc1[0-9a-z]{39,59}$").evaluate(with: sendAddress.lowercased())
        let isLTCValid = NSPredicate(format: "SELF MATCHES %@", "^L[a-zA-Z0-9]{26,33}$").evaluate(with: sendAddress)
        
        let validAddtressStatus = isSegwitValid || isLTCValid
        return validAddtressStatus
    }
    
    func validateSendAddressWith(address: String) -> Bool {
        let isSegwitValid = NSPredicate(format: "SELF MATCHES %@", "^ltc1[0-9a-z]{39,59}$").evaluate(with: address.lowercased())
        let isLTCValid = NSPredicate(format: "SELF MATCHES %@", "^L[a-zA-Z0-9]{26,33}$").evaluate(with: address)
        
        let validAddtressStatus = isSegwitValid || isLTCValid
        return validAddtressStatus
    }
    
    func validateSendAmount() -> Bool {
        guard let balance = store?.state.walletState.balance else { return false }
        let validAmountStatus = UInt64(sendAmount) <= balance
        return validAmountStatus
    }
    
    func validateMemoLength() -> Bool {
        return memo.count <= 255
    }
    
    func validateSendData() -> Bool {
        let validStatus = validateSendAmount() && validateSendAddress() && validateMemoLength()
        return validStatus
    }
}
