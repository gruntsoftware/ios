//
//  NewMainView.swift
//  brainwallet
//
//  Created by Kerry Washington on 03/05/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

import SwiftUI
import FirebaseAnalytics

struct NewMainView: View {

    @ObservedObject
    var newMainViewModel: NewMainViewModel

    @ObservedObject
    var newReceiveViewModel: NewReceiveViewModel

    @State
    private var userDidTapSend: Bool = false

    @State
    private var userDidTapSendWhileSyncing: Bool = false

    @State
    private var shouldShowTransactionDetail: Bool = false

    @State
    private var disableTransactionDetail: Bool = false

    @State
    private var userDidTapBuyReceive: Bool = false

    @State
    private var userBalanceIsEmpty: Bool = true

    @State
    private var walletIsSyncing: Bool = true

    @State
    private var shouldShowExportOptions: Bool = false

    @State
    private var shouldShowGameMode: Bool = false

    @State
    private var shouldShowPromptAlert: Bool = false

    @State
    private var currentPrompt: PromptType = .noPrompt

    @State
    var shouldShowSettings: Bool = false

    @State
    private var shouldRing: Bool = false

    @State
    private var bellAngle: Double = 0.0

    private let buttonSize: CGFloat = 20.0

    private let bentoPadding = 2.0

    private let buttonPlatformFactor: CGFloat = 2.1

    private let noSendTitle = String(localized: "Send is Disabled")

    private let noSendMessage = """
                                While syncing, send is disabled the \
                                database catchs up to the latest block.\nPlease try again later.
                                """

    @State
    private var mainGradientStyle: MainGradientStyle = .lightStyle

    @State
    private var userPrefersDarkTheme = UserDefaults.userPreferredDarkTheme

    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    init(viewModel: NewMainViewModel,
         receiveViewModel: NewReceiveViewModel) {
        newMainViewModel = viewModel
        newReceiveViewModel = receiveViewModel
    }

    var body: some View {
        GeometryReader { geometry in

            let width = geometry.size.width
            let height = geometry.size.height
            let midBentoHeight = geometry.size.height
            let sheetContentHeight = height * 0.7
            let mainTabIconSize: CGFloat = 26.0

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
                        .padding(bentoPadding)
                        .padding(.top, 10)
                        .padding(.bottom, 10)
                        .accessibilityIdentifier("balanceBentoView")

                        if shouldShowTransactionDetail {
                            TransactionDetailBentoView(viewModel: newMainViewModel,
                                                       userPrefersDarkTheme:  $userPrefersDarkTheme)
                                .frame(maxHeight: .infinity)
                                .padding(bentoPadding)
                                .scaleEffect(x: 1.0, y: shouldShowTransactionDetail ? 1.0 : 0.0, anchor: .top)
                                .transition(.scale)
                                .accessibilityIdentifier("transactionDetailBentoView")
                        }
                            TransactionHistoryBentoView(viewModel: newMainViewModel,
                                                    detailIsShowing: $shouldShowTransactionDetail,
                                                    userPrefersDarkTheme: $userPrefersDarkTheme)
                            .frame(height: transactionsBentoHeight, alignment: .top)
                            .padding(bentoPadding)
                            .accessibilityIdentifier("transactionHistoryBentoView")

                        if !shouldShowTransactionDetail {
                            Group {
                                HStack {
                                    TutorialsBentoView(viewModel: newMainViewModel,
                                                       userPrefersDarkTheme: $userPrefersDarkTheme)
                                    .frame(maxHeight: midBentoHeight * 0.5, alignment: .top)
                                    .padding(bentoPadding)
                                    .accessibilityIdentifier("tutorialsBentoView")

                                    VStack {
                                        LTCPriceBentoView(viewModel: newMainViewModel,
                                                          userPrefersDarkTheme: $userPrefersDarkTheme)
                                        .frame(maxHeight: midBentoHeight * 0.25)
                                        .padding(bentoPadding)
                                        .accessibilityIdentifier("ltcPriceBentoView")

                                        FavouritesBentoView(viewModel: newMainViewModel,
                                                            userPrefersDarkTheme: $userPrefersDarkTheme)
                                        .frame(maxHeight: midBentoHeight * 0.25)
                                        .padding(bentoPadding)
                                        .accessibilityIdentifier("favouritesBentoView")
                                    }
                                }
                                .frame(maxHeight: height * 0.5, alignment: .top)
                                .padding([.top,.leading, .trailing], bentoPadding)
                                GameHubBentoView(viewModel: newMainViewModel, userPrefersDarkTheme: $userPrefersDarkTheme)
                                        .frame(height: balanceGameBentoHeight, alignment: .top)
                                        .padding(bentoPadding)
                                        .accessibilityIdentifier("gameHubBentoView")
                            }
                            .scaleEffect(x: 1.0, y: shouldShowTransactionDetail ? 0.0 : 1.0, anchor: .bottom)
                            .transition(.scale)

                        }
                        Spacer()
                    }
                    .frame(maxHeight: .infinity, alignment: .init(horizontal: .center, vertical: .top))
                    .padding([.leading, .trailing], bentoPadding + 10)
                }
                .toolbar {

                    ToolbarItem(placement: .navigationBarLeading) {
                            Button(action: {
                                 userPrefersDarkTheme.toggle()
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

                                    Image(systemName: userPrefersDarkTheme ?
                                          "sun.max" : "moon.stars")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: iconSize,
                                           height: iconSize)
                                    .foregroundColor(content)
                                }
                            }
                            .accessibilityIdentifier("themePreferenceButton")

                    }

                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            newMainViewModel.shouldShowSettings.toggle()
                            shouldShowSettings = newMainViewModel.shouldShowSettings
                            newMainViewModel.userDidTapTheSettingsButton()
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

