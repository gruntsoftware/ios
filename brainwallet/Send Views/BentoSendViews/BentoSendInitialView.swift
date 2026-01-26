//
//  BentoSendInitialView.swift
//  brainwallet
//
//  Created by Kerry Washington on 03/05/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

import SwiftUI

struct BentoSendInitialView: View {

    enum SendField {
       case addressField
       case amountField
       case memoField
    }

    @ObservedObject
    var newMainViewModel: NewMainViewModel

    @Binding
    var userPrefersDarkTheme: Bool

    @Binding
    var userWalletIsEmpty: Bool

    @Binding
    var shouldShowView: Bool

    @Binding
    var currentIndex: Int

    @State
    private var shouldShowEmptyWalletAlert: Bool = false

    @State
    private var sendLTCAddress: String = ""

    @State
    private var sendAmount: Double = 0.0

    @State
    private var sentTextColor: Color = .black

    @State
    private var continueTextColor: Color = .black

    @State
    private var sendMemo: String = ""

    @State
    private var didTapPaste = false

    @State
    private var didTapScan = false

    @State
    private var isLTCValueShown = false

    @State
    private var isValidAddress = false

    @State
    private var shouldShowError = false

    @State
    private var errorMessage = ""

    @State
    private var isAmountValid = false

    @State
    private var isReadyToSend: Bool = false

    @State
    private var pasteboardString = ""

    @State
    private var scannedText = ""

    @State
    private var bwTransaction = BWTransaction()

    @FocusState
    private var focusedField: SendField?

    @State
    private var backgroundColor: LinearGradient = LinearGradient(colors: [.white], startPoint: .topLeading,
                                                                 endPoint: .bottomTrailing)

    init(viewModel: NewMainViewModel,
         userPrefersDarkTheme: Binding<Bool>, userWalletIsEmpty: Binding<Bool>,
         shouldShowView: Binding<Bool>,
         currentIndex: Binding<Int>) {
        _userPrefersDarkTheme = userPrefersDarkTheme
        _userWalletIsEmpty = userWalletIsEmpty
        _shouldShowView = shouldShowView
        _currentIndex = currentIndex
        newMainViewModel = viewModel
    }

    private func verifyAddressInPasteboard() -> Bool {

        if let pasteboard = UIPasteboard.general.string?.lowercased(),
            pasteboard.isValidAddress {
            pasteboardString = pasteboard
            self.isValidAddress = true
            return true
        }
        return false
    }

    private func isSendInformationValid() -> Bool {
        Task {
            isReadyToSend = isValidAddress && isAmountValid && !sendLTCAddress.isEmpty
        }
        return isReadyToSend
    }

