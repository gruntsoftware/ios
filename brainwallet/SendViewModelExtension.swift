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

struct FormattedLTCAmount {
    let amount: Litoshis
    let state: ReduxState
    let selectedRate: Rate?
    let minimumFractionDigits: Int?

    var description: String {
        return selectedRate != nil ? fiatDescription : litecoinDescription
    }

    var combinedDescription: String {
        return state.isLtcSwapped ? "\(fiatDescription) (\(litecoinDescription))" : "\(litecoinDescription) (\(fiatDescription))"
    }

    private var fiatDescription: String {
        guard let rate = selectedRate ?? state.currentRate else { return "" }
        guard let string = localFormat.string(from: Double(amount.rawValue) / Double(litoshisPerLitecoin) * rate.rate as NSNumber) else { return "" }
        return string
    }

    private var litecoinDescription: String {
        var decimal = Decimal(self.amount.rawValue)
        var amount: Decimal = 0.0
        NSDecimalMultiplyByPowerOf10(&amount, &decimal, Int16(-state.maxDigits), .up)
        let number = NSDecimalNumber(decimal: amount)
        guard let string = ltcFormat.string(from: number) else { return "" }
        return string
    }

    var localFormat: NumberFormatter {
        let format = NumberFormatter()
        format.isLenient = true
        format.numberStyle = .currency
        format.generatesDecimalNumbers = true
        format.negativePrefix = "-"
        if let rate = selectedRate {
            format.currencySymbol = rate.currencySymbol
        } else if let rate = state.currentRate {
            format.currencySymbol = rate.currencySymbol
        }
        if let minimumFractionDigits = minimumFractionDigits {
            format.minimumFractionDigits = minimumFractionDigits
        }
        return format
    }

    var ltcFormat: NumberFormatter {
        let format = NumberFormatter()
        format.isLenient = true
        format.numberStyle = .currency
        format.generatesDecimalNumbers = true
        format.negativePrefix = "-"
        format.currencyCode = "LTC"

        switch state.maxDigits {
        case 2:
            format.currencySymbol = "mł  "
            format.maximum = NSNumber(value: (maximumLitoshis / litoshisPerLitecoin) * 100_000)
        case 5:
            format.currencySymbol = "ł  "
            format.maximum = NSNumber(value: (maximumLitoshis / litoshisPerLitecoin) * 1000)
        case 8:
            format.currencySymbol = "Ł "
            format.maximum = NSNumber(value: maximumLitoshis / litoshisPerLitecoin)
        default:
            format.currencySymbol = "ł  "
        }

        format.maximumFractionDigits = state.maxDigits
        if let minimumFractionDigits = minimumFractionDigits {
            format.minimumFractionDigits = minimumFractionDigits
        }
        format.maximum = NSDecimalNumber(decimal: Decimal(maximumLitoshis) / pow(10 as Decimal, state.maxDigits))

        return format
    }
}

