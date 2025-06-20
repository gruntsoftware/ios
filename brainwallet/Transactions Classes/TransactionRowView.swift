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
    private var filterMode: FilterTransactionMode = .allTransactions

    @State
    private var modeState = 0

    let transaction: Transaction

    init(transaction: Transaction) {
        self.transaction = transaction
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
                            .foregroundColor(isReceived ? BrainwalletColor.affirm : BrainwalletColor.content)
                            .padding()
                    }
                    VStack {
                        Text("")
                            .font(.title2)
                            .foregroundColor(BrainwalletColor.content)
                        Text("")
                            .font(.title2)
                            .foregroundColor(BrainwalletColor.content)
                    }
                    VStack {}
                }
            }
        }
    }

}
