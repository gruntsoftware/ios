//
//  TutorialWalkthroughPageView.swift
//  brainwallet
//
//  Created by Kerry Washington on 23/01/2026.
//  Copyright © 2026 Grunt Software, LTD. All rights reserved.
//
import SwiftUI

struct TutorialWalkthroughPageView: View {

    @State
    private var selectedStep: Int = 0

    @Binding
    var userPrefersDarkTheme: Bool

    @State
    private var mainGradientStyle: MainGradientStyle = .lightStyle

    @State
    private var userDidTapMP: Bool = false

    private let buttonSize: CGFloat = 20.0

    private let buttonPlatformFactor: CGFloat = 2.1

    init(userPrefersDarkTheme: Binding<Bool>) {
        _userPrefersDarkTheme = userPrefersDarkTheme
        UIPageControl.appearance().currentPageIndicatorTintColor = BrainwalletUIColor.midnight
        UIPageControl.appearance().pageIndicatorTintColor = BrainwalletUIColor.lavender
    }

    var body: some View {
        GeometryReader { _ in

            ZStack {
                VStack(alignment: .center) {
                    HStack {
                        Text("Brainwallet Walkthrough")
                            .font(.system(size: 24, weight: .semibold, design: .default))
                            .foregroundColor(.white)
                            .padding([.leading, .trailing], 4)
                            .accessibilityIdentifier("tutorialWalkthroughPageViewTitle")

                    }
                    .padding(24)
                    Spacer()
                }
                TabView(selection: $selectedStep) {

                    WalkthroughStep1View(selectedStep: $selectedStep,
                                         userPrefersDarkTheme: $userPrefersDarkTheme)
                    .tag(0)
                    WalkthroughStep2View(selectedStep: $selectedStep,
                                         userPrefersDarkTheme: $userPrefersDarkTheme)
                    .tag(1)
                    WalkthroughStep3View(selectedStep: $selectedStep,
                                         userPrefersDarkTheme: $userPrefersDarkTheme)
                    .tag(2)
                    WalkthroughStep4View(selectedStep: $selectedStep,
                                         userPrefersDarkTheme: $userPrefersDarkTheme)
                    .tag(3)
                    WalkthroughStep5View(selectedStep: $selectedStep,
                                         userPrefersDarkTheme: $userPrefersDarkTheme)
                    .tag(4)
                }
                .tabViewStyle(.page)
                .indexViewStyle(.page(backgroundDisplayMode: .always))
            }
            .cornerRadius(bentoCornerRadius)
            .onAppear {
                mainGradientStyle = userPrefersDarkTheme ? .darkStyle : .lightStyle
            }
            .onChange(of: userDidTapMP) { _,_ in
                /// TBD
            }
        }
    }
}
