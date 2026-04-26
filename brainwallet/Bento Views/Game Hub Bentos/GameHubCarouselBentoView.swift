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
    var newMainViewModel: NewMainViewModel

    @Binding
    var userPrefersDarkTheme: Bool
    
    @State
    private var selectedStep: Int = 0
    
    @State
    private var carouselDirection: Int = 1

    @State
    private var mainGradientStyle: MainGradientStyle = .lightStyle

    @State
    private var shouldShowGameMode: Bool = false
    
   @State
    private var carouselTimer: Timer?

    init(viewModel: NewMainViewModel, userPrefersDarkTheme: Binding<Bool>) {
        _userPrefersDarkTheme = userPrefersDarkTheme
        newMainViewModel = viewModel
    }
    var body: some View {
        GeometryReader { geometry in
  
            ZStack {
                VStack(alignment: .center) {
                     
                    TabView(selection: $selectedStep) {
                        GameHubBentoView(viewModel: newMainViewModel,
                                         userPrefersDarkTheme: $userPrefersDarkTheme,
                                         selectedStep: $selectedStep)
                        .padding(.horizontal, 4)
                        .tag(0)
                        MoonPayView(viewModel: newMainViewModel,
                                    selectedStep: $selectedStep)
                        .padding(.horizontal, 4)
                        .tag(1)
                        SocialsBentoView(viewModel: newMainViewModel,
                                         selectedStep: $selectedStep)
                        .padding(.horizontal, 4)
                        .tag(2)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                     
                }
            }
            .cornerRadius(bentoCornerRadius)
            .frame(minHeight: gameBentoHeight * 0.9, idealHeight: gameBentoHeight * 1.4, maxHeight: gameBentoHeight * 2, alignment: .center)
            .onAppear {
                mainGradientStyle = userPrefersDarkTheme ? .darkStyle : .lightStyle
                startCarousel()
            }
            .onDisappear {
                stopCarousel()
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
            selectedStep += carouselDirection
            if selectedStep >= 2 {
                carouselDirection = -1
            } else if selectedStep <= 0 {
                carouselDirection = 1
            }
        }
    }
}
