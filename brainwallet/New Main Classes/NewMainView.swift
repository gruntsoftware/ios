//
//  NewMainView.swift
//  brainwallet
//
//  Created by Kerry Washington on 03/05/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

import SwiftUI
import FirebaseAnalytics
import BrainwalletiOSPrivateGeneralPurpose

let bentoCornerRadius: CGFloat = 14.0
let balanceGameBentoHeight: CGFloat = 130.0
let transactionsBentoHeight: CGFloat = 85.0
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

    var label: String {
        switch self {
        case .allTransactions:
            return "All"
        case .sendTransactions:
            return "Sent"
        case .receiveTransactions:
            return "Received"
        }
    }

    var icon: String {
        switch self {
        case .allTransactions:
            return "smallcircle.filled.circle"
        case .sendTransactions:
            return "arrow.up.circle"
        case .receiveTransactions:
            return "arrow.down.circle"
        }
    }

    var iconColor: Color {
        switch self {
        case .allTransactions:
            return BrainwalletColor.nearBlack
        case .sendTransactions:
            return BrainwalletColor.chili
        case .receiveTransactions:
            return BrainwalletColor.affirm
        }
    }

    mutating func toggle() {
            let nextRawValue = (self.rawValue + 1) % Self.allCases.count
            self = TransactionFilterState(rawValue: nextRawValue)!
    }
}

struct NewMainView: View {

    @ObservedObject
    var newMainViewModel: NewMainViewModel

    @ObservedObject
    var newReceiveViewModel: NewReceiveViewModel

    @State
    var cellViewModel = TransactionCellViewModel(transaction: Transaction(BRHelp().makeTransaction(),
                                                                          walletManager: WalletManager.sharedInstance,
                                                                          kvStore: nil, rate: nil)!,
                                                                          isLTCValueShown: false,
                                                                          rate: Rate(code: "", name: "", rate: 0.0, lastTimestamp: Date()),
                                                                          maxDigits: 8, isSyncing: false)

    @State
    private var userDidTapSend: Bool = false

    @State
    private var shouldShowTransactionDetail: Bool = false

    @State
    private var shouldShowExportProducts: Bool = false

    @State
    private var userDidTapBuyReceive: Bool = false

    @State
    private var shouldShowExportOptions: Bool = false

    @State
    var shouldShowSettings: Bool = false

    @State
    private var shouldRing: Bool = false

    @State
    private var bellAngle: Double = 0.0

    private let buttonSize: CGFloat = 20.0

    private let bentoPadding = 2.0

    private let buttonPlatformFactor: CGFloat = 2.1

