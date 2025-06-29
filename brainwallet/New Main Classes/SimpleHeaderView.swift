//
//  SimpleHeaderView.swift
//  brainwallet
//
//  Created by Kerry Washington on 03/05/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

import SwiftUI

struct SimpleHeaderView: View {

    @ObservedObject
    var newMainViewModel: NewMainViewModel

    @State
    var shouldShowSettings: Bool = false

    @State
    var transactionCount = 0

    @State
    var filterMode: TransactionFilterState = .allTransactions

    private var modeState = TransactionFilterState.allCases

    init(viewModel: NewMainViewModel) {
        newMainViewModel = viewModel
    }
    var body: some View {
        GeometryReader { geometry in

            let width = geometry.size.width
            ZStack {
                BrainwalletColor.surface.edgesIgnoringSafeArea(.all)
                VStack {
                    HStack {
                        Button(action: {
                            newMainViewModel.shouldShowSettings.toggle()
                            shouldShowSettings = newMainViewModel.shouldShowSettings
                        }) {
                            Image(systemName: "line.3.horizontal")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 30.0, height: 30.0,
                                       alignment: .topLeading)
                                .foregroundColor(BrainwalletColor.content)
                        }
                        .frame(width: 30.0, height: 30.0,
                               alignment: .leading)

                        Spacer()

                        Text(newMainViewModel.currentFiatValue)
                            .font(.barlowLight(size: 16.0))
                            .frame(width: width * 0.4, height: 30.0,
                                   alignment: .topTrailing)
                            .foregroundColor(BrainwalletColor.content)
                    }
                    .frame(maxWidth: .infinity)
                    .padding([.leading, .top, .trailing], 16.0)

                    HStack {
                        VStack {
                            Text("BALANCE")
                                .font(.barlowRegular(size: 20.0))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(BrainwalletColor.content)
                            Text("\(newMainViewModel.walletBalanceFiat)")
                                .font(.barlowSemiBold(size: 50.0))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundColor(BrainwalletColor.content)
                                .padding(.bottom,2.0)
                                Text("\(newMainViewModel.walletBalanceLitecoin)")
                                    .font(.barlowLight(size: 16.0))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(BrainwalletColor.content)
                                    .padding([.top,.bottom],4.0)
                            Spacer()
                        }
                        Spacer()
                        VStack {
                            Spacer()
                            Button(action: {
                                let caseCount = modeState.count
                                var index = filterMode.rawValue
                                index += 1
                                if index >= caseCount {
                                    index = 0
                                    filterMode = TransactionFilterState(rawValue: index)!
                                } else {
                                    filterMode = TransactionFilterState(rawValue: index)!
                                }
                                newMainViewModel.updateTransactions()

                            }) {
                                VStack {
                                    Spacer()
                                    Text("\(String(localized: "Tx Count: "))\(String(describing: newMainViewModel.transactionCount))")
                                        .font(.barlowLight(size: 16.0))
                                        .frame(maxWidth: .infinity, alignment: .trailing)
                                        .foregroundColor(BrainwalletColor.content)
                                        .padding([.top,.bottom],4.0)
                                    Image(systemName: "slider.horizontal.3")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 30.0, height: 30.0, alignment: .trailing)
                                        .foregroundColor(BrainwalletColor.content)
                                }
                            }
                            .frame(width: 80.0)
                            .padding([.top,.bottom],4.0)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding([.leading, .trailing], 16.0)
                    .padding(.top, 16.0)
                    HStack {
                        NewTransactionsView(viewModel: newMainViewModel)
                    }
                    .background(.purple)
                }
            }
            .frame(height: globalHeaderHeight, alignment: .center)

        }
    }
}
