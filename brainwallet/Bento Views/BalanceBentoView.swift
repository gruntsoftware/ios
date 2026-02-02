//
//  BalanceBentoView.swift
//  brainwallet
//
//  Created by Kerry Washington on 07/10/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

import SwiftUI
import FirebaseAnalytics

struct BalanceBentoView: View {
    @ObservedObject
    var newMainViewModel: NewMainViewModel
    @State
    private var shouldShowSettings: Bool = false
    @State
    private var shouldShowBalance: Bool = true
    @State
    private var isLTCValueShown: Bool = false
    @Binding
    var userPrefersDarkTheme: Bool
    @State
    private var mainGradientStyle: MainGradientStyle = .lightStyle
    private let buttonSize: CGFloat = 20.0
    private let buttonPlatformFactor: CGFloat = 2.1
    private let sidePadding: CGFloat = 16.0

    init(viewModel: NewMainViewModel, userPrefersDarkTheme: Binding<Bool>) {
        _userPrefersDarkTheme = userPrefersDarkTheme
        newMainViewModel = viewModel
    }

    var body: some View {
        GeometryReader { geometry in

            let width = geometry.size.width
            let height = geometry.size.height

            ZStack {
                BalanceBackgroundView(userPrefersDarkTheme: $userPrefersDarkTheme)
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    HStack {
                        SyncSubBentoView(viewModel: SyncSubBentoViewModel(store: newMainViewModel.store,
                                                                          walletManager: newMainViewModel.walletManager))
                    }
                    .padding([.leading, .trailing], sidePadding)
                }

                VStack {
                    HStack {
                        Text("MY BALANCE")
                            .font(.ibmPlexSansSemiBold(size: 16.0))
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)// Shrinks to 80% of original
                            .frame(maxWidth: .infinity, alignment: .topLeading)
                            .foregroundColor(Color.white.opacity(0.70))
                        Spacer()
                        Button(action: {
                            shouldShowBalance.toggle()
                        }) {
                            Image(systemName: shouldShowBalance ? "eye.slash" : "eye")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(Color.white)
                                .frame(width: buttonSize,
                                       height: buttonSize,
                                       alignment: .center)
                        }
                        .frame(width: buttonSize * 1.5, height: buttonSize * 1.5)
                        .accessibilityIdentifier("hideBalanceToggleButton")
                        .background(Color.white.opacity(0.07))
                        .cornerRadius(8)
                     }
                    .padding(.top, 24)
                    .padding([.leading, .trailing], sidePadding)
                    .frame(height: height * 0.25)

                    HStack {
                        ZStack {
                            VStack {
                                Text(shouldShowBalance ? "\(newMainViewModel.walletBalanceLitecoin)" : "")
                                    .font(isLTCValueShown ? .ibmPlexSansThin(size: 12.0) : .ibmPlexSansBold(size: 35.0))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(Color.white)
                                    .contentTransition(.identity)
                                    .offset(y: isLTCValueShown ? 45 : 0)
                                    .zIndex(isLTCValueShown ? 0 : 1)
                                Spacer()
                            }
                            .frame(height: height * 0.75)

                            VStack {
                                Text(shouldShowBalance ? "\(newMainViewModel.walletBalanceFiat)" : "")
                                    .font( isLTCValueShown ? .system(size: 35, weight: .bold, design: .default) :
                                            .system(size: 12, weight: .light, design: .default))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(Color.white)
                                    .contentTransition(.identity)
                                    .offset(y: isLTCValueShown ? 0 : 45)
                                    .zIndex(isLTCValueShown ? 1 : 0)
                                Spacer()
                            }
                            .frame(height: height * 0.75)
                        }
                    }
                    .padding([.leading, .trailing], sidePadding)
                    .frame(width: width, height: height * 0.75)
                    .onTapGesture {
                        if shouldShowBalance {
                            withAnimation(.spring(response: 0.8, dampingFraction: 0.5, blendDuration: 0.2)) {
                                isLTCValueShown.toggle()
                                newMainViewModel.isLTCValueShown = isLTCValueShown
                                Analytics
                                    .logEvent("user_tapped_switch_fiat_ltc",
                                    parameters: [
                                        "platform": "ios",
                                        "app_version": AppVersion.string
                                    ])
                            }
                        }
                    }
                }
            }
            .cornerRadius(bentoCornerRadius)
            .frame(height: balanceGameBentoHeight, alignment: .center)
            .onAppear {
                mainGradientStyle = userPrefersDarkTheme ? .darkStyle : .lightStyle
            }
        }
    }
}
