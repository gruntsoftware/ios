//
//  SettingsView.swift
//  brainwallet
//
//  Created by Kerry Washington on 08/05/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//
//
import SwiftUI

struct SettingsView: View {
    
    @ObservedObject
    var settingsViewModel: SettingsViewModel
      
    let squareButtonSize: CGFloat = 55.0
    let squareImageSize: CGFloat = 25.0
    let themeBorderSize: CGFloat = 44.0
    let largeButtonHeight: CGFloat = 65.0
    let largeButtonFont: Font = .barlowBold(size: 24.0)
 
    init(viewModel: SettingsViewModel) {
        self.settingsViewModel = viewModel
    }
    
    var body: some View {
        
        NavigationStack {
            
            VStack {
                List {
                    
                    Text("Security" )
                        .padding()
                    
                    Text("Settings View")
                        .padding()
                                        
                }
                .listStyle(.plain)
                Spacer()
            }
            .background(BrainwalletColor.surface.opacity(0.5))
        }
    }
}
 
