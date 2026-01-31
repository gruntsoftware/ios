//
//  GameHubBentoView.swift
//  brainwallet
//
//  Created by Kerry Washington on 07/10/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

import SwiftUI

struct GameHubBentoView: View {

    @ObservedObject
    var newMainViewModel: NewMainViewModel

    @Binding
    var userPrefersDarkTheme: Bool

    @State
    private var mainGradientStyle: MainGradientStyle = .lightStyle

    @State
    private var shouldShowGameMode: Bool = false

    private let buttonSize: CGFloat = 20.0

    private let buttonPlatformFactor: CGFloat = 2.1

    private let tagLabelWidth: CGFloat = 80.0

    init(viewModel: NewMainViewModel, userPrefersDarkTheme: Binding<Bool>) {
        _userPrefersDarkTheme = userPrefersDarkTheme
        newMainViewModel = viewModel
    }
    var body: some View {
        GeometryReader { geometry in

            let width = geometry.size.width
            let labelBackground = Color.white.opacity(0.1)
            let labelForeground = Color.white

            ZStack {
                BalanceGameBackgroundView(userPrefersDarkTheme: $userPrefersDarkTheme)
                    .edgesIgnoringSafeArea(.all)

                VStack(alignment: .center) {
                    HStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 6)
                                .frame(width: tagLabelWidth, height: 18, alignment: .center)
                                .foregroundColor(labelBackground)
                                .padding(8)
                            Text("GAME HUB")
                                .font(.system(size: 10, weight: .light, design: .default))
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)// Shrinks to 50% of original
                                .padding([.leading, .trailing], 4)
                                .frame(maxWidth: width * 0.25, maxHeight: 20, alignment: .center)
                                .foregroundColor(labelForeground)
                        }
                        Spacer()
                    }
                    Spacer()
                }

                VStack(alignment: .center) {
                    HStack {

                        Button(action: {
                            shouldShowGameMode.toggle()
                        }) {
                                VStack {
                                    Text("FALLINMOJI")
                                        .font(Font.custom("BoldenVan", size: 100))
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.4)
                                        .padding([.leading, .trailing], 16)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: [.white,.white, BentoColor.gameBlue1.opacity(0.9)],
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                        )

                                    Text("CAN YOU BE #1?")
                                        .font(.system(size: 16,
                                                      weight: .regular,
                                                      design: .rounded))
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.5)
                                        .padding([.leading, .trailing], 16)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .foregroundStyle(
                                            LinearGradient(
                                                colors: [.white,.white, BentoColor.gameBlue1.opacity(0.9)],
                                                startPoint: .top,
                                                endPoint: .bottom
                                            )
                                        )

                                }
                                .fixedSize(horizontal: true, vertical: false)
                                .frame(maxWidth: width * 0.8)
                                .padding(.top, 5)
                        }
                        .accessibilityIdentifier("enterGamesModeButton")

                    }
                }
            }
            .cornerRadius(bentoCornerRadius)
            .frame(height: balanceGameBentoHeight, alignment: .center)
            .onChange(of: shouldShowGameMode) { _,_ in
                newMainViewModel.shouldShowGameMode = shouldShowGameMode
            }
            .onAppear {
                mainGradientStyle = userPrefersDarkTheme ? .darkStyle : .lightStyle
            }
        }
    }
}
