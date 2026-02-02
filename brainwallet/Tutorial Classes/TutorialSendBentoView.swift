//
//  TutorialSendBentoView.swift
//  brainwallet
//
//  Created by Kerry Washington on 23/01/2026.
//  Copyright © 2026 Grunt Software, LTD. All rights reserved.
//

import SwiftUI

struct TutorialSendBentoView: View {

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
                    Spacer()
                    HStack {
                      Text("How to Send Litecoin")
                                .font(.ibmPlexSansBold(size: 18.0))
                                .lineLimit(2)
                                .minimumScaleFactor(0.6)
                                .padding(.leading, 8)
                                .padding(.trailing, 10)
                                .frame(alignment: .leading)
                                .foregroundStyle( userPrefersDarkTheme ? .white : .black)
                                .accessibilityIdentifier("tutorialSendBentoViewTitle")

                        Spacer()
                    }
                    .frame(height: height * 0.1)
                    .padding(.top, 20)

                    HStack {
                      Text("Follow the easy steps to send LTC to someone else's wallet. They get it in seconds!")
                                .font(.ibmPlexSansRegular(size: 15.0))
                                .lineLimit(4)
                                .minimumScaleFactor(0.6)
                                .kerning(0.5)
                                .padding([.leading], 8)
                                .padding(.trailing, 10)
                                .frame(alignment: .leading)
                                .foregroundStyle( userPrefersDarkTheme ? .white : .black)
                                .accessibilityIdentifier("tutorialSendBentoViewDescription")
                        Spacer()
                    }
                    .padding(.top, 5)
                    Spacer()
                    HStack {
                        Image("tutorial-send-art")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: width, alignment: .leading)
                            .accessibilityIdentifier("tutorialSendBentoViewImage")
                        Spacer()
                    }
                    .edgesIgnoringSafeArea([.bottom, .leading, .trailing])
                }
            }
            .onAppear {
                mainGradientStyle = userPrefersDarkTheme ? .darkStyle : .lightStyle
            }
        }
    }
}