    @State
    private var mainGradientStyle: MainGradientStyle = .lightStyle

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
            let height = geometry.size.height
            let surface = BrainwalletColor.surface
            let content = BrainwalletColor.content
            NavigationStack {
                ZStack(alignment: .bottom) {

                    if userPrefersDarkTheme {
                        GridWaveContentView(renderWidth: width, renderHeight: height, userPrefersDarkTheme: $userPrefersDarkTheme)
                            .mask(LinearGradient(gradient: Gradient(colors: mainGradientStyle.maskGradientStops),
                                                 startPoint: .top, endPoint: .bottom))
                            .edgesIgnoringSafeArea(.all)
                            .offset(x: 0, y: -20)
                    } else {
                        Color.init(#colorLiteral(red: 0.9725490196, green: 0.9803921569, blue: 0.9843137255, alpha: 1))
                        .edgesIgnoringSafeArea(.all)
                        .offset(x: 0, y: -20)
                    }

                    VStack {
                        BalanceBentoView(viewModel: newMainViewModel,
                                         userPrefersDarkTheme: $userPrefersDarkTheme)
                        .frame(height:  balanceGameBentoHeight, alignment: .top)
                        .modifier(BentoShadow(userPrefersDarkTheme: $userPrefersDarkTheme))
                        .padding(bentoPadding)
                        .padding(.top, 8)

                        if shouldShowTransactionDetail {
                            TransactionDetailBentoView(cellViewModel: $cellViewModel,
                                                       viewModel: newMainViewModel,
                                                       userPrefersDarkTheme:  $userPrefersDarkTheme,
                                                       shouldShowExportProducts: $shouldShowExportProducts)
                                .frame(maxHeight: .infinity)
                                .padding(bentoPadding)
                                .scaleEffect(x: 1.0, y: shouldShowTransactionDetail ? 1.0 : 0.0, anchor: .top)
                                .transition(.scale)
                                .modifier(BentoShadow(userPrefersDarkTheme: $userPrefersDarkTheme))

                        }
                            TransactionHistoryBentoView(
                                cellViewModel: $cellViewModel,
                            viewModel: newMainViewModel,
                                                    detailIsShowing: $shouldShowTransactionDetail,
                                                    userPrefersDarkTheme: $userPrefersDarkTheme)
                            .frame(height: transactionsBentoHeight, alignment: .top)
                            .modifier(BentoShadow(userPrefersDarkTheme: $userPrefersDarkTheme))
                            .padding(bentoPadding)

                        if !shouldShowTransactionDetail {
                            Group {
                                HStack {
                                    TutorialsBentoView(viewModel: newMainViewModel,
                                                       userPrefersDarkTheme: $userPrefersDarkTheme)
                                    .modifier(BentoShadow(userPrefersDarkTheme: $userPrefersDarkTheme))
                                    .frame(maxHeight: height * 0.4, alignment: .top)
                                    .padding(bentoPadding)

                                    VStack {
                                        LTCPriceBentoView(viewModel: newMainViewModel,
                                                          userPrefersDarkTheme: $userPrefersDarkTheme)
                                        .modifier(BentoShadow(userPrefersDarkTheme: $userPrefersDarkTheme))
                                        .padding(bentoPadding)

                                        FavouritesBentoView(viewModel: newMainViewModel,
                                                            userPrefersDarkTheme: $userPrefersDarkTheme)
                                        .modifier(BentoShadow(userPrefersDarkTheme: $userPrefersDarkTheme))
                                        .padding(bentoPadding)

                                    }
                                }
                                .frame(maxHeight: height * 0.4, alignment: .top)
                                .padding([.top,.leading, .trailing], bentoPadding)
                                GameHubBentoView(viewModel: newMainViewModel, userPrefersDarkTheme: $userPrefersDarkTheme)
                                        .frame(height: balanceGameBentoHeight, alignment: .top)
                                        .modifier(BentoShadow(userPrefersDarkTheme: $userPrefersDarkTheme))
                                        .padding(bentoPadding)
                            }
                            .scaleEffect(x: 1.0, y: shouldShowTransactionDetail ? 0.0 : 1.0, anchor: .bottom)
                            .transition(.scale)

                        }
                        Spacer()
                    }
                    .padding([.leading, .trailing], bentoPadding + 10)
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
                                    .modifier(BentoSurface(userPrefersDarkTheme: $userPrefersDarkTheme))
                                    .overlay(
                                        Ellipse()
                                            .stroke(content.opacity(0.3), lineWidth: 0.5)
                                            .frame(width: iconSize * 2.0,
                                                   height: iconSize * 2.0,
                                                   alignment: .center)
                                    )
                                    .modifier(BentoShadow(userPrefersDarkTheme: $userPrefersDarkTheme))

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
                                .modifier(BentoSurface(userPrefersDarkTheme: $userPrefersDarkTheme))
                                .overlay(
                                    Capsule()
                                        .stroke(content.opacity(0.2), lineWidth: 0.5)
                                        .frame(width: iconSize * buttonPlatformFactor * 2,
                                               height: iconSize * buttonPlatformFactor,
                                               alignment: .center)
                                )
                                .modifier(BentoShadow(userPrefersDarkTheme: $userPrefersDarkTheme))

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
                                    if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                                        if UIApplication.shared.canOpenURL(appSettings) {
                                            UIApplication.shared.open(appSettings)
                                        }
                                    }
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
                    mainGradientStyle = userPrefersDarkTheme ? .darkStyle : .lightStyle
                }
                .onChange(of: userPrefersDarkTheme) { _,preference in
                    newMainViewModel.userDidSetThemePreference(userPrefersDarkMode: preference)
                    mainGradientStyle = userPrefersDarkTheme ? .darkStyle : .lightStyle
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
                        .presentationDetents([.large])
                        .presentationDragIndicator(.visible)
                }
                .sheet(isPresented: $shouldShowExportProducts) {
                    WalletProductsModalView(data: newMainViewModel.transactionData)
                        .cornerRadius(bentoCornerRadius)
                        .presentationDetents([.medium])
                        .presentationDragIndicator(.visible)
                }
            }
        }
    }
}
