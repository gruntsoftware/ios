//
//  EmojiSetPagerView.swift
//  brainwallet
//
//  Created by Kerry Washington on 18/02/2026.
//  Copyright © 2026 Grunt Software, LTD. All rights reserved.
//

import SwiftUI

struct EmojiSetPagerView: View {
    
    @ObservedObject
    var gameHubViewModel: GameHubViewModel
    
    @ObservedObject
    var newMainViewModel: NewMainViewModel
    
    @State
    private var selectedPage: Int = 0
    
    @State
    private var enteredPin: String = ""
    
    @State
    private var seedPhrase: String = ""
    
    private let viewBackgroundGradient = LinearGradient(colors: [BentoColor.sendTopPurple,
                                                                BentoColor.sendBottomPurple.opacity(0.7),
                                                                BentoColor.sendBottomPurple.opacity(0.05)],
                                                       startPoint: .top, endPoint: .bottom)
    
    init(gameHubViewModel: GameHubViewModel,
         viewModel: NewMainViewModel) {
        self.gameHubViewModel = gameHubViewModel
        newMainViewModel = viewModel
        
    }

    
    var body: some View {
        GeometryReader { _ in
            
            ZStack {
                TabView(selection: $selectedPage) {
                    HowToSetEmojisView(backgroundGradient: viewBackgroundGradient,
                                       selectedPage: $selectedPage)
                    .tag(0)
                    EnterPinForSeedView(backgroundGradient: viewBackgroundGradient,
                                        enteredPin: $enteredPin,
                                        seedPhrase: $seedPhrase,
                                        viewModel: newMainViewModel,
                                        selectedPage: $selectedPage)
                    .tag(1)
                    
                    
                    PickEmojisView(gameHubViewModel: gameHubViewModel,
                                   viewModel: newMainViewModel,
                                   seedPhrase: seedPhrase,
                                   selectedPage: $selectedPage,
                                   backgroundGradient: viewBackgroundGradient)
                    .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.8), value: selectedPage)
                .transition(.slide)
            }.onChange(of: gameHubViewModel.userEmojisAreSet) { _ , newValue in
                if newValue {
                    newMainViewModel.shouldShowGameSDK = false
                }
            }
            
        }
    }
}
