//
//  NewMainView.swift
//  brainwallet
//
//  Created by Kerry Washington on 03/05/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

import SwiftUI
import FirebaseAnalytics
import AlertToast

struct NewMainView: View {

    @Environment(\.requestReview)
    private var requestReview

    @ObservedObject
    var newMainViewModel: NewMainViewModel

    @ObservedObject
    var newReceiveViewModel: NewReceiveViewModel

    @StateObject
    var gameHubViewModel = GameHubViewModel()

    @StateObject
    var shopViewModel = ShopBentoViewModel()

    @State
    private var userDidTapSend: Bool = false

    @State
    private var shouldCustomToast: Bool = false

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

    private let pasteXMessage = String(localized: "Copied! Paste your score to X.")

    @State
    private var mainGradientStyle: MainGradientStyle = .lightStyle

    @State
    private var userPrefersDarkTheme = UserDefaults.userPreferredDarkTheme

    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    private let socialsURL = URL(string: BrainwalletSocials.linktree)!

    init(viewModel: NewMainViewModel,
         receiveViewModel: NewReceiveViewModel) {
        newMainViewModel = viewModel
        newReceiveViewModel = receiveViewModel
    }

    private func updateWidgetTheme(url: URL) -> URL {
        let theme = userPrefersDarkTheme ? "dark" : "light"

        guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return url
        }

