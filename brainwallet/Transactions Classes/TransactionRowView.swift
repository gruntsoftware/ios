//
//  TransactionRowView.swift
//  brainwallet
//
//  Created by Kerry Washington on 03/05/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

import SwiftUI

struct TransactionRowView: View {

    @State
    private var isReceived: Bool = false

    @State
    private var filterMode: TransactionFilterState = .allTransactions

    @State
    private var modeState = 0

    let transaction: Transaction

    init(transaction: Transaction) {
        self.transaction = transaction
        isReceived = (transaction.direction == .received) ? true : false
    }

    var body: some View {
        GeometryReader { _ in

            ZStack {
                BrainwalletColor.affirm.edgesIgnoringSafeArea(.all)
                HStack {
                    VStack {
                        Image(systemName: isReceived ? "arrow.up.circlepath" : "arrow.down.circlepath")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .padding()
                    }
                    VStack {
                        Text(String(format: transaction.direction.addressTextFormat, transaction.toAddress ?? "---ERROR---"))
                            .font(.title2)
                            .foregroundColor(BrainwalletColor.content)
                    }
                    VStack {}
                }
            }
        }
    }

}
// amountText = transaction.descriptionString(isLtcSwapped: isLtcSwapped, rate: rate, maxDigits: maxDigits).string
//
// feeText = transaction.amountDetails(isLtcSwapped: isLtcSwapped, rate: rate, rates: [rate], maxDigits: maxDigits)
//
// addressText = String(format: transaction.direction.addressTextFormat, transaction.toAddress ?? "---ERROR---")
