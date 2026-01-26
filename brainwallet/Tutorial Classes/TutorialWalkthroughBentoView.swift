//
//  TutorialWalkthroughBentoView.swift
//  brainwallet
//
//  Created by Kerry Washington on 23/01/2026.
//  Copyright © 2026 Grunt Software, LTD. All rights reserved.
//

import SwiftUI

struct TutorialWalkthroughBentoView: View {

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
                      Text("Brainwallet Walkthrough")
                                .font(.system(size: 18, weight: .bold, design: .default))
                                .lineLimit(2)
                                .minimumScaleFactor(0.9)
                                .padding(.leading, 8)
                                .padding(.trailing, 10)
                                .frame(alignment: .leading)
                                .foregroundStyle( userPrefersDarkTheme ? .white : .black)
                        Spacer()
                    }
                    .frame(height: height * 0.2)
                    .padding(.top, 15)

                    HStack {
                      Text("Try all features of the Brainwallet, from sending and receiving crypto to managing your keys.")
                                .font(.system(size: 15, weight: .regular, design: .default))
                                .lineLimit(4)
                                .minimumScaleFactor(0.9)
                                .kerning(0.5)
                                .padding([.leading], 8)
                                .padding(.trailing, 10)
                                .frame(alignment: .leading)
                                .foregroundStyle( userPrefersDarkTheme ? .white : .black)
                        Spacer()
                    }
                    .padding(.top, 5)
                    HStack {
                        Image("tutorial-fruits-art")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: width * 0.8, alignment: .center)
                        Spacer()
                    }
                    Spacer()
                }
            }
            .onAppear {
                mainGradientStyle = userPrefersDarkTheme ? .darkStyle : .lightStyle
            }
        }
    }
}