        var queryItems = components.queryItems ?? []
        if let index = queryItems.firstIndex(where: { $0.name == "theme" }) {
            queryItems[index] = URLQueryItem(name: "theme", value: theme)
        } else {
            queryItems.append(URLQueryItem(name: "theme", value: theme))
        }
        components.queryItems = queryItems
        return components.url ?? url
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
                            LinearGradient(gradient: Gradient(colors: mainGradientStyle.maskGradientStops),
                                                     startPoint: .top, endPoint: .bottom)
                                .edgesIgnoringSafeArea(.all)
                                .offset(x: 0, y: -20)
                                .transition(.opacity)
                    } else {
                        Color.init(#colorLiteral(red: 0.9725490196, green: 0.9803921569, blue: 0.9843137255, alpha: 1))
                            .edgesIgnoringSafeArea(.all)
                            .offset(x: 0, y: -20)
                    }

                    VStack {
                        BalanceBentoView(viewModel: newMainViewModel,
                                         userPrefersDarkTheme: $userPrefersDarkTheme)
                        .frame(height:  balanceBentoHeight, alignment: .top)
                        .padding(bentoPadding)
                        .padding(.top, 10)
                        .accessibilityIdentifier("balanceBentoView")

                        if shouldShowTransactionDetail {
                            TransactionDetailBentoView(viewModel: newMainViewModel,
                                                       userPrefersDarkTheme:  $userPrefersDarkTheme)
                            .frame(maxHeight: 320, alignment: .top)
                            .padding(bentoPadding)
                            .scaleEffect(x: 1.0, y: shouldShowTransactionDetail ? 1.0 : 0.0, anchor: .top)
                            .transition(.scale)
                            .accessibilityIdentifier("transactionDetailBentoView")
                            Spacer()
                        }
                        TransactionHistoryBentoView(viewModel: newMainViewModel,
                                                    detailIsShowing: $shouldShowTransactionDetail,
                                                    userPrefersDarkTheme: $userPrefersDarkTheme)
                        .frame(height: transactionsBentoHeight, alignment: .bottom)
                        .padding(bentoPadding)
                        .accessibilityIdentifier("transactionHistoryBentoView")

                        if !shouldShowTransactionDetail {
                            Group {
                                HStack {
                                    TutorialsBentoView(viewModel: newMainViewModel,
                                                       userPrefersDarkTheme: $userPrefersDarkTheme)
                                    .frame(maxHeight: midBentoHeight * 0.9, alignment: .top)
                                    .padding(bentoPadding)
                                    .accessibilityIdentifier("tutorialsBentoView")

                                    GeometryReader { geo in

                                        let heightPadded = geo.size.height
                                        VStack(spacing: bentoPadding) {
                                            LTCPriceBentoView(viewModel: newMainViewModel,
                                                              userPrefersDarkTheme: $userPrefersDarkTheme)
                                            .frame(maxHeight: heightPadded * 0.7)
                                            .padding(bentoPadding)
                                            .accessibilityIdentifier("ltcPriceBentoView")
                                            ShopBentoView(shopBentoViewModel: shopViewModel,
                                                          newMViewModel: newMainViewModel,
                                                          userPrefersDarkTheme: $userPrefersDarkTheme)
                                            .frame(maxHeight: heightPadded * 0.3)
                                            .padding(bentoPadding)
                                            .accessibilityIdentifier("shopBentoView")
                                        }
                                    }
                                    .padding(bentoPadding)
                                }
                                .frame(maxHeight: height * 0.5, alignment: .top)
                                GameHubCarouselBentoView(viewModel: newMainViewModel,
                                                         newReceiveAddress: newReceiveViewModel.newReceiveAddress,
                                                         userPrefersDarkTheme: $userPrefersDarkTheme,
                                                         shouldShowGameSDK: $newMainViewModel.shouldShowGameSDK,
                                                         userEmojisAreSet: $gameHubViewModel.userEmojisAreSet
                                )
                                .frame(idealHeight: balanceBentoHeight * 0.9,
                                       maxHeight: balanceBentoHeight,
                                       alignment: .top)
                                .padding(bentoPadding)
                                .accessibilityIdentifier("gameHubCarouselBentoView")
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
                            newMainViewModel.updateTheme(shouldBeDark: userPrefersDarkTheme)
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
                        .sensoryFeedback(.success, trigger: userPrefersDarkTheme)  // ← test here
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
                        .disabled(walletIsSyncing)
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

                                Text("Get/Receive")
                                    .modifier(BWIPSSemiBold(size: 19.0))
                                    .foregroundStyle(content)
                            }
                        })
                        .accessibilityIdentifier("buyReceiveTabBarItem")

                        Spacer()

                        Button(action: {
                            
                            if (gameHubViewModel.userEmojisAreSet) {
                                let address = newReceiveViewModel.newReceiveAddress
                                DispatchQueue.userInitQueue.async {
                                    appDelegate.applicationController.shouldShowGameSDK(address: address)
                                }
                                Analytics.logEvent("user_did_tap_gamehub", parameters: nil)
                            } else {
                                newMainViewModel.shouldShowGameSDK.toggle()
                            }
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
                    gameHubViewModel.walletManager = newMainViewModel.walletManager
                }
                .onChange(of: newMainViewModel.filteredTransactions) { _,_ in
                    disableTransactionDetail = newMainViewModel.filteredTransactions.isEmpty
                }
                .onChange(of: newMainViewModel.userPrefersDarkMode) { _,_ in
                    userPrefersDarkTheme =  newMainViewModel.userPrefersDarkMode
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
                .onChange(of: newMainViewModel.gameExitUpdated) { _,_ in

                    if newMainViewModel.gameExitUpdated {
                            let gameExitDictionary = newMainViewModel.gameExitDictionary
                            let payload = gameExitDictionary["jsonString"] as? String
                            guard let payload = payload,
                                  let data = payload.data(using: .utf8) else {
                                return
                            }
                            guard let screenShotData = gameExitDictionary["screenshotdata"] as? Data else { return }

                            do {
                                let decodedObject = try JSONDecoder().decode(GameJSON.self, from: data)
                                let socialNetwork: String = decodedObject.socialNetwork
                                let social = SocialPostViewModel()
                                guard let image = social.image(from: screenShotData) else { return }

                                Analytics
                                    .logEvent("user_may_post_score_to_social",
                                              parameters: [
                                                "social_network": socialNetwork
                                              ])
                                if socialNetwork == "twitter" {
                                    shouldCustomToast.toggle()
                                    delay(3) {
                                        social.shareToX(image: image)
                                        shouldCustomToast.toggle()
                                    }
                                } else if socialNetwork == "instagram" {
                                    social.shareToInstagramStories(image: image)
                                }
                                newMainViewModel.gameExitUpdated = false

                            } catch {
                                print("Failed to decode payload: \(error)")
                            }
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
                .sheet(isPresented: $newMainViewModel.shouldShowBuyReceive) {
                    BuyReceiveView(viewModel: newReceiveViewModel, isModalMode: true)
                        .cornerRadius(bentoCornerRadius)
                        .presentationDetents([.large])
                        .presentationDragIndicator(.visible)
                }
                .sheet(isPresented: $newMainViewModel.shouldShowSocials) {
                    WebView(url: socialsURL, scrollToSignup: .constant(false))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .cornerRadius(8.0)
                        .padding(.top, 12.0)
                        .padding(8.0)
                }
                .sheet(isPresented: $newMainViewModel.shouldShowShop) {
                    WebView(url: updateWidgetTheme(url: shopViewModel.widgetURL), scrollToSignup: .constant(false))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .cornerRadius(8.0)
                        .padding(.top, 12.0)
                        .padding(8.0)
                }
                .sheet(isPresented: $newMainViewModel.shouldShowGameSDK) {
                    if (!gameHubViewModel.userEmojisAreSet) {
                        EmojiSetPagerView(gameHubViewModel: gameHubViewModel,
                                          viewModel: newMainViewModel)
                        .presentationBackground(.ultraThinMaterial)
                        .presentationDragIndicator(.hidden)
                    }
                }
                .onChange(of: gameHubViewModel.didJustCompleteEmojiSetup) { _, newValue in
                    guard newValue else { return }
                    let address = newReceiveViewModel.newReceiveAddress
                    DispatchQueue.userInitQueue.async {
                        appDelegate.applicationController.shouldShowGameSDK(address: address)
                    }
                    gameHubViewModel.didJustCompleteEmojiSetup = false
                }
                .alert(isPresented: $shouldShowPromptAlert) {
                    Alert(title: Text(currentPrompt.title),
                          message: Text(currentPrompt.body),
                          dismissButton: .default(Text(String(localized: "Ok")),
                                                  action: { shouldShowPromptAlert = false }))
                }
                .toast(isPresenting: $shouldCustomToast){
                    AlertToast(type: .regular, title: pasteXMessage)
                }
            }
        }
    }
}
