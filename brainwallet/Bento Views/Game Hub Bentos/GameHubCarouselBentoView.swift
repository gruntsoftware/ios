//
//  GameHubCarouselBentoView.swift
//  brainwallet
//
//  Created by Kerry Washington on 07/10/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

import SwiftUI
import FirebaseAnalytics

struct GameHubCarouselBentoView: View {

    @ObservedObject
    var viewModel: NewMainViewModel

    @ObservedObject
    var newReceiveViewModel: NewReceiveViewModel

    @Binding
    var userPrefersDarkTheme: Bool

    @Binding
    var shouldShowGameSDK: Bool
    
    @Binding
    var userEmojisAreSet: Bool

    @State
    private var selectedTab: Int = 0

    @State
    private var carouselDirection: Int = 1

    @State
    private var mainGradientStyle: MainGradientStyle = .lightStyle

   @State
    private var carouselTimer: Timer?
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    init(viewModel: NewMainViewModel,
         newReceiveViewModel: NewReceiveViewModel,
         userPrefersDarkTheme: Binding<Bool>,
         shouldShowGameSDK: Binding<Bool>,
         userEmojisAreSet: Binding<Bool>) {
        _userPrefersDarkTheme = userPrefersDarkTheme
        _shouldShowGameSDK = shouldShowGameSDK
        _userEmojisAreSet = userEmojisAreSet
        self.viewModel = viewModel
        self.newReceiveViewModel = newReceiveViewModel
    }
    var body: some View {
        GeometryReader { geometry in
        ZStack {
            VStack(alignment: .center) {
                TabView(selection: $selectedTab) {
                    GameHubBentoView(userPrefersDarkTheme: $userPrefersDarkTheme,
                                     selectedStep: $selectedTab)
                    .tag(0)
                    .contentShape(Rectangle())
                    .simultaneousGesture(
                        LongPressGesture(minimumDuration:0.05)
                            .onEnded { _ in
                               if (userEmojisAreSet) {
                                   let address = newReceiveViewModel.newReceiveAddress
                                   DispatchQueue.userInitQueue.async {
                                       appDelegate.applicationController
                                           .shouldShowGameSDK(address: address)
                                   }
                               } else {
                                   shouldShowGameSDK.toggle()
                                   Analytics.logEvent("user_did_tap_gamehub",
                                                      parameters: nil)
                               }
                            }
                    )
                    MoonPayView(viewModel: viewModel,
                                selectedStep: $selectedTab)
                    .tag(1)
                    SocialsBentoView(viewModel: viewModel,
                                     selectedStep: $selectedTab)
                    .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
            }
            .frame(maxWidth: .infinity,
                   alignment: .init(horizontal: .center,
                                    vertical: .center))
            .cornerRadius(bentoCornerRadius)
            .frame(minHeight: gameBentoHeight * 0.9,
                   idealHeight: gameBentoHeight * 1.4,
                   maxHeight: gameBentoHeight * 2, alignment: .center)
            .sensoryFeedback(.success, trigger: shouldShowGameSDK)
            .sensoryFeedback(.selection, trigger: selectedTab)
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
