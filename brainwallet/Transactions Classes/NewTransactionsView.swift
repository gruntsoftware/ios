//
//  NewTransactionsView.swift
//  brainwallet
//
//  Created by Kerry Washington on 03/05/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

import SwiftUI

struct NewTransactionsView: View {

    @ObservedObject
    var newMainViewModel: NewMainViewModel

    @State
    private var transactions: [Transaction] = []

    init(viewModel: NewMainViewModel) {
        newMainViewModel = viewModel
    }
    var body: some View {
        GeometryReader { geometry in

            let width = geometry.size.width

            ZStack {
                BrainwalletColor.lavender.edgesIgnoringSafeArea(.all)

                    ScrollViewReader { _ in
                        VStack {
                            List(transactions, id: \.hash) { tx in
                                TransactionRowView(transaction: tx)
                                    .frame(width: width, height: 45)
                            }.listStyle(PlainListStyle())
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 88.0)
            }.onAppear {
                guard let fetchedTransactions = newMainViewModel.transactions else { return }
                transactions = fetchedTransactions
            }
        }
    }
}
