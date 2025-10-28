//
//  HistoryTabView.swift
//  brainwallet
//
//  Created by Kerry Washington on 07/10/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

import SwiftUI

struct HistoryTabView: View {

    @ObservedObject
    var newMainViewModel: NewMainViewModel

    init(viewModel: NewMainViewModel) {
        newMainViewModel = viewModel
    }
    var body: some View {
        GeometryReader { _ in

            ZStack {
                BrainwalletColor.chili.edgesIgnoringSafeArea(.all)
                VStack {
                    Text("")
                }
            }
        }
    }
}
