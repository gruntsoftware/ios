//
//  CoreModeView.swift
//  brainwallet
//
//  Created by Kerry Washington on 02/11/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

import SwiftUI
import BrainwalletiOSPrivateGeneralPurpose

struct CoreModeView: View {

    @ObservedObject
    var newMainViewModel: NewMainViewModel

    @ObservedObject
    var newReceiveViewModel: NewReceiveViewModel

    @State
    var showGameMode: Bool = false

    init(mainViewModel: NewMainViewModel, receiveViewModel: NewReceiveViewModel) {
        newMainViewModel = mainViewModel
        newReceiveViewModel = receiveViewModel

    }
    var body: some View {
        GeometryReader { _ in
            if showGameMode {
                SampleGameView(showGame: $showGameMode)
            } else {
                NewMainView(viewModel: newMainViewModel, receiveViewModel: newReceiveViewModel)
            }
        }
        .onChange(of: newMainViewModel.shouldShowGameMode) { _,_ in
            showGameMode = newMainViewModel.shouldShowGameMode
        }
        .onChange(of: showGameMode) { _,_ in
            newMainViewModel.shouldShowGameMode = showGameMode
        }
    }
}
