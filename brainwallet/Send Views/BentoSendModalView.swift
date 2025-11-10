//
//  BentoSendModalView.swift
//  brainwallet
//
//  Created by Kerry Washington on 03/05/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

import SwiftUI

struct BentoSendModalView: View {

    @ObservedObject
    var newMainViewModel: NewMainViewModel

    @Binding
    var userPrefersDarkTheme: Bool

    @State
    private var sendLTCAddress: String = ""

    @State
    private var sendAmount: Double = 0.0

    @State
    private var sendAmountString = ""

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
    private var isAmountValid = false

    @State
    private var sendPaymentRequest = PaymentRequest(string: "")

    let darkModeColor = LinearGradient(colors: [BentoColor.sendTopPurple,
                                                BentoColor.sendBottomPurple],
                                       startPoint: .topLeading,
                                       endPoint: .bottomTrailing)
    let lightModeColor = LinearGradient(colors: [.white], startPoint: .topLeading,
                                        endPoint: .bottomTrailing)
    @State
    private var backgroundColor: LinearGradient = LinearGradient(colors: [.white],
                                                                 startPoint: .topLeading,
                                                                 endPoint: .bottomTrailing)

    init(viewModel: NewMainViewModel,
         userPrefersDarkTheme: Binding<Bool>) {
        _userPrefersDarkTheme = userPrefersDarkTheme
        newMainViewModel = viewModel
        print(":::::\(newMainViewModel.filteredTransactions.count)")
    }

    private func limitText(_ upper: Int) {
//            if username.count > upper {
//                username = String(username.prefix(upper))
//            }
    }

    private func isSendInformationValid() -> Bool {
        return isValidAddress && isAmountValid && !sendLTCAddress.isEmpty
    }

