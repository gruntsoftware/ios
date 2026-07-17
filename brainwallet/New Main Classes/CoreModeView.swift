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
            NewMainView(viewModel: newMainViewModel, receiveViewModel: newReceiveViewModel)
        }
    }
}