                                Image(systemName: "line.3.horizontal")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: iconSize, height: iconSize,
                                           alignment: .center)
                                    .foregroundColor(content)
                            }

                        }
                        .accessibilityIdentifier("settingsButton")
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
                                    .frame(width: mainTabIconSize,
                                           height: mainTabIconSize)
                                    .foregroundColor( walletIsSyncing ? content.opacity(0.3) : content)
                                    .padding(6)

                                Text("Send")
                                    .modifier(BWIPSSemiBold(size: 19.0))
                                    .foregroundStyle(walletIsSyncing ? content.opacity(0.3) : content)
                            }
                        })
                        .accessibilityIdentifier("sendTabBarItem")

                        Spacer()

                        Button(action: {
                            userDidTapBuyReceive.toggle()
                        }, label: {
                            VStack(spacing: 4) {
                                Image(systemName: "arrow.left.arrow.right")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: mainTabIconSize,
                                           height: mainTabIconSize)
                                    .foregroundColor(content)
                                    .padding(6)

                                Text("Buy/Receive")
                                    .modifier(BWIPSSemiBold(size: 19.0))
                                    .foregroundStyle(content)
                            }
                        })
                        .accessibilityIdentifier("buyReceiveTabBarItem")

                        Spacer()

                        Button(action: {
                            shouldShowGameMode.toggle()
                            Analytics.logEvent("user_did_tap_gamemode",
                                parameters: [
                                    "platform": "ios",
                                    "app_version": AppVersion.string
                                ])
                        }, label: {
                            VStack(spacing: 4) {
                                Image(systemName: "gamecontroller")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: mainTabIconSize,
                                           height: mainTabIconSize)
                                    .foregroundColor(content)
                                    .padding(6)

                                Text("Game Hub")
                                    .modifier(BWIPSSemiBold(size: 19.0))
                                    .foregroundStyle(content)
                            }
                        })
                        .accessibilityIdentifier("gameHubTabBarItem")

                        Spacer()

                        Button(action: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                shouldShowTransactionDetail.toggle()
                            }
                        }, label: {
                            VStack(spacing: 4) {
                                Image(systemName: shouldShowTransactionDetail ? "house" : "clock.arrow.trianglehead.2.counterclockwise.rotate.90")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: mainTabIconSize,
                                           height: mainTabIconSize)
                                    .foregroundColor(content)
                                    .padding(6)
                                    .animation(.easeInOut, value: shouldShowTransactionDetail)

                                Text(shouldShowTransactionDetail ? " Home " :"History")
                                    .modifier(BWIPSSemiBold(size: 19.0))
                                    .foregroundStyle(content)
                                    .contentTransition(.opacity)
                                    .animation(.easeInOut, value: shouldShowTransactionDetail)
                            }
                        })
                        .disabled(disableTransactionDetail)
                        .accessibilityIdentifier("historyHubTabBarItem")

                        Spacer()
                    }
                }
                .toolbarBackground(.hidden, for: .bottomBar)
                .onAppear {
                    userPrefersDarkTheme = newMainViewModel.userPrefersDarkMode
                    mainGradientStyle = userPrefersDarkTheme ? .darkStyle : .lightStyle
                    walletIsSyncing = newMainViewModel.walletIsSyncing
                }
                .onChange(of: shouldShowGameMode) { _,_ in
                    newMainViewModel.shouldShowGameMode = shouldShowGameMode
                }
                .onChange(of: newMainViewModel.filteredTransactions) { _,_ in
                    disableTransactionDetail = newMainViewModel.filteredTransactions.isEmpty
                }
                .onChange(of: userPrefersDarkTheme) { _,newPreference in
                    newMainViewModel.userDidSetThemePreference(userPrefersDarkMode: newPreference)
                    mainGradientStyle = userPrefersDarkTheme ? .darkStyle : .lightStyle
                }
                .onChange(of: newMainViewModel.walletIsSyncing) { _,newState in
                    walletIsSyncing = newState
                }
                .onChange(of: newMainViewModel.userWantsToTopUp) { _,newState in
                    if newState {
                        userDidTapBuyReceive.toggle()
                    }
                }
                .sheet(isPresented: $userDidTapSend) {
                 if !walletIsSyncing {
                        BentoSendModalView(viewModel: newMainViewModel,
                                           userPrefersDarkTheme: $userPrefersDarkTheme,
                                           userWalletIsEmpty: $userBalanceIsEmpty,
                                           shouldShowView: $userDidTapSend)
                        .cornerRadius(bentoCornerRadius)
                        .presentationDragIndicator(.hidden)
                        .presentationDetents([.height(sheetContentHeight)])
                        .presentationBackground(.ultraThickMaterial)
                        .ignoresSafeArea(edges: .bottom)
                  } else {
                      BentoNoSendModalView(userPrefersDarkTheme: $userPrefersDarkTheme,
                                           shouldShowView: $userDidTapSend)
                        .cornerRadius(bentoCornerRadius)
                        .presentationDragIndicator(.hidden)
                        .presentationDetents([.height(height * 0.4)])
                        .presentationBackground(.ultraThickMaterial)
                        .ignoresSafeArea(edges: .bottom)
                    }
                }
                .sheet(isPresented: $userDidTapBuyReceive) {
                    BuyReceiveView(viewModel: newReceiveViewModel, isModalMode: true)
                        .cornerRadius(bentoCornerRadius)
                        .presentationDetents([.large])
                        .presentationDragIndicator(.visible)
                }
                .alert(isPresented: $shouldShowPromptAlert) {
                    Alert(title: Text(currentPrompt.title),
                          message: Text(currentPrompt.body),
                          dismissButton: .default(Text(String(localized: "Ok")),
                                         action: { shouldShowPromptAlert = false }))
                }
            }
        }
    }
}
