//
//  NewMainView.swift
//  brainwallet
//
//  Created by Kerry Washington on 03/05/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

import SwiftUI
import FirebaseAnalytics

let bentoCornerRadius: CGFloat = 14.0
let utilityHeaderHeight: CGFloat = 60.0
let tabBarHeight: CGFloat = 80.0
let balanceGameBentoHeight: CGFloat = 120.0
let transactionsBentoHeight: CGFloat = 80.0
let maxMidBentoHeight: CGFloat = 220.0

enum Selection {
    case receive
    case send
    case gameHistory
}

enum TransactionFilterState: Int, CaseIterable {
    case allTransactions = 0
    case sendTransactions
    case receiveTransactions
}

struct NewMainView: View {

    @ObservedObject
    var newMainViewModel: NewMainViewModel

    @ObservedObject
    var newReceiveViewModel: NewReceiveViewModel

    @State
    private var selectionState: Selection = .gameHistory

    @State
    private var filterTransactionState: TransactionFilterState = .allTransactions

    let statusBarHeight = 20.0

    init(viewModel: NewMainViewModel,
         receiveViewModel: NewReceiveViewModel) {
        newMainViewModel = viewModel
        newReceiveViewModel = receiveViewModel
    }
    var body: some View {
        GeometryReader { geometry in

            let width = geometry.size.width
            let height = geometry.size.height

            ZStack(alignment: .bottom) {
                BrainwalletColor.surface.edgesIgnoringSafeArea(.all)

                VStack {
                    UtilityHeaderView(viewModel: newMainViewModel)
                        .frame(height: utilityHeaderHeight, alignment: .top)
                        .padding(.top, 1.0)
                        .padding([.leading, .trailing], 10.0)

                    BalanceBentoView(viewModel: newMainViewModel)
                        .frame(height: balanceGameBentoHeight, alignment: .top)
                        .padding(.top, 1.0)
                        .padding([.leading, .trailing], 10.0)

                    TransactionHistoryBentoView(viewModel: newMainViewModel)
                        .frame(height: transactionsBentoHeight, alignment: .top)
                        .padding(.top, 1.0)
                        .padding([.leading, .trailing], 10.0)

                    HStack {
                        TutorialsBentoView(viewModel: newMainViewModel)

                        VStack {
                            LTCPriceBentoView(viewModel: newMainViewModel)
                                .frame(maxHeight: height * 0.5 * 0.5, alignment: .top)

                            FavouritesBentoView(viewModel: newMainViewModel)
                                .frame(maxHeight: height * 0.5 * 0.5, alignment: .top)
                        }
                    }
                    .frame(maxHeight: height * 0.5, alignment: .top)
                    .padding([.leading, .trailing], 10.0)

                    GameHubBentoView(viewModel: newMainViewModel)
                        .frame(height: balanceGameBentoHeight, alignment: .top)
                        .padding(.bottom, 1.0)
                        .padding([.leading, .trailing], 10.0)
                    Spacer(minLength: tabBarHeight)
                }
                .offset(x: newMainViewModel.shouldShowSettings ? width - 90.0: 0)

                TabView {
                    Color.clear
                        .tabItem {
                            Label(String(localized: "Send"), systemImage: "paperplane")
                        }
                        .toolbar(.visible, for: .tabBar)
                        .toolbarBackground(BrainwalletColor.surface, for: .tabBar)
                        .onAppear {
                            
                        }
                    Color.clear
                        .tabItem {
                            Label(newReceiveViewModel.canUserBuy ?
                                  String(localized: "Buy/Receive") : String(localized: "Receive"),
                                  systemImage: "arrow.left.arrow.right")
                        }
                        .toolbar(.visible, for: .tabBar)
                        .toolbarBackground(BrainwalletColor.surface, for: .tabBar)
                        .onAppear {
                            
                        }
                    Color.clear
                        .tabItem {
                            Label(String(localized: "Game Hub"), systemImage: "gamecontroller")
                        }
                        .toolbar(.visible, for: .tabBar)
                        .toolbarBackground(BrainwalletColor.surface, for: .tabBar)
                        .onAppear {
                            
                        }
                    Color.clear
                        .tabItem {
                            Label(String(localized: "History"),
                                  systemImage: "clock.arrow.trianglehead.2.counterclockwise.rotate.90")
                        }
                        .toolbar(.visible, for: .tabBar)
                        .toolbarBackground(BrainwalletColor.surface, for: .tabBar)
                        .onAppear {
                            
                        }
                }
                .accentColor(BrainwalletColor.content)
                .frame(height: tabBarHeight, alignment: .bottom)
            }
        }
    }
}
