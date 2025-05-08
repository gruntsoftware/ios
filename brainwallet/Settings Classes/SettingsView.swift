//
//  SettingsView.swift
//  brainwallet
//
//  Created by Kerry Washington on 03/05/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//
import SwiftUI
import brainwallet_ios_storekit

struct SettingsView: View {
    
    @ObservedObject
    var newMainViewModel: NewMainViewModel
    
     
    init(viewModel: NewMainViewModel) {
        newMainViewModel = viewModel
    }
    
    var body: some View {
        
        NavigationStack {
            
            VStack {
                List {
                    
                    
                    Text(S.SecurityCenter.title.localize())
                        .padding()
                    
                    Text(S.Settings.languages.localize())
                        .padding()
                    
                    Text(S.Settings.languages.localize())
                        .padding()
                    
                    Text("Settings View 4")
                        .padding()
                                        
                }
                .listStyle(.plain)
                Spacer()
            }
            .background(BrainwalletColor.surface.opacity(0.5))
        }
    }
}
 