    var body: some View {
        GeometryReader { geometry in

            let width = geometry.size.width
            let sectionHeight = 60.0
            let sectionSpacer = 12.0
            let sectionSides = 30.0
            let labelSize = 11.0
            let contentSize = 12.0
            let iconSize = 14.0
            let buttonSize = 35.0
            let coinSize = 28.0
            ZStack {
                backgroundColor.edgesIgnoringSafeArea(.all)
                VStack {
                    Text("Send Litecoin")
                        .font(.system(size: 24, weight: .bold, design: .default))
                        .lineLimit(1)
                        .minimumScaleFactor(0.9)
                        .foregroundColor(userPrefersDarkTheme ? .white : .black)
                        .padding(.top, sectionSpacer * 3)
                        .padding(.bottom, sectionSpacer)

                    HStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(userPrefersDarkTheme ? .white : BentoColor.grayBorder,
                                        lineWidth: 1)
                                .frame(height: sectionHeight)
                            VStack {
                                HStack {
                                    Text("Recipient")
                                        .font(.system(size: labelSize, weight: .light, design: .default))
                                        .foregroundColor(userPrefersDarkTheme ? .white : .black)
                                        .frame(height: 18, alignment: .topLeading)
                                        .padding(.leading, 16)
                                    Spacer()
                                }
                                .padding(.top, 10)
                                .frame(height: 18)

                                TextField(String(localized:""),
                                          text: $sendLTCAddress)
                                .font(.system(size: 11,
                                              weight: .regular, design: .default))
                                .frame(height: 20, alignment: .leading)
                                .controlSize(.regular)
                                .textFieldStyle(.plain)
                                .background(.clear)
                                .keyboardType(.alphabet)
                                .onChange(of: sendLTCAddress) { _ in

                                }
                                .padding(.bottom, 4)
                                .padding(.leading, 16)
                                .padding(.trailing, width * 0.3)

                            }
                            .frame(height: sectionHeight,
                                   alignment: .leading)

                            VStack {
                                HStack {
                                    Spacer()
                                    Button(action: {
                                        didTapPaste.toggle()
                                    }) {
                                        ZStack {

                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(userPrefersDarkTheme ? .white : BentoColor.grayBackground)
                                                .frame(width: buttonSize, height: buttonSize)

                                            Image(systemName: "list.clipboard")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .foregroundColor(.black)
                                                .frame(width: iconSize,
                                                       height: iconSize,
                                                       alignment: .center)
                                        }
                                    }
                                    .frame(width: buttonSize, height: buttonSize)
                                    .accessibilityIdentifier("pasteLTCAddressButton")
                                    .padding(.trailing, 4)

                                    Button(action: {
                                        // shouldShowBalance.toggle()
                                    }) {
                                        ZStack {

                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(userPrefersDarkTheme ? .white : BentoColor.grayBackground)
                                                .frame(width: buttonSize, height: buttonSize)

                                            Image(systemName: "qrcode")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .foregroundColor(.black)
                                                .frame(width: iconSize,
                                                       height: iconSize,
                                                       alignment: .center)
                                        }
                                    }
                                    .frame(width: buttonSize, height: buttonSize)
                                    .accessibilityIdentifier("scanLTCAddressButton")
                                    .background(userPrefersDarkTheme ? BentoColor.grayBackground.opacity(0.2) : BentoColor.grayBackground)
                                    .cornerRadius(8)
                                    .padding(.trailing, 16)
                                }
                            }
                            .frame(height: sectionHeight,
                                   alignment: .trailing)

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
                                        .font(.system(size: labelSize, weight: .light, design: .default))
                                        .foregroundColor(userPrefersDarkTheme ? .white : .black)
                                        .frame(height: 15, alignment: .topLeading)
                                        .padding(.leading, 16)
                                    Spacer()
                                }
                                .padding(.top, 10)
                                .frame(height: 18)

                                TextField(String(localized: isLTCValueShown ? "\(newMainViewModel.walletBalanceLitecoin)" : "\(newMainViewModel.walletBalanceFiat)"),
                                              text: $sendAmountString)
                                    .font(.system(size: 26,
                                                  weight: .bold, design: .default))
                                    .foregroundColor(userPrefersDarkTheme ? .white : .black)
                                    .frame(height: 34, alignment: .leading)
                                    .controlSize(.regular)
                                    .textFieldStyle(.plain)
                                    .background(.clear)
                                    .keyboardType(.decimalPad)
                                    .onChange(of: sendAmountString) { _ in

                                    }
                                    .padding(.bottom, 4)
                                    .padding(.leading, 16)
                                    .padding(.trailing, width * 0.25)
                            }
                            .frame(height: sectionHeight,
                                   alignment: .leading)

                            VStack {
                                HStack {
                                    Spacer()

                                    Button(action: {
                                        isLTCValueShown.toggle()

                                    }) {
                                        HStack {
                                            Spacer()
                                            if isLTCValueShown {
                                                Image("litecoin_cutout24")
                                                    .resizable()
                                                    .renderingMode(.template)
                                                    .foregroundColor(userPrefersDarkTheme ? .white : .black)
                                                    .frame(width: coinSize,
                                                           height: coinSize,
                                                           alignment: .trailing)
                                            } else {

                                                Text( "\(newMainViewModel.exchangeRate?.code ?? "")")
                                                    .font(.system(size: 18,
                                                                  weight: .bold, design: .default))
                                                    .foregroundColor(userPrefersDarkTheme ? .white : .black)
                                                    .frame(height: 30, alignment: .trailing)
                                            }

                                        }
                                        .frame(width: buttonSize * 2 + 4, height: buttonSize)

                                    }
                                    .frame(width: buttonSize * 2 + 4, height: buttonSize)
                                    .accessibilityIdentifier("toggleFiatLTCSendButton")
                                    .padding(.top, 16)
                                    .padding(.trailing, 16)
                                }
                            }
                            .frame(height: sectionHeight,
                                   alignment: .trailing)

                        }
                    }
                    .padding([.leading, .trailing], sectionSides)
                    .padding(.bottom, sectionSpacer)