    var body: some View {
        GeometryReader { geometry in

            let width = geometry.size.width
            let sectionHeight = 60.0
            let sectionSpacer = 18.0
            let sectionSides = 15.0
            let buttonSize = 35.0

            ZStack {
                backgroundColor.edgesIgnoringSafeArea(.all)
                VStack {
                    Text("Send Litecoin")
                        .font(.system(size: 24, weight: .bold, design: .default))
                        .lineLimit(1)
                        .minimumScaleFactor(0.9)
                        .foregroundColor(userPrefersDarkTheme ? .white : .black)
                        .padding(2.5 * sectionSpacer)
                        .onTapGesture {
                            focusedField = nil
                        }
                    HStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(userPrefersDarkTheme ? .white : BentoColor.grayBorder,
                                        lineWidth: 1)
                                .frame(height: sectionHeight)
                            VStack {
                                HStack {
                                    Text("Recipient")
                                        .modifier(SendTextModalSubTitleModifier())
                                        .foregroundColor(userPrefersDarkTheme ? .white : .black)
                                    Spacer()
                                }
                                .frame(height: 18)
                                .padding(.top, 10)

                                 TextField(String(localized:""), text: $sendLTCAddress)
                                    .focused($focusedField, equals: .addressField)
                                    .truncationMode(.middle)
                                    .onChange(of: sendLTCAddress) { _ , newStringValue in
                                        if newStringValue.isValidAddress {
                                            bwTransaction.sendAddress = newStringValue
                                            newMainViewModel.currentSendAddress = bwTransaction.sendAddress
                                            isValidAddress = true
                                            isReadyToSend = isValidAddress && isAmountValid && !sendLTCAddress.isEmpty
                                        }
                                    }
                                    .padding(.trailing, width * 0.3)
                                    .textFieldStyle(BentoSendTextFieldStyle())

                            }
                            .frame(height: sectionHeight, alignment: .leading)
                            .onTapGesture {
                                focusedField = .addressField
                            }

                            VStack {
                                HStack {
                                    Spacer()
                                    Button(action: {
                                        if verifyAddressInPasteboard() {
                                            isValidAddress = true
                                            bwTransaction.sendAddress = sendLTCAddress
                                            newMainViewModel.currentSendAddress = bwTransaction.sendAddress
                                            didTapPaste.toggle()
                                        } else {
                                            errorMessage =  sendLTCAddress.isEmpty ? "No LTC Address Entered" : "Invalid LTC Address"
                                            shouldShowError.toggle()
                                        }
                                    }) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(userPrefersDarkTheme ? .white : BentoColor.grayBackground)
                                                .frame(width: buttonSize, height: buttonSize)

                                            Image(systemName: "list.clipboard")
                                                .sendButtonImageModifier()
                                                .frame(alignment: .center)
                                        }
                                    }
                                    .alert(errorMessage, isPresented: $shouldShowError) {
                                                Button("OK", role: .cancel) { }
                                    }
                                    .frame(width: buttonSize, height: buttonSize)
                                    .accessibilityIdentifier("pasteLTCAddressButton")
                                    .padding(.trailing, 4)

                                    Button(action: {
                                        didTapScan.toggle()
                                    }) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(userPrefersDarkTheme ? .white : BentoColor.grayBackground)
                                                .frame(width: buttonSize, height: buttonSize)
                                            Image(systemName: "qrcode")
                                                .sendButtonImageModifier()
                                                .frame(alignment: .center)
                                        }
                                    }
                                    .frame(width: buttonSize, height: buttonSize)
                                    .accessibilityIdentifier("scanLTCAddressButton")
                                    .background(userPrefersDarkTheme ? BentoColor.grayBackground.opacity(0.2) : BentoColor.grayBackground)
                                    .cornerRadius(8)
                                    .padding(.trailing, 16)
                                }
                            }
                            .frame(height: sectionHeight, alignment: .trailing)
                        }
                    }
                    .padding([.leading, .trailing], sectionSides)
                    .padding(.bottom, sectionSpacer)

                    HStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(userPrefersDarkTheme ? .white : BentoColor.grayBorder,
                                        lineWidth: 1)
                                .frame(height: sectionHeight)

                            VStack {
                                HStack {
                                    Text("Amount")
                                        .modifier(SendTextModalSubTitleModifier())
                                        .foregroundColor(userPrefersDarkTheme ? .white : .black)
                                    Spacer()
                                }
                                .frame(height: 18)
                                .padding(.top, 10)

                                TextField(String(localized: isLTCValueShown ? "\(newMainViewModel.walletBalanceLitecoin)" : "\(newMainViewModel.walletBalanceFiat)"),
                                          value: $sendAmount, format: .number)
                                    .foregroundColor(sentTextColor)
                                    .focused($focusedField, equals: .amountField)
                                    .keyboardType(.decimalPad)
                                    .onChange(of: sendAmount) { _,_ in

                                        sentTextColor = userPrefersDarkTheme ? .white : .black
                                        if !newMainViewModel.canSendAmountWithFees(isLTCValue: isLTCValueShown, sendAmountDouble: sendAmount) {
                                            sentTextColor = BrainwalletColor.error
                                            isAmountValid = false
                                        } else {
                                            isAmountValid = true
                                            guard let code = GlobalCurrency.from(code: newMainViewModel.exchangeRate?.code ?? "USD"),
                                                  let rate = newMainViewModel.exchangeRate?.rate else { return }
                                            bwTransaction.amount = newMainViewModel.currentPreFeeAmount
                                            bwTransaction.networkFee = newMainViewModel.currentNetworkFee
                                            bwTransaction.serviceFee = newMainViewModel.currentServiceFee
                                            bwTransaction.currentRate = newMainViewModel.exchangeRate
                                            bwTransaction.fiatAmount = rate * newMainViewModel.currentTotalAmount.rawValue
                                            bwTransaction.globalCode = code
                                            newMainViewModel.bwTransaction = bwTransaction
                                            debugPrint(" bwTransaction Amount: \(bwTransaction.amount)\n")
                                            debugPrint(" bwTransaction Address: \(bwTransaction.sendAddress)\n")
                                            debugPrint(" bwTransaction NetworkFee: \(bwTransaction.networkFee)\n")
                                            debugPrint(" bwTransaction ServiceFee: \(bwTransaction.serviceFee)\n")
                                            debugPrint(" bwTransaction Rate: \(bwTransaction.currentRate)\n")
                                            debugPrint(" bwTransaction Fiat Amount: \(bwTransaction.fiatAmount)\n")
                                        }
                                        isReadyToSend = isValidAddress && isAmountValid && !sendLTCAddress.isEmpty
                                     }
                                    .textFieldStyle(BentoSendTextFieldStyle())
                                    .padding(.trailing, width * 0.25)
                                    .padding(.bottom, 8)
                            }
                            .frame(height: sectionHeight, alignment: .leading)

                            VStack {
                                Spacer()
                                HStack {
                                    Spacer()
                                    Button(action: {
                                        isLTCValueShown.toggle()
                                    }) {
                                        VStack {
                                            Spacer()
                                            HStack {
                                                Spacer()
                                                if isLTCValueShown {
                                                    Image("litecoin_cutout24")
                                                        .ltcIconImageModifier()
                                                        .foregroundColor(userPrefersDarkTheme ? .white : .black)

                                                } else {
                                                    Text( "\(newMainViewModel.exchangeRate?.code ?? "")")
                                                        .font(.system(size: 18, weight: .bold, design: .default))
                                                        .foregroundColor(userPrefersDarkTheme ? .white : .black)
                                                        .frame(height: 30, alignment: .trailing)
                                                }
                                            }
                                            .frame(width: buttonSize * 2 + 4, height: buttonSize)

                                        }
                                    }
                                    .frame(width: buttonSize * 2 + 4, height: buttonSize)
                                    .accessibilityIdentifier("toggleFiatLTCSendButton")
                                    .padding(.trailing, 16)
                                }
                                .padding(.bottom, 8)

                            }
                            .frame(height: sectionHeight, alignment: .trailing)
                        }
                    }
                    .padding([.leading, .trailing], sectionSides)
                    .padding(.bottom, sectionSpacer)
                    .onTapGesture {
                        focusedField = .amountField
                    }

                    HStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(userPrefersDarkTheme ? .white : BentoColor.grayBorder , lineWidth: 1)
                                .frame(height: sectionHeight)
                            VStack {
                                HStack {
                                    Text("Memo (Optional):")
                                        .modifier(SendTextModalSubTitleModifier())
                                        .foregroundColor(userPrefersDarkTheme ? .white : .black)
                                    Spacer()
                                }
                                .frame(height: 18)
                                .padding(.top, 10)

                                ZStack {
                                    Divider()
                                        .frame(height: 1.0)
                                        .background(userPrefersDarkTheme ? .white : BentoColor.grayBorder)
                                        .padding(.top, 15.0)

                                    TextField(String(localized:""),
                                              text: $sendMemo)
                                    .focused($focusedField, equals: .memoField)
                                    .onChange(of: sendMemo) { _,_ in
                                    }
                                    .textFieldStyle(BentoSendTextFieldStyle())
                                }
                                .padding([.leading, .trailing], 16)
                                .padding(.bottom, 4)
                            }
                            .frame(height: sectionHeight)
                        }
                    }
                    .padding([.leading, .trailing], sectionSides)
                    .padding(.bottom, sectionSpacer / 2)
                    .onTapGesture {
                        focusedField = .memoField
                    }

                    Text("Dismiss keyboard")
                        .font(.system(size: 14, weight: .light, design: .default))
                        .foregroundColor(userPrefersDarkTheme ? .white : .black)
                        .padding(sectionSpacer)
                        .onTapGesture {
                            focusedField = nil
                        }

                    Spacer()
                    HStack {
                        Text("1 LTC" + " = \(newMainViewModel.currentFiatValue)")
                            .modifier(SendTextModalFooterModifier())
                            .foregroundColor(userPrefersDarkTheme ? .white : .black)
                        Spacer()
                    }
                    .padding(.bottom, 2)
                    .padding([.leading, .trailing], sectionSides)

                    HStack {
                        Button(action: {
                            focusedField = nil
                            currentIndex = 1
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(userPrefersDarkTheme ? .white : BentoColor.nearNearBlack)
                                    .frame(height: 48)
                                Text("Continue")
                                    .font(.system(size: 18, weight: .semibold, design: .default))
                                    .foregroundColor(isReadyToSend ? continueTextColor : continueTextColor.opacity(0.2))
                            }
                        }
                        .frame(height: 48)
                        .padding([.leading, .trailing], sectionSides)
                        .padding(.bottom, sectionSides * 0.5)
                        .disabled(!isReadyToSend)
                    }
                }
            }
        }
        .onAppear {
            backgroundColor = userPrefersDarkTheme ? BentoColor.darkModeColor1 : BentoColor.lightModeColor1
            sentTextColor = userPrefersDarkTheme ? .white : .black
            continueTextColor = userPrefersDarkTheme ? .black : .white
            isLTCValueShown = newMainViewModel.isLTCValueShown
            userWalletIsEmpty = (newMainViewModel.walletBalanceLitecoinDouble > 0.0 ) ? false : true
        }
        .onChange(of: didTapPaste) { _,_ in

            guard let pasteboard = UIPasteboard.general.string, !pasteboard.utf8.isEmpty,
                  pasteboard.isValidAddress
            else {
                shouldShowError  = true
                return
            }
            sendLTCAddress = pasteboard
        }
        .onChange(of: isLTCValueShown) { _,newValue in
            newMainViewModel.isLTCValueShown = newValue
            sendAmount = 0.0
        }
        .onChange(of: shouldShowError) { _,newValue in
            newMainViewModel.isLTCValueShown = newValue
        }
        .onChange(of: scannedText) { _, newValue in
            sendLTCAddress = newValue
            guard sendLTCAddress.isValidAddress else {
                shouldShowError  = true
                return
            }
         }
        .onChange(of: userWalletIsEmpty) { _,_ in
            delay(0.4) { shouldShowEmptyWalletAlert = userWalletIsEmpty }
        }
        .sheet(isPresented: $didTapScan) {
            DataScannerView(scannedText: $scannedText, isPresented: $didTapScan)
        }
        .alert(isPresented: $shouldShowEmptyWalletAlert) {
              Alert(title: Text("TOP UP NOW!"),
                      message: Text("You have no Litecoin. Tap Buy/Recieve. Get LTC in 5 minutes with MoonPay!"),
                      dismissButton: .default(Text("Ok"),action: { shouldShowView = false }))
        }
        .onDisappear {
            sendLTCAddress = ""
            sendAmount = 0.0
            sendMemo = ""
        }
    }
}
