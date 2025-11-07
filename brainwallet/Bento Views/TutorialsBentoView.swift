//
//  TutorialsBentoView.swift
//  brainwallet
//
//  Created by Kerry Washington on 07/10/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

import SwiftUI

struct TutorialsBentoView: View {

    @ObservedObject
    var newMainViewModel: NewMainViewModel

    @State
    private var shouldShowSettings: Bool = false

    @State
    private var selectedPage: Int = 0

    @Binding
    var userPrefersDarkTheme: Bool

    @State
    private var mainGradientStyle: MainGradientStyle = .lightStyle

    private let buttonSize: CGFloat = 20.0

    private let buttonPlatformFactor: CGFloat = 2.1

    init(viewModel: NewMainViewModel, userPrefersDarkTheme: Binding<Bool>) {
        _userPrefersDarkTheme = userPrefersDarkTheme
        newMainViewModel = viewModel

        UIPageControl.appearance().currentPageIndicatorTintColor = BrainwalletUIColor.midnight
        UIPageControl.appearance().pageIndicatorTintColor = BrainwalletUIColor.lavender

    }

    @ViewBuilder
    func formattedText(_ text: String, backgroundColor: Color = Color.clear, foregroundColor: Color = BrainwalletColor.nearBlack) -> some View {

        VStack {
            Text(text)
                .font(.system(size: 12, weight: .semibold, design: .default))
                .lineLimit(1)
                .minimumScaleFactor(0.5)// Shrinks to 50% of original
                .padding([.leading, .trailing], 4)

            Text("1. ")
                .font(.system(size: 12, weight: .light, design: .default))
                .lineLimit(1)
                .minimumScaleFactor(0.5)// Shrinks to 50% of original
                .padding([.leading, .trailing], 4)
            Text("2. ")
                .font(.system(size: 12, weight: .light, design: .default))
                .lineLimit(1)
                .minimumScaleFactor(0.5)// Shrinks to 50% of original
                .padding([.leading, .trailing], 4)
            Text("3. ")
                .font(.system(size: 12, weight: .light, design: .default))
                .lineLimit(1)
                .minimumScaleFactor(0.5)// Shrinks to 50% of original
                .padding([.leading, .trailing], 4)
        }
    }
    var body: some View {
        GeometryReader { geometry in

            let width = geometry.size.width
            let labelBackground =  userPrefersDarkTheme ? BrainwalletColor.content.opacity(0.1) : BentoColor.tutorialGreen1
            let labelForeground = userPrefersDarkTheme ? BrainwalletColor.content : BentoColor.tutorialGreen2

            ZStack {
                BentoBackgroundView(userPrefersDarkTheme: $userPrefersDarkTheme).edgesIgnoringSafeArea(.all)
                VStack(alignment: .center) {
                    HStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .frame(width: width * 0.5, height: 22, alignment: .center)
                                .foregroundColor(labelBackground)
                                .padding(8)
                            Text("TUTORIALS")
                                .font(.system(size: 12, weight: .light, design: .default))
                                .lineLimit(1)
                                .minimumScaleFactor(0.5)// Shrinks to 50% of original
                                .padding([.leading, .trailing], 4)
                                .frame(maxWidth: width * 0.5, maxHeight: 24, alignment: .center)
                                .foregroundColor(labelForeground)
                        }
                        Spacer()
                    }
                    Spacer()
                }

                TabView(selection: $selectedPage) {
                        formattedText("How to send").tag(0)
                            .tabItem {
                                Text("Sending is easy!")
                            }

                        formattedText("How to receive").tag(1)
                            .tabItem {
                                Text("Receive Litecoin in seconds")
                            }

                        formattedText("Top Up").tag(2)
                            .tabItem {
                                Text("Load with MoonPay")
                            }

                    }
                .tabViewStyle(.page)

            }
            .cornerRadius(bentoCornerRadius)
            .onAppear {
                mainGradientStyle = userPrefersDarkTheme ? .darkStyle : .lightStyle
            }
        }
    }
}
