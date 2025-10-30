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
    var cellViewModel: TransactionCellViewModel?

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

    init(cellViewModel:  Binding<TransactionCellViewModel?>?,
         viewModel: NewMainViewModel, detailIsShowing: Binding<Bool>, userPrefersDarkTheme: Binding<Bool>) {
        _detailIsShowing = detailIsShowing
        _userPrefersDarkTheme = userPrefersDarkTheme
        newMainViewModel = viewModel
        self._cellViewModel = cellViewModel ?? Binding.constant(nil)
        filteredTransactions = newMainViewModel.transactions ?? []
    }

    var body: some View {
        GeometryReader { geometry in

            let width = geometry.size.width
            let height = geometry.size.height
            let labelBackground =  userPrefersDarkTheme ? BrainwalletColor.content.opacity(0.1) : BentoColor.tutorialGreen1
            let labelForeground = userPrefersDarkTheme ? BrainwalletColor.content : BentoColor.tutorialGreen2

            ZStack {
                BentoBackgroundView(userPrefersDarkTheme: $userPrefersDarkTheme).edgesIgnoringSafeArea(.all)
                HStack {

                    if !filteredTransactions.isEmpty {
                        ZStack {
                            ScrollView(.vertical) {
                                LazyVStack {
                                    ForEach($filteredTransactions, id: \.self) { transaction in
                                        TransactionRowView(userPrefersDarkTheme:$userPrefersDarkTheme, transaction: transaction, newMainViewModel: newMainViewModel)
                                            .frame(height: height)
                                            .cornerRadius(bentoCornerRadius)
                                            .id(transaction.id)
                                            .onAppear {
                                                currentID = transaction.id
                                                currentTransaction = filteredTransactions.filter { $0.id == currentID }.first
                                            }
                                    }
                                }
                                .scrollTargetLayout()
                            }
                            .scrollTargetBehavior(.viewAligned)
                            VStack {
                                Spacer()
                                HStack {
                                    ZStack {
                                        Capsule()
                                            .fill(labelBackground.opacity(0.4))
                                            .frame(width: 85, height: 25)
                                        Button {
                                            filterModeState.toggle()
                                        } label: {
                                            HStack {

                                                Image(systemName: filterModeState.icon)
                                                    .resizable()
                                                    .frame(width: 12, height: 12)
                                                    .foregroundColor(filterModeState.iconColor)
                                                Text("\(filteredTransactions.count) txns")
                                                    .font(.system(size: 12, weight: .semibold, design: .default))
                                                    .lineLimit(1)
                                                    .minimumScaleFactor(0.3)// Shrinks to 30% of original
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .foregroundColor(labelForeground)
                                            }
                                        }
                                        .padding(.leading)
                                        .frame(width: 85, height: 25)
                                        .accessibilityIdentifier("filterTransactionsButton")

                                    }
                                    Spacer()
                                }
                                .padding(.leading, 4)
                                .padding(.bottom, 2)

                            }
                        }
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
            .onChange(of: currentTransaction ) { _,_ in

                guard let trxn = currentTransaction,
                      let rate = newMainViewModel.store?.state.currentRate,
                      let maxDigits = newMainViewModel.store?.state.maxDigits else { return }

                cellViewModel = TransactionCellViewModel(transaction: trxn,
                                                         isLTCValueShown: newMainViewModel.isLTCValueShown,
                                                         rate: rate,
                                                         maxDigits: maxDigits,
                                                         isSyncing: false)
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

// let width = geometry.size.width
//
//
// ZStack {
//    BentoBackgroundView(userPrefersDarkTheme: $userPrefersDarkTheme).edgesIgnoringSafeArea(.all)
//    VStack(alignment: .center) {
//        HStack {
//            ZStack {
//                RoundedRectangle(cornerRadius: 8)
//                    .frame(width: width * 0.5, height: 24, alignment: .center)
//                    .foregroundColor(labelBackground)
//                    .padding(8)
//                Text("TUTORIALS")
//                    .font(.system(size: 12, weight: .light, design: .default))
//                    .lineLimit(1)
//                    .minimumScaleFactor(0.5)// Shrinks to 50% of original
//                    .padding([.leading, .trailing], 4)
//                    .frame(maxWidth: width * 0.5, maxHeight: 24, alignment: .center)
//                    .foregroundColor(labelForeground)
//            }
//            Spacer()
//        }
//        Spacer()
//    }

//                                            Picker("", selection: $currentTransaction) {
//                                                ForEach($filteredTransactions, id: \.self) { transaction in
//                                                    TransactionRowView(transaction: transaction, newMainViewModel: newMainViewModel)
//                                                }
//                                            }
//                                            .pickerStyle(.wheel)
//                                            .background(Color.clear)
//                                            .frame(height: height, alignment: .center)
//                                            .disabled(filteredTransactions.isEmpty)
//                                            .onChange(of: currentTransaction) { value in
//                                                print(":::||\(value)")
//                                            }
// if detailIsShowing {
//    Button(action: {
//        modeState.toggle()
//    }) {
//        ZStack {
//            BentoBackgroundView(userPrefersDarkTheme: $userPrefersDarkTheme)
//                .frame(width: width * 0.18, height: height * 0.7, alignment: .center)
//
//            Text(String(localized: "\(modeState.label)"))
//                .frame(width: width * 0.18, height: height * 0.7, alignment: .center)
//                .font(Font(UIFont.barlowSemiBold(size: 15.0)))
//                .foregroundColor(BrainwalletColor.content)
//                .overlay(
//                    RoundedRectangle(cornerRadius: bentoCornerRadius)
//                        .stroke(BrainwalletColor.content, lineWidth: 0.5)
//                )
//        }
//        .padding(.all, 6.0)
//    }
//    .modifier(BentoShadow(userPrefersDarkTheme: $userPrefersDarkTheme))
//    .accessibilityIdentifier("transactionsFilterToggleButton")
// }
// if detailIsShowing {
//    Button(action: {
//        shouldShowExportOptions.toggle()
//    }) {
//        ZStack {
//            BentoBackgroundView(userPrefersDarkTheme: $userPrefersDarkTheme)
//                .frame(width: width * 0.18, height: height * 0.7, alignment: .center)
//
//            Text(String(localized: "Export"))
//                .frame(width: width * 0.18, height: height * 0.7, alignment: .center)
//                .font(Font(UIFont.barlowSemiBold(size: 15.0)))
//                .foregroundColor(BrainwalletColor.content)
//                .overlay(
//                    RoundedRectangle(cornerRadius: bentoCornerRadius)
//                        .stroke(BrainwalletColor.content, lineWidth: 0.5)
//                )
//        }
//        .padding(.all, 6.0)
//    }
//    .modifier(BentoShadow(userPrefersDarkTheme: $userPrefersDarkTheme))
//    .accessibilityIdentifier("exportTransactionsButton")
// }
