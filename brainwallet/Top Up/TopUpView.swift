//
//  TopUpView.swift
//  brainwallet
//
//  Created by Kerry Washington on 20/04/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

import SwiftUI

struct TopUpView: View {
    
    @Binding var path: [Onboarding]

    @ObservedObject
    var viewModel: StartViewModel

    init(viewModel: StartViewModel, path: Binding<[Onboarding]>) {
        self.viewModel = viewModel
        _path = path
    }
                                
    var body: some View {
        Text("TopUpView")
    }
}

