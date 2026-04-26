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

    @Binding
    private var detailIsShowing: Bool

    @State
    private var changeTransactionFilter: Bool = false

    @State
    private var shouldShowExportOptions: Bool = false

    @State
    private var shouldHideExportButton: Bool = true

    @State
    private var phase = 0.0

    @State
    private var mainGradientStyle: MainGradientStyle = .lightStyle

    @State
    private var currentTransaction: Transaction?

    @State
    private var currentID = UUID()

    @State
    var filteredTransactions: [Transaction] = []

    @State
    private var filterModeState: TransactionFilterState = .allTransactions

    init(viewModel: NewMainViewModel,
         detailIsShowing: Binding<Bool>,
         userPrefersDarkTheme: Binding<Bool>) {
        _detailIsShowing = detailIsShowing
        _userPrefersDarkTheme = userPrefersDarkTheme
        newMainViewModel = viewModel
        filteredTransactions = newMainViewModel.transactions ?? []
    }

    var body: some View {
        GeometryReader { geometry in

            let height = geometry.size.height
            let labelBackground =  userPrefersDarkTheme ? Color.white.opacity(0.1) : BentoColor.tutorialGreen2.opacity(0.2)
            let labelForeground = userPrefersDarkTheme ? BrainwalletColor.content : BentoColor.tutorialGreen2

            ZStack {
                BentoBackgroundView(userPrefersDarkTheme: $userPrefersDarkTheme).edgesIgnoringSafeArea(.all)
                HStack {
                        ZStack {
                            ScrollView(.vertical) {
                                LazyVStack {
                                    ForEach($filteredTransactions, id: \.self) { transaction in

                                        TransactionRowView(userPrefersDarkTheme:$userPrefersDarkTheme,
                                                               transaction: transaction,
                                                               newMainViewModel: newMainViewModel)
                                                .frame(height: height)
                                                .cornerRadius(bentoCornerRadius)
                                                .id(transaction.id)
                                                .onAppear {
                                                    currentID = transaction.id
                                                    currentTransaction = filteredTransactions.filter { $0.id == currentID }.first
                                                    newMainViewModel.currentTransaction = currentTransaction
                                                }
                                    }
                                }
                                .scrollTargetLayout()
                            }
                            .frame(height: detailIsShowing ? transactionsBentoHeight * 2 : transactionsBentoHeight, alignment: .leading)
                            .scrollTargetBehavior(.viewAligned)

                    .opacity(filteredTransactions.isEmpty ? 0 : 1)

                            EmptyTransactionRow(userPrefersDarkTheme: $userPrefersDarkTheme)
                                 .frame(height: height)
                                 .cornerRadius(bentoCornerRadius)
                                 .opacity(filteredTransactions.isEmpty ? 1 : 0)
                            VStack {
                                Spacer()
                                HStack {
                                    ZStack {
                                        Button {
                                            filterModeState.toggle()
                                        } label: {
                                            HStack {
                                                Image(systemName: filterModeState.icon)
                                                    .resizable()
                                                    .frame(width: 12, height: 12)
                                                    .foregroundColor(filterModeState.iconColor)
                                                Text("\(filteredTransactions.count) txns")
                                                    .modifier(BWIPSSemiBold(size: 14.0))
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .foregroundColor(labelForeground)
                                            }
                                            .padding([.leading, .trailing], 4)
                                        }
                                        .frame(width: 80, height: 22, alignment: .leading)
                                        .background(labelBackground)
                                        .cornerRadius(8)
                                        .accessibilityIdentifier("filterTransactionsButton")
                                    }
                                    .padding([.leading, .bottom], 16)

                                    Spacer()
                                }
                            }
                            .opacity(filteredTransactions.isEmpty ? 0 : 1)
                        }
                }
            }
            .cornerRadius(bentoCornerRadius)
            .frame(height: transactionsBentoHeight, alignment: .center)
            .onAppear {
                mainGradientStyle = userPrefersDarkTheme ? .darkStyle : .lightStyle

                if let filteredTxs = newMainViewModel.transactions {
                    filteredTransactions = filteredTxs
                }
            }
            .onChange(of: newMainViewModel.isLTCValueShown ) { _,_ in
                if let filteredTxs = newMainViewModel.transactions {
                    filteredTransactions = filteredTxs
                }
            }
            .onChange(of: newMainViewModel.transactions ) { _,_ in
                if let filteredTxs = newMainViewModel.transactions {
                    filteredTransactions = filteredTxs
                }
            }
            .onChange(of: filterModeState) { _,_ in
                if let filteredTxs = newMainViewModel.transactions {
                    switch filterModeState {
                    case .allTransactions:
                        filteredTransactions = filteredTxs
                    case .sendTransactions:
                        filteredTransactions = filteredTxs.filter { $0.direction == .sent }
                    case .receiveTransactions:
                        filteredTransactions = filteredTxs.filter { $0.direction == .received }
                    }
                }
            }
        }
    }
}

class BRHelp: NSObject {

    override init() {}
    public func makeTransaction (
        txHash: UInt256 = UInt256(),
        version: UInt32 = 1,
        inputs: UnsafeMutablePointer<BRTxInput>? = nil,
        inCount: Int = 0,
        outputs: UnsafeMutablePointer<BRTxOutput>? = nil,
        outCount: Int = 0,
        lockTime: UInt32 = 0,
        blockHeight: UInt32 = 0,
        timestamp: UInt32 = UInt32(Date().timeIntervalSince1970)
    ) -> UnsafeMutablePointer<BRTransaction> {
        let txPtr = UnsafeMutablePointer<BRTransaction>.allocate(capacity: 1)
        txPtr.initialize(to: BRTransaction(
            txHash: txHash,
            version: version,
            inputs: inputs,
            inCount: inCount,
            outputs: outputs,
            outCount: outCount,
            lockTime: lockTime,
            blockHeight: blockHeight,
            timestamp: timestamp
        ))
        return txPtr
    }
}
//
// .background(
//        RoundedRectangle(cornerRadius: 10)
//            .fill(Color.white.opacity(0.07))
