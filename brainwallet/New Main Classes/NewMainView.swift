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
let balanceGameBentoHeight: CGFloat = 140.0
let transactionsBentoHeight: CGFloat = 80.0
let maxMidBentoHeight: CGFloat = 220.0
let iconSize: CGFloat = 20.0

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
    private var userDidTapSend: Bool = false

    @State
    private var shouldShowTransactionDetail: Bool = false

    @State
    private var userDidTapBuyReceive: Bool = false

    @State
    var shouldShowSettings: Bool = false

    @State
    private var shouldRing: Bool = false

    @State
    private var bellAngle: Double = 0.0

    private let buttonSize: CGFloat = 20.0

    private let buttonPlatformFactor: CGFloat = 2.1

    @State
    private var selectionState: Selection = .gameHistory

    @State
    private var filterTransactionState: TransactionFilterState = .allTransactions

    @State
    private var userPrefersDarkTheme = true

    init(viewModel: NewMainViewModel,
         receiveViewModel: NewReceiveViewModel) {
        newMainViewModel = viewModel
        newReceiveViewModel = receiveViewModel
        userPrefersDarkTheme = viewModel.userPrefersDarkMode
    }
    var body: some View {
        GeometryReader { geometry in

            let width = geometry.size.width
            let surface = BrainwalletColor.surface
            let content = BrainwalletColor.content

            NavigationStack {
                ZStack(alignment: .bottom) {
                    surface.edgesIgnoringSafeArea(.all)
                    VStack {
                        BalanceBentoView(viewModel: newMainViewModel, userPrefersDarkTheme: $userPrefersDarkTheme)
                            .frame(height: balanceGameBentoHeight, alignment: .top)
                            .padding([.top,.leading, .trailing], 10.0)
                        if shouldShowTransactionDetail {
                            TransactionDetailBentoView(viewModel: newMainViewModel, userPrefersDarkTheme:  $userPrefersDarkTheme)
                                .padding(.top, 1.0)
                                .frame(maxHeight: .infinity)
                                .padding([.leading, .trailing], 10.0)
                                .scaleEffect(x: 1.0, y: shouldShowTransactionDetail ? 1.0 : 0.0, anchor: .top)
                                .transition(.scale)
                        }
                        TransactionHistoryBentoView(viewModel: newMainViewModel, userPrefersDarkTheme: $userPrefersDarkTheme)
                            .frame(height: shouldShowTransactionDetail ? transactionsBentoHeight * 1.2 :
                                    transactionsBentoHeight, alignment: .top)
                            .padding(.top, 1.0)
                            .padding([.leading, .trailing], 10.0)
                            .onTapGesture {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    shouldShowTransactionDetail.toggle()
                                }
                            }

                        if !shouldShowTransactionDetail {
                            Group {
                                HStack {
                                    TutorialsBentoView(viewModel: newMainViewModel,
                                                       userPrefersDarkTheme: $userPrefersDarkTheme)
                                    .frame(maxHeight: .infinity, alignment: .top)

                                    VStack {
                                        LTCPriceBentoView(viewModel: newMainViewModel,
                                                          userPrefersDarkTheme: $userPrefersDarkTheme)

                                        FavouritesBentoView(viewModel: newMainViewModel,
                                                            userPrefersDarkTheme: $userPrefersDarkTheme)

                                    }
                                }
                                .frame(maxHeight: .infinity, alignment: .top)
                                .padding([.leading, .trailing], 10.0)

                                GameHubBentoView(viewModel: newMainViewModel, userPrefersDarkTheme: $userPrefersDarkTheme)
                                    .frame(height: balanceGameBentoHeight, alignment: .top)
                                    .padding(.bottom, 10.0)
                                    .padding([.leading, .trailing], 10.0)
                            }
                            .scaleEffect(x: 1.0, y: shouldShowTransactionDetail ? 0.0 : 1.0, anchor: .bottom)
                            .transition(.scale)

                        }
                    }
                    .offset(x: newMainViewModel.shouldShowSettings ? width - 90.0: 0)
                }
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button(action: {
                            newMainViewModel.shouldShowSettings.toggle()
                            shouldShowSettings = newMainViewModel.shouldShowSettings
                        }) {
                            ZStack {
                                Ellipse()
                                    .frame(width: iconSize * 2.0,
                                           height: iconSize * 2.0,
                                           alignment: .center)
                                    .foregroundColor(surface)
                                    .overlay(
                                        Ellipse()
                                            .stroke(content.opacity(0.3), lineWidth: 0.5)
                                            .frame(width: iconSize * 2.0,
                                                   height: iconSize * 2.0,
                                                   alignment: .center)
                                    )
                                Image(systemName: "line.3.horizontal")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: iconSize, height: iconSize,
                                           alignment: .center)
                                    .foregroundColor(content)
                            }
                        }
                    }

                    ToolbarItemGroup(placement: .navigationBarTrailing) {

                        ZStack {
                            Capsule()
                                .frame(width: iconSize * buttonPlatformFactor * 2,
                                       height: iconSize * buttonPlatformFactor,
                                       alignment: .center)
                                .foregroundColor(surface)
                                .overlay(
                                    Capsule()
                                        .stroke(content.opacity(0.3), lineWidth: 0.5)
                                        .frame(width: iconSize * buttonPlatformFactor * 2,
                                               height: iconSize * buttonPlatformFactor,
                                               alignment: .center)
                                )
                            HStack {
                                Button(action: {
                                    userPrefersDarkTheme.toggle()
                                }) {
                                    Image(systemName: userPrefersDarkTheme ?
                                          "sun.max.circle" : "moon.circle")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: iconSize,
                                           height: iconSize)
                                    .foregroundColor(content)
                                    .offset(x: -7, y: 0)
                                }

                                Button(action: {
                                    shouldRing.toggle()
                                    withAnimation(.spring(response: 0.5, dampingFraction: 0.3)) {
                                        bellAngle = shouldRing ? 30 : 0
                                    }

                                }) {
                                    Image(systemName: "bell")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: iconSize,
                                               height: iconSize)
                                        .foregroundColor(content)
                                        .rotationEffect(Angle(degrees: bellAngle))
                                }
                            }
                            .frame(width: iconSize * buttonPlatformFactor * 2,
                                   height: iconSize * buttonPlatformFactor)
                        }
                    }

                    ToolbarItemGroup(placement: .bottomBar) {
                        Spacer()
                        Button(action: {
                            userDidTapSend.toggle()
                        }, label: {
                            VStack(spacing: 4) {
                                Image(systemName: "paperplane")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: iconSize,
                                           height: iconSize)
                                    .foregroundColor(content)
                                    .padding(6)

                                Text("Send")
                                    .font(.caption2)
                                    .foregroundStyle(content)
                            }
                        })

                        Spacer()

                        Button(action: {
                            userDidTapBuyReceive.toggle()
                        }, label: {
                            VStack(spacing: 4) {
                                Image(systemName: "arrow.left.arrow.right")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: iconSize,
                                           height: iconSize)
                                    .foregroundColor(content)
                                    .padding(6)

                                Text("Buy/Receive")
                                    .font(.caption2)
                                    .foregroundStyle(content)
                            }
                        })

                        Spacer()

                        Button(action: {
                            // action
                        }, label: {
                            VStack(spacing: 4) {
                                Image(systemName: "gamecontroller")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: iconSize,
                                           height: iconSize)
                                    .foregroundColor(content)
                                    .padding(6)

                                Text("Game Hub")
                                    .font(.caption2)
                                    .foregroundStyle(content)
                            }
                        })

                        Spacer()

                        Button(action: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                shouldShowTransactionDetail.toggle()
                            }
                        }, label: {
                            VStack(spacing: 4) {
                                Image(systemName: "clock.arrow.trianglehead.2.counterclockwise.rotate.90")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: iconSize,
                                           height: iconSize)
                                    .foregroundColor(content)
                                    .padding(6)
                                Text("History")
                                    .font(.caption2)
                                    .foregroundStyle(content)

                            }
                        })
                        Spacer()
                    }
                }
                .toolbarBackground(.hidden, for: .bottomBar)
                .onAppear {
                    userPrefersDarkTheme = newMainViewModel.userPrefersDarkMode
                }
                .onChange(of: userPrefersDarkTheme) { preference in
                    newMainViewModel.userDidSetThemePreference(userPrefersDarkMode: preference)
                }
                .sheet(isPresented: $userDidTapSend) {
                    NewSendView(viewModel: newMainViewModel)
                        .cornerRadius(bentoCornerRadius)
                        .presentationDetents([.medium])
                        .presentationDragIndicator(.visible)
                }
                .sheet(isPresented: $userDidTapBuyReceive) {

                    BuyReceiveView(viewModel: newReceiveViewModel, isModalMode: true)
                        .cornerRadius(bentoCornerRadius)
                        .presentationDetents([.medium])
                        .presentationDragIndicator(.visible)
                }
            }
        }
    }
}
