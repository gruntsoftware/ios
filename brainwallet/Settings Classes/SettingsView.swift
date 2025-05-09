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
    var newMainViewModel: NewMainViewModel
     
    init(viewModel: NewMainViewModel) {
        newMainViewModel = viewModel
    }
    
    var body: some View {
        
        NavigationStack {
            
            VStack {
                List {
                    
                    
                    Text("Security" )
                        .padding()
                    
                    Text("Languages" )
                        .padding()
                    
                    Text("Languages" )
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
 
