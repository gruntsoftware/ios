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
    private var selectedPage: Int = 0

    @State
    private var shouldShowSendPage: Bool = false

    @State
    private var shouldShowReceivePage: Bool = false

    @State
    private var shouldShowWalkthroughPage: Bool = false

    @Binding
    var userPrefersDarkTheme: Bool

    @State
    private var mainGradientStyle: MainGradientStyle = .lightStyle

    private let buttonSize: CGFloat = 20.0

    private let buttonPlatformFactor: CGFloat = 2.1

    private let tagLabelWidth: CGFloat = 80.0

    init(viewModel: NewMainViewModel, userPrefersDarkTheme: Binding<Bool>) {
        _userPrefersDarkTheme = userPrefersDarkTheme
        newMainViewModel = viewModel

        UIPageControl.appearance().currentPageIndicatorTintColor = BrainwalletUIColor.midnight
        UIPageControl.appearance().pageIndicatorTintColor = BrainwalletUIColor.lavender
        UIPageControl.appearance().backgroundStyle = .prominent
    }

    var body: some View {
        GeometryReader { geometry in

            let width = geometry.size.width
            let labelBackground =  userPrefersDarkTheme ? BentoColor.tutorialGreen1.opacity(0.1) : BentoColor.purple4.opacity(0.1)
            let labelForeground = userPrefersDarkTheme ? BentoColor.tutorialGreen2 :BentoColor.purple4

            ZStack {
                BentoBackgroundView(userPrefersDarkTheme: $userPrefersDarkTheme).edgesIgnoringSafeArea(.all)
                VStack(alignment: .center) {
                    HStack {
                        ZStack {
                            RoundedRectangle(cornerRadius: 6)
                                .frame(width: tagLabelWidth, height: 18, alignment: .center)
                                .foregroundColor(labelBackground)
                                .padding(8)
                            Text("TUTORIALS")
                                .font(.system(size: 10, weight: .regular, design: .default))
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
                    TutorialSendBentoView(selectedPage: $selectedPage,
                                          userPrefersDarkTheme: $userPrefersDarkTheme)
                        .onTapGesture {
                            shouldShowSendPage.toggle()
                        }
                        .tag(0)
                    TutorialWalkthroughBentoView(selectedPage: $selectedPage,
                                          userPrefersDarkTheme: $userPrefersDarkTheme)
                        .onTapGesture {
                            shouldShowWalkthroughPage.toggle()
                        }
                        .tag(1)
                    TutorialReceiveBentoView(selectedPage: $selectedPage,
                                          userPrefersDarkTheme: $userPrefersDarkTheme)
                        .onTapGesture {
                            shouldShowReceivePage.toggle()
                        }
                        .tag(2)
                }
                .tabViewStyle(.page)
                .indexViewStyle(.page(backgroundDisplayMode: .always))

            }
            .cornerRadius(bentoCornerRadius)
            .onAppear {
                mainGradientStyle = userPrefersDarkTheme ? .darkStyle : .lightStyle
            }
            .sheet(isPresented: $shouldShowSendPage) {
                TutorialSendPageView(userPrefersDarkTheme: $userPrefersDarkTheme)
                    .environmentObject(newMainViewModel)
                .cornerRadius(bentoCornerRadius)
                .presentationDragIndicator(.hidden)
                .presentationBackground(.opacity(0.1))
                .ignoresSafeArea(edges: .bottom)
            }
            .sheet(isPresented: $shouldShowReceivePage) {
                TutorialReceivePageView(userPrefersDarkTheme: $userPrefersDarkTheme)
                .cornerRadius(bentoCornerRadius)
                .presentationDragIndicator(.hidden)
                .presentationBackground(.opacity(0.1))
                .ignoresSafeArea(edges: .bottom)
            }
            .sheet(isPresented: $shouldShowWalkthroughPage) {
                TutorialWalkthroughPageView(userPrefersDarkTheme: $userPrefersDarkTheme)
                .cornerRadius(bentoCornerRadius)
                .presentationDragIndicator(.hidden)
                .presentationBackground(.opacity(0.1))
                .ignoresSafeArea(edges: .bottom)
            }

        }
    }
}
