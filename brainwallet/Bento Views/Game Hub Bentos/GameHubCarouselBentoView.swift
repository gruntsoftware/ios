//
//  GameHubCarouselBentoView.swift
//  brainwallet
//
//  Created by Kerry Washington on 07/10/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

import SwiftUI

struct GameHubCarouselBentoView: View {

    @ObservedObject
    var viewModel: NewMainViewModel

    @Binding
    var userPrefersDarkTheme: Bool
    
    @Binding
    var shouldToggleGame: Bool
    
    @State
    private var selectedTab: Int = 0
    
    @State
    private var carouselDirection: Int = 1

    @State
    private var mainGradientStyle: MainGradientStyle = .lightStyle

    @State
    private var shouldShowGameMode: Bool = false
    
   @State
    private var carouselTimer: Timer?

    init(viewModel: NewMainViewModel, userPrefersDarkTheme: Binding<Bool>, shouldToggleGame: Binding<Bool>) {
        _userPrefersDarkTheme = userPrefersDarkTheme
        _shouldToggleGame = shouldToggleGame
        self.viewModel = viewModel
    }
    var body: some View {
        GeometryReader { geometry in
  
            ZStack {
                VStack(alignment: .center) {
                     
                    TabView(selection: $selectedTab) {
                        GameHubBentoView(viewModel: viewModel,
                                         userPrefersDarkTheme: $userPrefersDarkTheme,
                                         selectedStep: $selectedTab)
                        .tag(0)
                        MoonPayView(viewModel: viewModel,
                                    selectedStep: $selectedTab)
                        .tag(1)
                        SocialsBentoView(viewModel: viewModel,
                                         selectedStep: $selectedTab)
                        .tag(2)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .onTapGesture {
                        if selectedTab == 0 {
                            shouldToggleGame.toggle()
                        }
                    }

                }
                .frame(maxWidth: .infinity, alignment: .init(horizontal: .center, vertical: .center))

            }
            .cornerRadius(bentoCornerRadius)
            .frame(minHeight: gameBentoHeight * 0.9, idealHeight: gameBentoHeight * 1.4, maxHeight: gameBentoHeight * 2, alignment: .center)
            .onAppear {
                mainGradientStyle = userPrefersDarkTheme ? .darkStyle : .lightStyle

            }
        }
    }
    
    private func startCarousel() {
        stopCarousel()
        carouselTimer = Timer.scheduledTimer(withTimeInterval: 15.0,
                                             repeats: true) { _ in
            advanceCarousel()
        }
        RunLoop.main.add(carouselTimer!, forMode: .common)
    }
    
    private func stopCarousel() {
        carouselTimer?.invalidate()
        carouselTimer = nil
    }
    
    private func advanceCarousel() {
        withAnimation {
            selectedTab += carouselDirection
            if selectedTab >= 2 {
                carouselDirection = -1
            } else if selectedTab <= 0 {
                carouselDirection = 1
            }
        }
    }
}