                    HStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(userPrefersDarkTheme ? .white : BentoColor.grayBorder , lineWidth: 1)
                                .frame(height: sectionHeight)
                            VStack {
                                HStack {
                                    Text("Payment Memo")
                                        .font(.system(size: labelSize, weight: .light, design: .default))
                                        .foregroundColor(userPrefersDarkTheme ? .white : .black)
                                        .frame(height: 18, alignment: .topLeading)
                                        .padding(.leading, 16)
                                    Spacer()
                                }
                                .padding(.top, 10)
                                .frame(height: 18)

                                ZStack {

                                    Divider()
                                        .frame(height: 1.0)
                                        .background(userPrefersDarkTheme ? .white : BentoColor.grayBorder)
                                        .padding(.top, 18.0)

                                    TextField(String(localized:""),
                                              text: $sendMemo)
                                    .font(.system(size: contentSize,
                                                  weight: .semibold, design: .default))
                                    .frame(height: 20, alignment: .leading)
                                    .controlSize(.regular)
                                    .textFieldStyle(.plain)
                                    .background(.clear)
                                    .keyboardType(.alphabet)
                                    .onChange(of: sendMemo) { _ in

                                    }
                                }
                                .padding([.leading, .trailing], 16)
                                .padding(.bottom, 4)

                            }
                            .frame(height: sectionHeight)
                        }
                    }
                    .padding([.leading, .trailing], sectionSides)
                    .padding(.bottom, sectionSpacer)

                    Spacer()

                    HStack {
                        Text("1 LTC" + " = \(newMainViewModel.currentFiatValue)")
                            .font(.system(size: labelSize, weight: .light, design: .default))
                            .foregroundColor(userPrefersDarkTheme ? .white : .black)
                            .frame(height: 15, alignment: .leading)
                        Spacer()
                    }
                    .padding(.bottom, 2)
                    .padding([.leading, .trailing], sectionSides)
                    .frame(height: 15)

                    HStack {
                        Button(action: {
                            // Prepare to Send
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(userPrefersDarkTheme ? .white : BentoColor.nearNearBlack)
                                    .frame(height: 48)

                                Text("Continue")
                                    .font(.system(size: 18, weight: .semibold, design: .default))
                                    .foregroundColor(userPrefersDarkTheme ? .black : .white)
                            }

                        }
                        .frame(height: 48)
                        .padding([.leading, .trailing], sectionSides)
                        .padding(.bottom, sectionSides * 0.5)
                        .disabled(!isSendInformationValid())
                    }
                }
            }
        }
        .onAppear {
            backgroundColor = userPrefersDarkTheme ? darkModeColor : lightModeColor
            isLTCValueShown = newMainViewModel.isLTCValueShown
        }
        .onChange(of: didTapPaste) { _ in

            guard let pasteboard = UIPasteboard.general.string, !pasteboard.utf8.isEmpty
            else {
                return
            }
//            guard let request = PaymentRequest(string: pasteboard)
//            else {
//                return showAlert(title: "Invalid Address" , message: "Please enter the recipient's address." , buttonLabel: "Ok" )
//            }
//            

//            if let amount = request.amount {
//                amountView.forceUpdateAmount(amount: amount)
//            }
//            if request.label != nil {
//                memoCell.content = request.label
//            }
            newMainViewModel.sendPaymentRequest = sendPaymentRequest
            sendLTCAddress = pasteboard
        }
        .onChange(of: didTapScan) { _ in

        }
        .onChange(of: isLTCValueShown) { _ in
            newMainViewModel.isLTCValueShown = isLTCValueShown
        }
        .onDisappear {
            backgroundColor = userPrefersDarkTheme ? darkModeColor : lightModeColor
            sendLTCAddress = ""
            sendAmount = 0.0
            sendAmountString = ""
            sendMemo = ""
            sendPaymentRequest = PaymentRequest(string: "")
        }
    }
}
