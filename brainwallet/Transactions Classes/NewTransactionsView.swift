//
//  NewTransactionsView.swift
//  brainwallet
//
//  Created by Kerry Washington on 03/05/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

import SwiftUI

enum FilterTransactionMode: Int, CaseIterable {
    case all = 0
    case sent = 1
    case received = 2
}

struct NewTransactionsView: View {

    @ObservedObject
    var newMainViewModel: NewMainViewModel

    @State
    private var transactions: [Transaction] = []

    @State
    private var filterMode: FilterTransactionMode = .all

    @State
    private var modeState = 0

    init(viewModel: NewMainViewModel) {
        newMainViewModel = viewModel

    }
    var body: some View {
        GeometryReader { geometry in

            let width = geometry.size.width

            ZStack {
                BrainwalletColor.affirm.edgesIgnoringSafeArea(.all)
                VStack {
                    HStack {
                        Text("\(filterMode.rawValue)")
                        Spacer()
                        Button(action: {
                            if modeState < 2 {
                                modeState += 1
                            } else {
                                modeState = 0
                            }
                            filterMode = FilterTransactionMode(rawValue: modeState)!

                        }) {
                            Image(systemName: "slider.horizontal.3")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 30.0, height: 30.0,
                                       alignment: .center)
                                .foregroundColor(BrainwalletColor.content)
                        }
                        .frame(width: 30.0, height: 30.0)
                    }
                    .frame(height: 30.0, alignment: .center)
                    .padding([.leading, .trailing], 8.0)
                    ScrollViewReader { _ in
                        VStack {
                            List(transactions, id: \.hash) { tx in
                                TransactionRowView(transaction: tx)
                                    .frame(width: width, height: 45)
                            }.listStyle(PlainListStyle())
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}
