//
//  NewMainView.swift
//  brainwallet
//
//  Created by Kerry Washington on 03/05/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

import SwiftUI
import FirebaseAnalytics

let globalHeaderHeight: CGFloat = 160.0

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

    let statusBarHeight = 44.0

    init(viewModel: NewMainViewModel,
         receiveViewModel: NewReceiveViewModel) {
        newMainViewModel = viewModel
        newReceiveViewModel = receiveViewModel
    }
    var body: some View {
        GeometryReader { geometry in

            let width = geometry.size.width
            let height = geometry.size.height
            let activeHeight = abs(height - globalHeaderHeight - statusBarHeight - geometry.safeAreaInsets.bottom - geometry.safeAreaInsets.top)

            ZStack {
                BrainwalletColor.surface.edgesIgnoringSafeArea(.all)

                VStack {
                        SimpleHeaderView(viewModel: newMainViewModel)
                            .frame(height: globalHeaderHeight,
                                    alignment: .top)
                            .padding(.top, statusBarHeight)
                    Spacer()
                        TabView {
                            NewSendView(viewModel: newMainViewModel)
                                .tabItem {
                                    Label(String(localized: "Send"), systemImage: "arrow.up.right")
                                }
                                .toolbar(.visible, for: .tabBar)
                                .toolbarBackground(BrainwalletColor.surface, for: .tabBar)
                            GameView(viewModel: newMainViewModel)
                                .tabItem {
                                    Label(String(localized: "History"), systemImage: "deskclock")
                                }
                                .toolbar(.visible, for: .tabBar)
                                .toolbarBackground(BrainwalletColor.surface, for: .tabBar)

                            NewReceiveView(viewModel: newReceiveViewModel, isModalMode: nil)
                                .tabItem {
                                    Label(newReceiveViewModel.canUserBuy ? String(localized: "Buy / Receive") : String(localized: "Receive"),
                                          systemImage: "arrow.down.backward")
                                }
                                .toolbar(.visible, for: .tabBar)
                                .toolbarBackground(BrainwalletColor.surface, for: .tabBar)
                            }
                            .frame(height: activeHeight, alignment: .bottom)
                            .accentColor(BrainwalletColor.content)

                    }
                    .offset(x: newMainViewModel.shouldShowSettings ? width - 90.0: 0)
                }
            }
        }
}
