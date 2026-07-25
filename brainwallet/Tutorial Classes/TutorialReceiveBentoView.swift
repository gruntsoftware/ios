//
//  TutorialReceiveBentoView.swift
//  brainwallet
//
//  Created by Kerry Washington on 23/01/2026.
//  Copyright © 2026 Grunt Software, LTD. All rights reserved.
//

import SwiftUI

struct TutorialReceiveBentoView: View {

    @Binding
    var selectedPage: Int

    @Binding
    var userPrefersDarkTheme: Bool

    @State
    private var mainGradientStyle: MainGradientStyle = .lightStyle

    private let buttonSize: CGFloat = 20.0

    private let buttonPlatformFactor: CGFloat = 2.1

    init(selectedPage: Binding<Int>, userPrefersDarkTheme: Binding<Bool>) {
        _userPrefersDarkTheme = userPrefersDarkTheme
        _selectedPage = selectedPage

        UIPageControl.appearance().currentPageIndicatorTintColor = BrainwalletUIColor.midnight
        UIPageControl.appearance().pageIndicatorTintColor = BrainwalletUIColor.lavender

    }

    var body: some View {
        GeometryReader { geometry in

            let width = geometry.size.width
            let height = geometry.size.height

            ZStack {

                VStack(alignment: .center) {
                    HStack {
                        Spacer()
                        Image("tutorial-receive-art")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .opacity(0.8)
                            .frame(width: width, alignment: .center)
                            .accessibilityIdentifier("tutorialReceiveBentoViewImage")
                    }
                    .edgesIgnoringSafeArea([.top, .leading, .trailing])
                    Spacer()
                }
                VStack(alignment: .center) {
                    Spacer()
                    HStack {
                      Text("How to receive LTC")
                                .modifier(BWIPSBold(size: 18.0, lineLimit: 2))
                                .padding(.leading, 8)
                                .frame(alignment: .leading)
                                .foregroundStyle( userPrefersDarkTheme ? .white : .black)
                                .accessibilityIdentifier("tutorialTutorialReceiveBentoViewTitle")
                        Spacer()
                    }
                    .frame(height: height * 0.1)

                    HStack {
                      Text("Follow the easy steps to stack LTC. Get it from a friend or our partner MoonPay")
                            .modifier(BWIPSRegular(size: 15.0, lineLimit: 4))
                            .kerning(0.2)
                            .padding(.leading, 8)
                            .padding(.trailing, 10)
                            .frame(alignment: .leading)
                            .foregroundStyle( userPrefersDarkTheme ? .white : .black)
                            .accessibilityIdentifier("tutorialReceiveBentoViewDescription")
                        Spacer()
                    }
                }
                .padding(.bottom, 44)
            }
            .onAppear {
                mainGradientStyle = userPrefersDarkTheme ? .darkStyle : .lightStyle
            }
        }
    }
}
