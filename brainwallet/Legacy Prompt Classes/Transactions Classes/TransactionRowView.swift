//
//  TransactionRowView.swift
//  brainwallet
//
//  Created by Kerry Washington on 03/05/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

import SwiftUI

struct TransactionRowView: View {

    @ObservedObject
    var newMainViewModel: NewMainViewModel

    @State
    private var filterMode: FilterTransactionMode = .allTransactions

    @Binding
    var userPrefersDarkTheme: Bool

    @State
    private var amountLabel = ""

    @State
    private var isLTCValueShown = false

    @Binding
    var transaction: Transaction

    init(userPrefersDarkTheme: Binding<Bool>, transaction: Binding<Transaction>, newMainViewModel: NewMainViewModel) {
        self.newMainViewModel = newMainViewModel
        _transaction = transaction
        _userPrefersDarkTheme = userPrefersDarkTheme
    }

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width

            ZStack {
                BentoBackgroundView(userPrefersDarkTheme: $userPrefersDarkTheme).edgesIgnoringSafeArea(.all)
                VStack {
                    Spacer()
                    HStack {
                        Text(transaction.longTimestamp)
                            .modifier(BWIPSRegular(size: 19.0))
                            .frame(maxWidth: width * 0.5, alignment: .leading)
                            .foregroundStyle( userPrefersDarkTheme ? .white: BrainwalletColor.nearBlack.opacity(0.8))

                        Spacer()
                        Text(amountLabel)
                            .modifier(BWIPSBold(size: 22.0))
                            .frame(maxWidth: width * 0.5, alignment: .trailing)
                            .foregroundColor(transaction.direction == .sent ? BrainwalletColor.transferRed : BrainwalletColor.affirm)
                    }
                    .padding([.leading, .trailing], 16)

                    Spacer()

                    HStack {
                        Spacer()
                        Text(transaction.detailsAddressText)
                            .modifier(BWIPSThin(size: 15.0))
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .foregroundStyle( userPrefersDarkTheme ? .white.opacity(0.8): BrainwalletColor.nearBlack.opacity(0.8))

                    }
                    .padding([.leading, .trailing], 16)
                    Spacer()
                }
            }
        }
        .onChange(of: newMainViewModel.isLTCValueShown, { _, _ in
            isLTCValueShown = newMainViewModel.isLTCValueShown
        })
        .onAppear {
            if let currentRate = newMainViewModel.store?.state.currentRate,
               let maxDigits = newMainViewModel.store?.state.maxDigits {
                let sense = transaction.direction == .sent ? "-" : "+"
                isLTCValueShown = newMainViewModel.isLTCValueShown
                amountLabel = "\(sense) " + transaction.amountDescription(isLTCValueShown: isLTCValueShown, rate: currentRate, maxDigits: maxDigits)
            }
        }
    }
}
