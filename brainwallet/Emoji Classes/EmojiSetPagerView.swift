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
    
    init(gameHubViewModel: GameHubViewModel,
         viewModel: NewMainViewModel) {
        self.gameHubViewModel = gameHubViewModel
        newMainViewModel = viewModel
        
    }

    
    var body: some View {
        GeometryReader { _ in
            
            ZStack {
                TabView(selection: $selectedPage) {
                    HowToSetEmojisView(selectedPage: $selectedPage)
                    .tag(0)
                    EnterPinForSeedView(enteredPin: $enteredPin,
                                        seedPhrase: $seedPhrase,
                                        viewModel: newMainViewModel,
                                        selectedPage: $selectedPage)
                    .tag(1)
                    
                    
                    PickEmojisView(gameHubViewModel: gameHubViewModel,
                                   viewModel: newMainViewModel,
                                   seedPhrase: seedPhrase,
                                   selectedPage: $selectedPage)
                    .tag(2)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                // Let the pages reach the bottom edge so each page's gradient fills it, content stays inset
                .ignoresSafeArea(.container, edges: .bottom)
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

#Preview {
    let walletManager = MockSeeds.walletManager
    EmojiSetPagerView(gameHubViewModel: GameHubViewModel(walletManager: walletManager),
                      viewModel: NewMainViewModel(store: Store(), walletManager: walletManager))
}
