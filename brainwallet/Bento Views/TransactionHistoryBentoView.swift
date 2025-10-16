//
//  TransactionHistoryBentoView.swift
//  brainwallet
//
//  Created by Kerry Washington on 07/10/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//
import SwiftUI
import BRCore

struct TransactionHistoryBentoView: View {

    @ObservedObject
    var newMainViewModel: NewMainViewModel

    @Binding
    var userPrefersDarkTheme: Bool

    @State
    private var changeTransactionFilter: Bool = false

    @State
    private var shouldShowExportOptions: Bool = false

    @State
    private var isDashMoving: Bool = false

    @State
    private var phase = 0.0

    @State
    private var mainGradientStyle: MainGradientStyle = .lightStyle

    @Binding
    private var detailIsShowing: Bool

//    typedef struct {
//        UInt256 txHash;
//        uint32_t version;
//        BRTxInput *inputs;
//        size_t inCount;
//        BRTxOutput *outputs;
//        size_t outCount;
//        uint32_t lockTime;
//        uint32_t blockHeight;
//        uint32_t timestamp; // time interval since unix epoch
//    } BRTransaction;

    @State
    private var currentTransactionAddress = ""

    @State
    var filteredTransactions: [brainwallet.Transaction] = []

    @State
    private var modeState: TransactionFilterState = .allTransactions

    private let buttonSize: CGFloat = 20.0

    private let buttonPlatformFactor: CGFloat = 2.1

    init(viewModel: NewMainViewModel, detailIsShowing: Binding<Bool>, userPrefersDarkTheme: Binding<Bool>) {
        _detailIsShowing = detailIsShowing
        _userPrefersDarkTheme = userPrefersDarkTheme
        newMainViewModel = viewModel
        filteredTransactions = newMainViewModel.transactions ?? []
    }
    var body: some View {
        GeometryReader { geometry in

            let width = geometry.size.width
            let height = geometry.size.height

            ZStack {
                BentoBackgroundView(userPrefersDarkTheme: $userPrefersDarkTheme).edgesIgnoringSafeArea(.all)
                HStack {

                    if detailIsShowing {
                        Button(action: {
                            modeState.toggle()
                        }) {
                            ZStack {
                                BentoBackgroundView(userPrefersDarkTheme: $userPrefersDarkTheme)
                                    .frame(width: width * 0.18, height: height * 0.7, alignment: .center)

                                Text(String(localized: "\(modeState.label)"))
                                    .frame(width: width * 0.18, height: height * 0.7, alignment: .center)
                                    .font(Font(UIFont.barlowSemiBold(size: 15.0)))
                                    .foregroundColor(BrainwalletColor.content)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: bentoCornerRadius)
                                            .stroke(BrainwalletColor.content, lineWidth: 0.5)
                                    )
                            }
                            .padding(.all, 6.0)
                        }
                        .modifier(BentoShadow(userPrefersDarkTheme: $userPrefersDarkTheme))
                        .accessibilityIdentifier("transactionsFilterToggleButton")
                    }

                    Picker("", selection: $currentTransactionAddress) {
                        ForEach(filteredTransactions, id: \.self) {
                            Text($0.toAddress ?? "")
                                .font(Font(UIFont.barlowRegular(size: 15.0)))
                                .foregroundColor(BrainwalletColor.content)
                                .padding(4.0)
                        }
                    }
                    .pickerStyle(.wheel)
                    .frame(height: height * 0.7, alignment: .center)

                    if detailIsShowing {
                        Button(action: {
                            shouldShowExportOptions.toggle()
                        }) {
                            ZStack {
                                BentoBackgroundView(userPrefersDarkTheme: $userPrefersDarkTheme)
                                    .frame(width: width * 0.18, height: height * 0.7, alignment: .center)

                                Text(String(localized: "Export"))
                                    .frame(width: width * 0.18, height: height * 0.7, alignment: .center)
                                    .font(Font(UIFont.barlowSemiBold(size: 15.0)))
                                    .foregroundColor(BrainwalletColor.content)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: bentoCornerRadius)
                                            .stroke(BrainwalletColor.content, lineWidth: 0.5)
                                    )
                            }
                            .padding(.all, 6.0)
                        }
                        .modifier(BentoShadow(userPrefersDarkTheme: $userPrefersDarkTheme))
                        .accessibilityIdentifier("exportTransactionsButton")
                    }
                }
            }
            .cornerRadius(bentoCornerRadius)
            .frame(height: transactionsBentoHeight, alignment: .center)
            .onAppear {
                mainGradientStyle = userPrefersDarkTheme ? .darkStyle : .lightStyle
            }
        }
    }
}
