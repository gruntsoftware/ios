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
    
    func validateLitecoinAddress(_ address: String) -> Bool {
        let trimmedAddress = address.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedAddress.isEmpty else { return false }
        
        // Bech32 validation (native SegWit)
        let bech32Pattern = "^ltc1[qpzry9x8gf2tvdw0s3jn54khce6mua7l]{38,58}$"
        let isBech32Valid = NSPredicate(format: "SELF MATCHES %@", bech32Pattern).evaluate(with: trimmedAddress.lowercased())
        
        // Legacy address validation (P2PKH and P2SH)
        // Uses Base58 character set excluding 0, O, I, l to avoid confusion
        let legacyPattern = "^[LM][1-9A-HJ-NP-Za-km-z]{25,33}$"
        let isLegacyValid = NSPredicate(format: "SELF MATCHES %@", legacyPattern).evaluate(with: trimmedAddress)
       
        let isAddressValid = (isBech32Valid || isLegacyValid)
        return isAddressValid
    }
    
    func validateSendAmount(store: Store) -> Bool {
        let balance = store.state.walletState.balance ?? 0
        let sentAmountUInt64 = UInt64(sendAmountString) ?? 0
        let validAmountStatus = sentAmountUInt64 <= balance
        return validAmountStatus
    }
    
    func validateMemoLength() -> Bool {
        return memo.count <= 255
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

    var fiatDescription: String {
        guard let rate = selectedRate ?? state.currentRate else { return "" }
        guard let string = localFormat.string(from: Double(amount.rawValue) / Double(litoshisPerLitecoin) * rate.rate as NSNumber) else { return "" }
        print("||| fiatDescription \(string)")
        return string
    }

   var litecoinDescription: String {
        var decimal = Decimal(self.amount.rawValue)
        var amount: Decimal = 0.0
        NSDecimalMultiplyByPowerOf10(&amount, &decimal, Int16(-state.maxDigits), .up)
        let number = NSDecimalNumber(decimal: amount)
        guard let string = ltcFormat.string(from: number) else { return "" }
       print("|||  litecoinDescription \(string)")

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

