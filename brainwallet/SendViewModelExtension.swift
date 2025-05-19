//
//  SendViewModelExtension.swift
//  brainwallet
//
//  Created by Kerry Washington on 19/05/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//
import Foundation
import SwiftUI

extension SendViewModel {
    
    func validateSendAddress() -> Bool {
        let isSegwitValid = NSPredicate(format: "SELF MATCHES %@", "^ltc1[0-9a-z]{39,59}$").evaluate(with: sendAddress.lowercased())
        let isLTCValid = NSPredicate(format: "SELF MATCHES %@", "^[LM][a-zA-Z0-9]{26,33}$").evaluate(with: sendAddress)
         
        let validAddtressStatus = isSegwitValid || isLTCValid
        return validAddtressStatus
    }
    
    func validateSendAddressWith(address: String) -> Bool {
        let isSegwitValid = NSPredicate(format: "SELF MATCHES %@", "^ltc1[0-9a-z]{39,59}$").evaluate(with: address.lowercased())
        let isLTCValid = NSPredicate(format: "SELF MATCHES %@", "^[LM][a-zA-Z0-9]{26,33}$").evaluate(with: address)
        
        let validAddtressStatus = isSegwitValid || isLTCValid
        return validAddtressStatus
    }
    
    func validateSendAmount(store: Store) -> Bool {
        let balance = store.state.walletState.balance ?? 0
        let validAmountStatus = UInt64(sendAmount) <= balance
        return validAmountStatus
    }
    
    func validateMemoLength() -> Bool {
        return memo.count <= 255
    }
    
    func validateSendData(store: Store) -> Bool {
        return validateSendAmount(store: store) && validateSendAddress() && validateMemoLength()
    }
}

