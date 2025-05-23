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
    var isOverBalance: Bool = false
    
    @Published
    var totalAmountToSend: String = ""
    
    @Published
    var currencyCodeString: String = ""
    
    @Published
    var currencyLTCTitle: String = ""
    
    @Published
    var sendError: String = ""
    
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
    
        guard let symbol = store.state.currentRate?.currencySymbol else { return }

        currencyCodeString = "\(symbol)"
        
        switch store.state.maxDigits {
        case 2: self.currencyLTCTitle = "mł"
        case 5: self.currencyLTCTitle = "ł"
        case 8: self.currencyLTCTitle = "Ł"
        default: self.currencyLTCTitle = "ł"
        }
    }
    
    func updateAmountValue() {
        if sendAmountString.isNumericWithOptionalDecimal() {
            
            guard let rateValue = store.state.currentRate?.rate else { return }
            guard let symbol = store.state.currentRate?.currencySymbol else { return }
           
            var amountValueUInt64: UInt64 = 0
            if userPrefersToShowLTC {
                let doubleValue = Double(sendAmountString) ?? 0.0
                amountValueUInt64 = UInt64(doubleValue * Double(litoshisPerLitecoin))
                currencyCodeString = "Ł"
            }
            else {
                let doubleValue = Double(sendAmountString) ?? 0.0
                amountValueUInt64 = UInt64((doubleValue / rateValue) * Double(litoshisPerLitecoin))
                currencyCodeString = "\(symbol)"
            }
            updateTotalSendAmountofBalanceAndFees(enteredAmount: amountValueUInt64)
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
    func updateTotalSendAmountofBalanceAndFees(enteredAmount: UInt64?) {

        if let entered = enteredAmount,
           entered > 0
        {
            ///  All values in Litoshis
            let tieredOpsFee = tieredOpsFee(amount: entered)
            let amountAndFees = (entered + tieredOpsFee)
            let networkFee = sender.feeForTx(amount: amountAndFees)
            let serviceAndNetworkFees = tieredOpsFee + networkFee
            let sendAmountInSats = amountAndFees + networkFee
            
            if userPrefersToShowLTC {
                
            ///  All values in LTC
                totalFees = String(format: "Ł %.5f" , Double(serviceAndNetworkFees) / Double(litoshisPerLitecoin))
                totalAmountToSend = String(format: "Ł %.5f" , Double(sendAmountInSats) / Double(litoshisPerLitecoin))
                let balanceInLTC = Double(balance) / Double(litoshisPerLitecoin)
                let totalAmountInLTC = Double(sendAmountInSats) / Double(litoshisPerLitecoin)
                if totalAmountInLTC < balanceInLTC
                {
                    let remaining = balanceInLTC - totalAmountInLTC
                    remainingBalance = String(format: "Ł %.5f" , remaining)
                    isOverBalance = false
                }
                else {
                    remainingBalance = "OVER BALANCE"
                    isOverBalance = true
                }
            }
            else {
                
                guard let rateValue = store.state.currentRate?.rate else { return }
                guard let symbol = store.state.currentRate?.currencySymbol else { return }

            ///  All values in LocalFiat
                totalFees = String(format: "%@ %.2f" , symbol, Double(serviceAndNetworkFees) / Double(litoshisPerLitecoin) * Double(rateValue))
                totalAmountToSend = String(format: "%@ %.2f" , symbol, Double(sendAmountInSats) / Double(litoshisPerLitecoin) * Double(rateValue))
                let balanceInLocalFiat = Double(balance) / Double(litoshisPerLitecoin) * Double(rateValue)
                let totalAmountInLocalFiat = Double(sendAmountInSats) / Double(litoshisPerLitecoin) * Double(rateValue)
                if sendAmountInSats < balance
                {
                    let remaining = balanceInLocalFiat - totalAmountInLocalFiat
                    remainingBalance = String(format: "%@ %.2f" , symbol, remaining)
                    isOverBalance = false
                }
                else {
                    remainingBalance = "OVER BALANCE"
                    isOverBalance = true
                }
            }
        } else {
            totalFees = ""
            totalAmountToSend = ""
            remainingBalance = ""
            isOverBalance = false
        }
    }
    
    
    func sendLTC() {
//        sendAddress
//        totalFees
//        totalAmountToSend
    }
    
}
//if requestAmount == 0 {
//    if let amount = amount {
//        guard sender.createTransaction(amount: amount.rawValue, to: address)
//        else {
//            return showAlert(title: String(localized: "Error", bundle: .main) , message: String(localized: "Could not create transaction.", bundle: .main) , buttonLabel: String(localized: "Ok", bundle: .main))
//        }
//    }
//}
//
//private func send() {
//    guard let rate = store.state.currentRate else { return }
//    guard let feePerKb = walletManager.wallet?.feePerKb else { return }
//
//    sender.send(biometricsMessage: "Authorize this transaction" ,
//                rate: rate,
//                comment: memoCell.textView.text,
//                feePerKb: feePerKb,
//                verifyPinFunction: { [weak self] pinValidationCallback in
//                    self?.presentVerifyPin?("Please enter your PIN to authorize this transaction." ) { [weak self] pin, vc in
//                        if pinValidationCallback(pin) {
//                            vc.dismiss(animated: true, completion: {
//                                self?.parent?.view.isFrameChangeBlocked = false
//                            })
//                            return true
//                        } else {
//                            return false
//                        }
//                    }
//                }, completion: { [weak self] result in
//                    switch result {
//                    case .success:
//                        self?.dismiss(animated: true, completion: {
//                            guard let myself = self else { return }
//                            myself.store.trigger(name: .showStatusBar)
//                            if myself.isPresentedFromLock {
//                                myself.store.trigger(name: .loginFromSend)
//                            }
//                            myself.onPublishSuccess?()
//                        })
//                        self?.saveEvent("send.success")
//                        self?.sendAddressCell.textField.text = ""
//                        self?.memoCell.textView.text = ""
//                        LWAnalytics.logEventWithParameters(itemName: ._20191105_DSL)
//
//                    case let .creationError(message):
//                        self?.showAlert(title: String(localized: "Could not create transaction." , bundle: .main), message: message, buttonLabel:  String(localized: "Ok", bundle: .main))
//                        self?.saveEvent("send.publishFailed", attributes: ["errorMessage": message])
//
//                    case let .publishFailure(error):
//                        if case let .posixError(code, description) = error {
//                            self?.showAlert(title: String(localized: "Send failed", bundle: .main), message: "\(description) (\(code))", buttonLabel: String(localized:  "Ok", bundle: .main))
//                            self?.saveEvent("send.publishFailed", attributes: ["errorMessage": "\(description) (\(code))"])
//                        }
//                    }
//                })
//}
//
//
//
//func createTransactionWithOpsOutputs(amount: UInt64,
//                                     to: String) -> Bool
//{
//    transaction = walletManager.wallet?.createOpsTransaction(forAmount: amount,
//                                                             toAddress: to,
//                                                             opsFee: tieredOpsFee(amount: amount),
//                                                             opsAddress: Partner.partnerKeyPath(name: .walletOps))
//
//    return transaction != nil
//}
//
//func feeForTx(amount: UInt64) -> UInt64 {
//    return walletManager.wallet?.feeForTx(amount: amount) ?? 0
//}
