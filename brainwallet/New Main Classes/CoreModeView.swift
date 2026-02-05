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

    @State
    var userWanteToExit: Bool = false

    init(mainViewModel: NewMainViewModel, receiveViewModel: NewReceiveViewModel) {
        newMainViewModel = mainViewModel
        newReceiveViewModel = receiveViewModel

    }
    var body: some View {
        GeometryReader { geometry in

            let width = geometry.size.width
            let height = geometry.size.height

            if showGameMode {
              //  SampleGameView(showGame: $showGameMode)
                WelcomeMojiDemoView(width: width,
                                   height: height,
                                   shouldPlay: .constant(true),
                                   userWantsToExit: $showGameMode,
                                   gameIsInWelcomeMode: false)
                    .frame(maxWidth: width,
                           maxHeight: height,
                           alignment: .center)
                    .padding([.leading, .trailing], 16.0)
                    .accessibilityIdentifier("welcomMojiDemoView")

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
