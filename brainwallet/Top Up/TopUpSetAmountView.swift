//
//  TopUpSetAmountView.swift
//  brainwallet
//
//  Created by Kerry Washington on 20/04/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

import SwiftUI

struct TopUpSetAmountView: View {
    
    @Binding var path: [Onboarding]

    @ObservedObject
    var viewModel: StartViewModel

    let squareButtonSize: CGFloat = 55.0
    let squareImageSize: CGFloat = 25.0
    let themeBorderSize: CGFloat = 44.0
    let largeButtonHeight: CGFloat = 65.0
    let largeButtonFont: Font = .barlowBold(size: 24.0)
    let selectorFont: Font = .barlowSemiBold(size: 16.0)
    let buttonLightFont: Font = .barlowLight(size: 16.0)
    let regularButtonFont: Font = .barlowRegular(size: 24.0)
    let detailFont: Font = .barlowRegular(size: 28.0)
    let billboardFont: Font = .barlowBold(size: 70.0)
    let versionFont: Font = .barlowSemiBold(size: 16.0)
    let verticalPadding: CGFloat = 20.0
    let themeButtonSize: CGFloat = 28.0
    
    let arrowSize: CGFloat = 60.0

    init(viewModel: StartViewModel, path: Binding<[Onboarding]>) {
        self.viewModel = viewModel
        _path = path
    }
    
    var body: some View {
        
        GeometryReader { geometry in
            
            let width = geometry.size.width
            
            ZStack {
                BrainwalletColor.surface.edgesIgnoringSafeArea(.all)
                
                VStack {
                    HStack {
                        Button(action: {
                            path.removeLast()
                        }) {
                            HStack {
                                Image(systemName: "arrow.backward")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: squareImageSize,
                                           height: squareImageSize,
                                           alignment: .center)
                                
                                    .foregroundColor(BrainwalletColor.content)
                                Spacer()
                            }
                        }
                        Spacer()
                    }
                    .padding(.all, 20.0)
                    
                    Spacer()
                    HStack {
                        Image(systemName: "arrow.down.right")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: arrowSize,
                                   alignment: .center)
                            .padding(.leading, 20.0)
                        
                        Spacer()
                    }
                    .frame(maxHeight: .infinity, alignment: .bottomLeading)
                    .padding(.bottom, 10.0)
                    HStack {
                        Spacer()
                    }
                    .padding(.bottom, 40.0)
                    .padding(.leading, 20.0)
                    
                    Spacer(minLength: 20.0)
                        Button(action: {
                            //path.append(.setTopUpAmount)
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: largeButtonHeight/2)
                                    .frame(width: width * 0.9, height: largeButtonHeight, alignment: .center)
                                    .foregroundColor(BrainwalletColor.surface)
                                
                                Text("Buy with MoonPay")
                                    .frame(width: width * 0.9, height: largeButtonHeight, alignment: .center)
                                    .font(largeButtonFont)
                                    .foregroundColor(BrainwalletColor.content)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: largeButtonHeight/2)
                                            .stroke(BrainwalletColor.content, lineWidth: 2.0)
                                    )
                            }
                            .padding(.all, 8.0)
                        }
                    }
                }
            }
    }
}

