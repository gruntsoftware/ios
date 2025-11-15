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
let balanceGameBentoHeight: CGFloat = 135.0
let transactionsBentoHeight: CGFloat = 85.0
let iconSize: CGFloat = 20.0

struct NewMainView: View {

    @ObservedObject
    var newMainViewModel: NewMainViewModel

    @ObservedObject
    var newReceiveViewModel: NewReceiveViewModel

    @State
    var cellViewModel: TransactionCellViewModel?

    @State
    private var userDidTapSend: Bool = false

    @State
    private var shouldShowTransactionDetail: Bool = false

    @State
    private var disableTransactionDetail: Bool = false

    @State
    private var userDidTapBuyReceive: Bool = false

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

    @State
    private var mainGradientStyle: MainGradientStyle = .lightStyle

    @State
    private var userPrefersDarkTheme = UserDefaults.userPreferredDarkTheme

    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    init(viewModel: NewMainViewModel,
         receiveViewModel: NewReceiveViewModel) {
        newMainViewModel = viewModel
        newReceiveViewModel = receiveViewModel
        if let transaction = Transaction(BRHelp().makeTransaction(),
                                         walletManager: WalletManager.sharedInstance,
                                         kvStore: nil, rate: nil) {

            cellViewModel =  TransactionCellViewModel(transaction: transaction,
                                                      isLTCValueShown: false,
                                                      rate: Rate(code: "", name: "",
                                                                 rate: 0.0, lastTimestamp: Date()),
                                                      maxDigits: 8, isSyncing: false)
        }
    }
    var body: some View {
        GeometryReader { geometry in

            let width = geometry.size.width
            let height = geometry.size.height
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

                        if shouldShowTransactionDetail {
                            TransactionDetailBentoView(cellViewModel: $cellViewModel,
                                                       viewModel: newMainViewModel,
                                                       userPrefersDarkTheme:  $userPrefersDarkTheme)
                                .frame(maxHeight: .infinity)
                                .padding(bentoPadding)
                                .scaleEffect(x: 1.0, y: shouldShowTransactionDetail ? 1.0 : 0.0, anchor: .top)
                                .transition(.scale)

                        }
                            TransactionHistoryBentoView(
                                cellViewModel: $cellViewModel,
                            viewModel: newMainViewModel,
                                                    detailIsShowing: $shouldShowTransactionDetail,
                                                    userPrefersDarkTheme: $userPrefersDarkTheme)
                            .frame(height: transactionsBentoHeight, alignment: .top)
                            .padding(bentoPadding)

                        if !shouldShowTransactionDetail {
                            Group {
                                HStack {
                                    TutorialsBentoView(viewModel: newMainViewModel,
                                                       userPrefersDarkTheme: $userPrefersDarkTheme)
                                    .frame(maxHeight: height * 0.5, alignment: .top)
                                    .padding(bentoPadding)

                                    VStack {
                                        LTCPriceBentoView(viewModel: newMainViewModel,
                                                          userPrefersDarkTheme: $userPrefersDarkTheme)
                                        .frame(maxHeight: height * 0.25)
                                        .padding(bentoPadding)

                                        FavouritesBentoView(viewModel: newMainViewModel,
                                                            userPrefersDarkTheme: $userPrefersDarkTheme)
                                        .frame(maxHeight: height * 0.25)
                                        .padding(bentoPadding)

                                    }
                                }
                                .frame(maxHeight: height * 0.5, alignment: .top)
                                .padding([.top,.leading, .trailing], bentoPadding)
                                GameHubBentoView(viewModel: newMainViewModel, userPrefersDarkTheme: $userPrefersDarkTheme)
                                        .frame(height: balanceGameBentoHeight, alignment: .top)
                                        .padding(bentoPadding)
                            }
                            .scaleEffect(x: 1.0, y: shouldShowTransactionDetail ? 0.0 : 1.0, anchor: .bottom)
                            .transition(.scale)

                        }
                        Spacer()
                    }
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
                            shouldShowGameMode.toggle()
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
                        .disabled(disableTransactionDetail)
                        Spacer()
                    }
                }
                .toolbarBackground(.hidden, for: .bottomBar)
                .onAppear {
                    userPrefersDarkTheme = newMainViewModel.userPrefersDarkMode
                    mainGradientStyle = userPrefersDarkTheme ? .darkStyle : .lightStyle
                }
                .onChange(of: shouldShowGameMode) { _,_ in
                    newMainViewModel.shouldShowGameMode = shouldShowGameMode
                }
                .onChange(of: newMainViewModel.filteredTransactions) { _,_ in
                    disableTransactionDetail = newMainViewModel.filteredTransactions.isEmpty
                }
                .onChange(of: userPrefersDarkTheme) { preference in
                    newMainViewModel.userDidSetThemePreference(userPrefersDarkMode: preference)
                    mainGradientStyle = userPrefersDarkTheme ? .darkStyle : .lightStyle
                }
                .sheet(isPresented: $userDidTapSend) {
                    BentoSendModalView(viewModel: newMainViewModel,
                                       userPrefersDarkTheme: $userPrefersDarkTheme)
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
                .alert(isPresented: $shouldShowPromptAlert) {
                    Alert(title: Text(currentPrompt.title),
                          message: Text(currentPrompt.body),
                          primaryButton: .default(Text("Okay"),
                                        action: {
                                        print("Ok CLICK")
                                }),
                          secondaryButton: .destructive(Text("Dismiss (Desctructive)")))
                }
            }
        }
    }
}
