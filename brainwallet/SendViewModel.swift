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
    var networkFees: String = ""
    
    @Published
    var serviceFees: String = ""
    
    @Published
    var totalAmountToSend: String = ""
    
    @Published
    var currencyCodeString: String = "USD ($)"
    
    @Published
    var currencyLTCTitle: String = ""
    
    
    @Published
    var userPrefersShowLTC: Bool = false
    
    var newAmount: Satoshis?
    var balanceTextForAmount: ((Satoshis?, Rate?) -> (NSAttributedString?, NSAttributedString?)?)?
    
//    enteredAmount, rate in
//        self?.balanceTextForAmountWithFormattedFees(enteredAmount: enteredAmount, rate: rate)
//    }
    
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
        
        setCurrencySwitchTitles()
    }
    
    private func setCurrencySwitchTitles() {
        
        guard let currentCode = store.state.currentRate?.code else { return }
        guard let symbol = store.state.currentRate?.currencySymbol else { return }

        currencyCodeString = "\(currentCode) (\(symbol))"
        
        switch store.state.maxDigits {
        case 2: self.currencyLTCTitle = "photons (mł)"
        case 5: self.currencyLTCTitle = "lites (ł)"
        case 8: self.currencyLTCTitle = "LTC (Ł)"
        default: self.currencyLTCTitle = "lites (ł)"
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
    
    
    /// Description: Recalculated the send amount based on network and service fees
    /// - Parameters:
    ///   - enteredAmount: UInt64 value in Litoshis
    ///   - rate: Rate
    /// - Returns: Tuple (String? , String?)
    private func fetchTotalSendAmountofBalanceAndFees(enteredAmount: Litoshis?) -> (String?, String?) {

        let balanceAmount = FormattedLTCAmount(amount: Litoshis(rawValue: balance),
                                          state: store.state,
                                          selectedRate: store.state.currentRate,
                                          minimumFractionDigits: 2)
        
        let balanceText = balanceAmount.description
        let balanceOutput = String(format: "Balance: %1$@" , balanceText)
        var combinedFeesOutput = ""
        
        if let currentRate = store.state.currentRate,
           let enteredAmount = enteredAmount,
           enteredAmount > 0
        {
            let tieredOpsFee = tieredOpsFee(amount: enteredAmount.rawValue)

            let totalAmountToCalculateFees = (enteredAmount.rawValue + tieredOpsFee)

            let networkFee = sender.feeForTx(amount: totalAmountToCalculateFees)
            let totalFees = (networkFee + tieredOpsFee)
            let sendTotal = balance + totalFees
            let networkFeeAmount = FormattedLTCAmount(amount:Litoshis(rawValue: networkFee),
                                              state: store.state,
                                              selectedRate: store.state.currentRate,
                               minimumFractionDigits: 2).description

            let serviceFeeAmount = FormattedLTCAmount(amount:Litoshis(rawValue: tieredOpsFee),
                                                      state: store.state,
                                                      selectedRate: store.state.currentRate,
                                       minimumFractionDigits: 2).description
            

            let totalFeeAmount = FormattedLTCAmount(amount:Litoshis(rawValue: networkFee + tieredOpsFee),
                                                    state: store.state,
                                                    selectedRate: store.state.currentRate,
                                     minimumFractionDigits: 2).description
            
            let combinedFeesOutput = String(
                format: String(localized: "(Network fee + Service fee):", bundle: .main),
                networkFeeAmount,
                serviceFeeAmount,
                totalFeeAmount
            )
        }
        return ( balanceOutput, combinedFeesOutput)
    }
    
    
    
        
  
//    private func balanceTextForAmountWithFormattedFees(enteredAmount: Satoshis?, rate: Rate?) -> (NSAttributedString?, NSAttributedString?) {
//        var currentRate  = store.state.currentRate
//
//        let balanceAmount = DisplayAmount(amount: Satoshis(rawValue: balance),
//                                          state: store.state,
//                                          selectedRate: currentRate,
//                                          minimumFractionDigits: 2)
//
//        let balanceText = balanceAmount.description
//
//        let balanceOutput = String(format: "Balance: %1$@" , balanceText)
//        var combinedFeesOutput = ""
//        var balanceColor: UIColor = BrainwalletUIColor.content
//
//        /// Check the amount is greater than zero and amount satoshis are not nil
//        if let currentRate = currentRate,
//           let enteredAmount = enteredAmount,
//           enteredAmount > 0
//        {
//            let tieredOpsFee = tieredOpsFee(amount: enteredAmount.rawValue)
//
//            let totalAmountToCalculateFees = (enteredAmount.rawValue + tieredOpsFee)
//
//            let networkFee = sender.feeForTx(amount: totalAmountToCalculateFees)
//            let totalFees = (networkFee + tieredOpsFee)
//            let sendTotal = balance + totalFees
//            let networkFeeAmount = DisplayAmount(amount: Satoshis(rawValue: networkFee),
//                                                 state: store.state,
//                                                 selectedRate: currentRate,
//                                                 minimumFractionDigits: 2).description
//
//            let serviceFeeAmount = DisplayAmount(amount: Satoshis(rawValue: tieredOpsFee),
//                                                 state: store.state,
//                                                 selectedRate: currentRate,
//                                                 minimumFractionDigits: 2).description
//
//            let totalFeeAmount = DisplayAmount(amount: Satoshis(rawValue: networkFee + tieredOpsFee),
//                                               state: store.state,
//                                               selectedRate: currentRate,
//                                               minimumFractionDigits: 2).description
//            
//            let combinedFeesOutput = String(
//                format: String(localized: "(Network fee + Service fee):", bundle: .main),
//                networkFeeAmount,
//                serviceFeeAmount,
//                totalFeeAmount
//            )
//            
//            if sendTotal > balance {
//                balanceColor = BrainwalletUIColor.error
//            }
//            else {
//                balanceColor = BrainwalletUIColor.content
//            }
//        }
//
//        let balanceStyle = [
//            NSAttributedString.Key.font: UIFont.customBody(size: 14.0),
//            NSAttributedString.Key.foregroundColor: balanceColor
//        ]
//
//        return (NSAttributedString(string: balanceOutput, attributes: balanceStyle), NSAttributedString(string: combinedFeesOutput, attributes: balanceStyle))
//    }

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

 
