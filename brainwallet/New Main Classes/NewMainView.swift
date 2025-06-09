//
//  NewMainView.swift
//  brainwallet
//
//  Created by Kerry Washington on 03/05/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

import SwiftUI

struct NewMainView: View {
    
    @ObservedObject
    var newMainViewModel: NewMainViewModel
    
    @ObservedObject
    var newReceiveViewModel: NewReceiveViewModel
     
    init(viewModel: NewMainViewModel,
         receiveViewModel: NewReceiveViewModel) {
        newMainViewModel = viewModel
        newReceiveViewModel = receiveViewModel
    }
    var body: some View {
        GeometryReader { geometry in
            
            let width = geometry.size.width
            let height = geometry.size.height
            
            ZStack {
                BrainwalletColor.surface.edgesIgnoringSafeArea(.all)
                
                VStack {
                   
                }
                .frame(width: width,
                       alignment: .center)
                    .background(BrainwalletColor.warn)
                .opacity(newMainViewModel.shouldShowSettings ? 1.0 : 0.0)
                .transition(.opacity)
                    
                VStack {
                        SimpleHeaderView(viewModel: newMainViewModel)
                            .frame(minHeight: 60.0,
                                    maxHeight: height * 0.10,
                                    alignment: .top)
                            .padding(.bottom, 1.0)
                        WalletBalanceView(viewModel: newMainViewModel)
                            .frame(minHeight: 120,
                                    maxHeight: height * 0.20,
                                    alignment: .top)
                        Spacer()
                        TabView {
                            NewSendView(viewModel: newMainViewModel)
                                .tabItem {
                                    Label("Send", systemImage: "square.and.arrow.up")
                                }
                                .toolbar(.visible, for: .tabBar)
                                .toolbarBackground(BrainwalletColor.surface, for: .tabBar)
                            GameView(viewModel: newMainViewModel)
                                .frame(minHeight: 300,
                                        maxHeight: height * 0.6,
                                        alignment: .top)
                                .tabItem {
                                    Image("bw-square-logo")
                                        .resizable()
                                }
                                .toolbar(.visible, for: .tabBar)
                                .toolbarBackground(BrainwalletColor.surface, for: .tabBar)
                            
                            NewReceiveView(viewModel: newReceiveViewModel)
                                .tabItem {
                                    Label("Receive", systemImage: "square.and.arrow.down")
                                }
                                .toolbar(.visible, for: .tabBar)
                                .toolbarBackground(BrainwalletColor.surface, for: .tabBar)
                            }
                            .frame(minHeight: 350.0,
                                maxHeight: height * 0.50,
                                alignment: .bottom)
                        
                        NewTransactionsView(viewModel: newMainViewModel)
                            .frame(minHeight: height * 0.10,
                                    maxHeight: 100,
                                    alignment: .bottom)
                    }
                    .offset(x: newMainViewModel.shouldShowSettings ? width - 90.0: 0)

                }
            }
        }
}
