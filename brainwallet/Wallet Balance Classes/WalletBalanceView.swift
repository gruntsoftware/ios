//
//  WalletBalanceView.swift
//  brainwallet
//
//  Created by Kerry Washington on 03/05/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

import SwiftUI

struct WalletBalanceView: View {
    
    @ObservedObject
    var newMainViewModel: NewMainViewModel
    
    @State
    private var didTapPriceGroup: Bool = false
    
    @State
    private var shouldShowBalance: Bool = true
    
    @State
    private var swapOffest: CGFloat = 60.0
    
    init(viewModel: NewMainViewModel) {
        newMainViewModel = viewModel
    }
    var body: some View {
        GeometryReader { geometry in
            
            let width = geometry.size.width
            let height = geometry.size.height
            
            ZStack {
                BrainwalletColor.surface.edgesIgnoringSafeArea(.all)
                HStack {
                    VStack {
                        Text("BALANCE")
                            .font(.barlowSemiBold(size: 20.0))
                            .frame(maxWidth: .infinity,
                                   alignment: .leading)
                            .foregroundColor(BrainwalletColor.content)
                        
                        Group {
                            if didTapPriceGroup {
                                Text("$43,000,000.99")
                                    .font( .barlowBold(size: 50.0))
                                    .frame(maxWidth: .infinity,
                                           alignment: .leading)
                                    .foregroundColor(BrainwalletColor.content)
                                    .animation(.bouncy(), value: didTapPriceGroup)
                                Text("Ł1233.994")
                                    .font(.barlowLight(size: 20.0))
                                    .frame(maxWidth: .infinity,
                                           alignment: .leading)
                                    .foregroundColor(BrainwalletColor.content)
                                    .animation(.bouncy(), value: didTapPriceGroup)
                                
                            }
                            else {
                                Text("Ł1233.994")
                                    .font(.barlowBold(size: 50.0))
                                    .frame(maxWidth: .infinity,
                                           alignment: .leading)
                                    .offset(y: didTapPriceGroup ? swapOffest : 0)
                                    .foregroundColor(BrainwalletColor.content)
                                    .animation(.bouncy(), value: didTapPriceGroup)
                                Text("$43,000,000.99")
                                    .font( .barlowLight(size: 20.0))
                                    .frame(maxWidth: .infinity,
                                           alignment: .leading)
                                    .foregroundColor(BrainwalletColor.content)
                                    .animation(.bouncy(), value: didTapPriceGroup)
                            }
                        }
                        .opacity(shouldShowBalance ? 1.0 : 0.0)
                        Spacer()
                    }
                    .padding(.all, 16.0)
                    .onTapGesture {
                       didTapPriceGroup.toggle()
                    }
                    Spacer()
                    VStack {
                        Button(action: {
                            shouldShowBalance.toggle()
                        }) {
                            Image(systemName: shouldShowBalance ? "eye.slash" : "eye")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 30.0, height: 30.0,
                                       alignment: .center)
                                .foregroundColor(BrainwalletColor.content)
                        }
                        .frame(width: 30.0, height: 30.0,
                               alignment: .trailing)
                        Spacer()
                    }
                    .padding(.all, 16.0)
                }
            }
        }
    }
}
