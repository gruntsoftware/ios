//
//  BalanceBentoView.swift
//  brainwallet
//
//  Created by Kerry Washington on 07/10/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

import SwiftUI

struct BalanceBentoView: View {
    @ObservedObject
    var newMainViewModel: NewMainViewModel
    @Environment(\.requestReview)
    private var requestReview
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
    
    private func playBoing() {
        SoundsHelper().play(filename: "boingspringmouthharp042013", type: "mp3")
    }

    var body: some View {
        GeometryReader { geometry in

            let width = geometry.size.width
            let height = geometry.size.height

            ZStack {
                BalanceBackgroundView(userPrefersDarkTheme: $userPrefersDarkTheme)
                    .edgesIgnoringSafeArea(.all)
                VStack {
                    Spacer()
                    HStack {
                        SyncSubBentoView(viewModel: SyncSubBentoViewModel(store: newMainViewModel.store,
                                                                          walletManager: newMainViewModel.walletManager))
                    }
                    .frame(maxHeight: .infinity, alignment: .bottom)
                    .padding([.leading, .trailing], sidePadding)
                }
                .frame(maxHeight: .infinity, alignment: .bottom)
                VStack(alignment: .leading, spacing: 0) {
                    HStack {
                        Text("MY BALANCE")
                            .modifier(BWIPSRegular(size: 12.0))
                            .frame(maxWidth: .infinity, alignment: .topLeading)
                            .foregroundColor(Color.white.opacity(0.70))
                        Spacer()
                        Button(action: {
                            shouldShowBalance.toggle()
                            playBoing()
                            if BalanceBentoReviewPolicy
                                .shouldRequestReview(afterTogglingBalanceVisibilityTo: shouldShowBalance) {
                                delay(0.8) {
                                    requestReview()
                                    debugPrint("did_request_rating")
                                }
                            }
                        }) {
                            Image(systemName: shouldShowBalance ? "eye.slash" : "eye")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .foregroundColor(Color.white)
                                .frame(width: buttonSize,
                                       height: buttonSize,
                                       alignment: .bottom)
                        }
                        .frame(width: buttonSize * 1.5, height: buttonSize * 1.5)
                        .accessibilityIdentifier("hideBalanceToggleButton")
                        .background(Color.white.opacity(0.07))
                        .cornerRadius(8)
                     }
                    .padding([.leading, .trailing], sidePadding)
                    .frame(width: width, height: height * 0.25, alignment: .top)
                    HStack {
                        ZStack {
                            VStack {
                                Text(shouldShowBalance ? "\(newMainViewModel.walletBalanceLitecoin)" : "")
                                    .font(isLTCValueShown ? .ibmPlexSansThin(size: 12.0) : .ibmPlexSansBold(size: 29.0))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(Color.white)
                                    .contentTransition(.identity)
                                    .offset(y: isLTCValueShown ? 40 : 0)
                                    .zIndex(isLTCValueShown ? 0 : 1)
                                Spacer()

                            }
                            .frame(maxHeight: 50.0, alignment: .top)
                            VStack {
                                Text(shouldShowBalance ? "\(newMainViewModel.walletBalanceFiat)" : "")
                                    .font(isLTCValueShown ? .ibmPlexSansBold(size: 29.0) : .ibmPlexSansThin(size: 12.0))
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(Color.white)
                                    .contentTransition(.identity)
                                    .offset(y: isLTCValueShown ? 0 : 40)
                                    .zIndex(isLTCValueShown ? 1 : 0)
                                Spacer()
                            }
                            .frame(maxHeight: 50.0, alignment: .top)
                        }
                    }
                    .padding([.leading, .trailing], sidePadding)
                    .frame(width: width, height: height * 0.75, alignment: .top)
                    .onTapGesture {
                        if shouldShowBalance {
                            withAnimation(.spring(response: 0.8, dampingFraction: 0.5, blendDuration: 0.2)) {
                                isLTCValueShown.toggle()
                                newMainViewModel.isLTCValueShown = isLTCValueShown
                            }
                            if BalanceBentoReviewPolicy.shouldRequestReview(afterTogglingCurrencyEmphasisTo: isLTCValueShown) {
                                delay(0.8) {
                                    requestReview()
                                    debugPrint("did_request_rating")
                                }
                            }
                        }
                    }
                    .layoutPriority(1)
                    .accessibilityIdentifier("balanceFiatToggleButton")

                    Spacer()
                }

            }
            .cornerRadius(bentoCornerRadius)
            .frame(minHeight: balanceBentoHeight, idealHeight: balanceBentoHeight * 1.2, maxHeight: balanceBentoHeight * 1.4, alignment: .center)
            .onAppear {
                mainGradientStyle = userPrefersDarkTheme ? .darkStyle : .lightStyle
            }
        }
    }
}
