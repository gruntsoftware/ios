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

    private let buttonSize: CGFloat = 20.0

    private let buttonPlatformFactor: CGFloat = 2.1

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
                            RoundedRectangle(cornerRadius: 8)
                                .frame(width: width * 0.25, height: 24, alignment: .center)
                                .foregroundColor(labelBackground)
                                .padding(8)
                            Text("GAME HUB")
                                .font(.system(size: 12, weight: .light, design: .default))
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)// Shrinks to 50% of original
                                .padding([.leading, .trailing], 4)
                                .frame(maxWidth: width * 0.25, maxHeight: 24, alignment: .center)
                                .foregroundColor(labelForeground)
                        }
                        Spacer()
                    }
                    Spacer()
                }

                VStack(alignment: .center) {
                    HStack {

                        Button(action: {
                            ///
                        }) {
                            VStack {
                                Text("FALLINMOJI")
                                    .font(Font.custom("BoldenVan", size: 100))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.5)// Shrinks to 50% of original
                                    .padding([.leading, .trailing], 10)
                                    .frame(maxWidth: width, maxHeight: 24, alignment: .center)
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.white,.white,
                                                     Color(red: 0.06666666666666667,
                                                           green: 0.2980392156862745,
                                                           blue: 0.8313725490196079)
                                                        .opacity(0.9)],// #114CD4
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                            }
                            .padding(.top, 20)
                        }
                        .accessibilityIdentifier("enterGamesModeButton")

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
