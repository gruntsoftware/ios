//
//  BentoSendPrepView.swift
//  brainwallet
//
//  Created by Kerry Washington on 03/05/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

import SwiftUI
import CoreHaptics
import Foundation
import UIKit
import FirebaseAnalytics

struct BentoSendConfirmView: View {

    enum TransactionCreationError: Error {
        case invalidLTCAddress
        case insufficientFunds
    }

    @Environment(\.requestReview)
    private var requestReview

    @ObservedObject
    var viewModel: SendPinLockModel

    @ObservedObject
    var newMainViewModel: NewMainViewModel

    @State
    private var startShake = false

    @State
    private var pinState: [Bool] = [false,false,false,false]

    @State
    private var pinDigits: [Int] = []

    @State
    private var didFillPIN: Bool = false

    @Binding
    var userPrefersDarkTheme: Bool

    @Binding
    var nextIndex: Int

    @Binding
    var shouldDismiss: Bool

    init(viewModel: SendPinLockModel,
         newMainViewModel: NewMainViewModel,
         userPrefersDarkTheme: Binding<Bool>,
         nextIndex: Binding<Int>,
         shouldDismiss: Binding<Bool>) {
        self.viewModel = viewModel
        self.newMainViewModel = newMainViewModel
        _userPrefersDarkTheme = userPrefersDarkTheme
        _nextIndex = nextIndex
        _shouldDismiss = shouldDismiss
    }

    func clearPINSettings() {
        /// Resetting for another attempt
        self.pinDigits = []
        self.pinState = [false,false,false,false]
        viewModel.authenticationFailed = true
        viewModel.pinDigits = []
    }

        var body: some View {

            GeometryReader { geometry in

                let width = geometry.size.width
                let height = geometry.size.height

                ZStack {
                    BrainwalletColor.surface.edgesIgnoringSafeArea(.all)

                    VStack {
                        Text(String(localized: "Enter PIN"))
                            .modifier(BWIPSBold(size: 24.0))
                            .foregroundColor(userPrefersDarkTheme ? .white : .black)
                            .frame(width: width, height: 30.0, alignment: .top)
                            .padding([.top, .bottom], 8.0)

                        PINRowView(pinState: $pinState)
                            .frame(width: 180, height: 30.0)
                            .offset(x: startShake ? 7 : 0)
                            .animation(.spring(response: 0.15, dampingFraction: 0.1, blendDuration: 0.2), value: startShake)
                            .padding(20.0)

                        PasscodeGridView(digits: $pinDigits,
                                         userPrefersDarkMode: $userPrefersDarkTheme)
                        .frame(width: width * 0.6, height: height * 0.5, alignment: .center)
                        .padding(15.0)

                    }
                    .onChange(of: pinDigits) { _,_ in

                        pinState = (0..<4).map { $0 < pinDigits.count }

                        didFillPIN  = pinState.allSatisfy { $0 == true }
                        let pinString = pinDigits.map(String.init).joined()

                        if didFillPIN {
                            viewModel.pinDigits = pinDigits
                            debugPrint("didVerifyPin pre: \(viewModel.pinDigits)\n")

                            if viewModel.didVerifyPin() {
                                debugPrint("didVerifyPin post: \(viewModel.pinDigits)\n")

                                var transactionError: TransactionCreationError?
                                let biometricsMessage = "Authorize this transaction"
                                /// Setup  Transaction
                                if let sender = newMainViewModel.sender,
                                   let walletManager = newMainViewModel.walletManager {
                                    let totalAmount = newMainViewModel.currentPreFeeAmount
                                    let amountInLitoshis = UInt64(totalAmount.rawValue * 100_000_000)
                                    let opsFeeAmount = tieredOpsFee(amount: amountInLitoshis)
                                    guard let networkFee = walletManager.wallet?.feeForTx(amount: amountInLitoshis + opsFeeAmount) else { return }

                                    /// Created transaction
                                    _ = sender.createTransactionWithOpsOutputs(amount: amountInLitoshis, to: newMainViewModel.currentSendAddress)

                                    /// Created transaction
                                    sender.send(biometricsMessage: biometricsMessage,
                                                rate:  newMainViewModel.exchangeRate,
                                                memoString: newMainViewModel.currentMemoString,
                                                feePerKb: networkFee,
                                                pinCode: pinString, completion: { result in

                                        switch result {
                                        case .success:
                                            if let txID = sender.transaction?.pointee.txHash.description {
                                                newMainViewModel.bwTransaction.txIDString = txID
                                                delay(0.5) {
                                                    shouldDismiss.toggle()
                                                    nextIndex = 2
                                                    requestReview()
                                                    Analytics
                                                        .logEvent("did_request_rating",
                                                                  parameters: [
                                                                    "platform": "ios",
                                                                    "app_version": AppVersion.string,
                                                                    "request_placement": String(describing: type(of: BentoSendConfirmView.self))
                                                                  ])
                                                }
                                            }
                                            case .creationError:
                                            Analytics
                                                .logEvent("error_message",
                                                          parameters: [
                                                            "platform": "ios",
                                                            "transaction_failure" : "transaction_creation_failed",
                                                            "app_version": AppVersion.string ])

                                            case .publishFailure:
                                            Analytics
                                                .logEvent("error_message",
                                                               parameters: [
                                                                "platform": "ios",
                                                                "transaction_failure" : "transaction_publish_failed",
                                                                "app_version": AppVersion.string ])
                                        }
                                    })

                                } else {
                                    transactionError = .invalidLTCAddress
                                    clearPINSettings()
                                }

                            } else {
                                clearPINSettings()
                            }
                        }
                    }
                    .onChange(of: viewModel.authenticationFailed) { _,didFailAuthentication in
                        if didFailAuthentication {
                            startShake.toggle()
                            let generator = UINotificationFeedbackGenerator()
                            generator.notificationOccurred(.error)

                            delay(0.4) {
                                clearPINSettings()
                                startShake.toggle()
                            }
                        }
                    }
                }
                .onDisappear {
                    clearPINSettings()
                }
            }
        }
    }
