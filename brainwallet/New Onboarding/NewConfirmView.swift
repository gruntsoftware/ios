//
//  NewConfirmView.swift
//  brainwallet
//
//  Created by Kerry Washington on 10/05/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

import SwiftUI

struct NewConfirmView: View {
    
    @ObservedObject
    var viewModel: NewConfirmViewModel
    
    init(viewModel: NewConfirmViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        GeometryReader { geometry in
        
            ZStack {
                BrainwalletColor.surface.edgesIgnoringSafeArea(.all)
                VStack {
                    Text("")
                }
            }
        }
    }
}
