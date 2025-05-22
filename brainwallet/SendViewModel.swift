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
    var sendAmountString: String = ""

    @Published
    var memo: String = ""
    
    @Published
    var totalFees: String = ""
    
    @Published
    var remainingBalance: String = ""
    
    @Published
    var totalAmountToSend: String = ""
    
    @Published
    var currencyCodeString: String = "USD($)"
    
    @Published
    var currencyLTCTitle: String = ""
    
    @Published
    var userPrefersToShowLTC: Bool = false
     
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
        self.balance = self.walletManager.wallet?.balance ?? 0
        setCurrencySwitchTitles()
        
        store.subscribe(self, selector: { $0.walletState.balance != $1.walletState.balance },
                        callback: {
                            if let balance = $0.walletState.balance {
                                self.balance = balance
                            }
                        })
    }
    
    deinit {
        store.unsubscribe(self)
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setCurrencySwitchTitles() {
        
        guard let currentCode = store.state.currentRate?.code else { return }
        guard let symbol = store.state.currentRate?.currencySymbol else { return }

        currencyCodeString = "\(currentCode) (\(symbol))"
        
        switch store.state.maxDigits {
        case 2: self.currencyLTCTitle = "mł"
        case 5: self.currencyLTCTitle = "ł"
        case 8: self.currencyLTCTitle = "Ł"
        default: self.currencyLTCTitle = "ł"
        }
    }
    
    func updateAmountValue() {
        if sendAmountString.isNumericWithOptionalDecimal() {
            
            //convert string to uint64
            guard let amountValueUInt64 = UInt64(sendAmountString) else { return }
            
            // Update fees string
            updateTotalSendAmountofBalanceAndFees(enteredAmount: Litoshis(amountValueUInt64))
        }
        else {
            sendAmountString = ""
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
    ///  - Updates  totalFees
    ///  - Updates  remainingBalance
    ///  - Updates  totalAmountToSend
    /// - Returns: Void
    func updateTotalSendAmountofBalanceAndFees(enteredAmount: Litoshis?) {

        if let enteredAmount = enteredAmount,
           enteredAmount > 0
        {
            ///  All values in Litoshis
            let tieredOpsFee = tieredOpsFee(amount: enteredAmount.rawValue)
            let amountAndFees = (enteredAmount.rawValue + tieredOpsFee)
            let networkFee = sender.feeForTx(amount: amountAndFees)
            let sendAmountInSats = amountAndFees + networkFee
            
            if userPrefersToShowLTC {
                
            ///  All values in LTC
            let tieredOpsFeeInLTC = Double(tieredOpsFee / litoshisPerLitecoin)
            let amountAndFeesInLTC  = amountAndFees / litoshisPerLitecoin
            let networkFeeInLTC  = networkFee / litoshisPerLitecoin
            let sendAmountInSatsInLTC  = sendAmountInSats / litoshisPerLitecoin
                print("||| \(tieredOpsFeeInLTC)" + "\(amountAndFeesInLTC)" + "\(networkFeeInLTC)" + "\(sendAmountInSatsInLTC)")
                totalFees = "\(tieredOpsFeeInLTC)" + "\(amountAndFeesInLTC)" + "\(networkFeeInLTC)" + "\(sendAmountInSatsInLTC)"
                
                if sendAmountInSats < balance {
//                    remainingBalance =
//                    remainingBalance = String(format: "Remaining balance: %1$@" , remainingBalance)
                }
                else {
                    remainingBalance = "OVER BALANCE"
                }
            }
            else {
                
                guard let rateValue = store.state.currentRate?.rate else { return }

            ///  All values in LocalFiat
            let tieredOpsFeeInLocalFiat = Double(tieredOpsFee / litoshisPerLitecoin) * Double(rateValue)
            let amountAndFeesInLocalFiat = Double(amountAndFees / litoshisPerLitecoin) * Double(rateValue)
            let networkFeeInLocalFiat = Double(networkFee / litoshisPerLitecoin) * Double(rateValue)
            let sendAmountInSatsInLocalFiat = Double(sendAmountInSats / litoshisPerLitecoin) * Double(rateValue)
                
                
                totalFees = ""
                print("||| \(tieredOpsFeeInLocalFiat)" + "\(amountAndFeesInLocalFiat)" + "\(networkFeeInLocalFiat)" + "\(sendAmountInSatsInLocalFiat)")
                
                if sendAmountInSats < balance {
//                    remainingBalance =
//                    remainingBalance = String(format: "Remaining balance: %1$@" , remainingBalance)
                }
                else {
                    remainingBalance = "OVER BALANCE"
                }
            }
        }
    }
    
}
