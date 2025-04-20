//
//  SettingsView.swift
//  brainwallet
//
//  Created by Kerry Washington on 27/04/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//
import SwiftUI

struct SettingsView: View {
    
    @Binding var path: [Onboarding]
    
    @ObservedObject
    var viewModel: StartViewModel
    
    let squareButtonSize: CGFloat = 55.0
    let squareImageSize: CGFloat = 25.0
    let themeBorderSize: CGFloat = 44.0
    let largeButtonHeight: CGFloat = 65.0
    let largeButtonFont: Font = .barlowBold(size: 24.0)

    init(viewModel: StartViewModel, path: Binding<[Onboarding]>) {
        self.viewModel = viewModel
        _path = path
    }
                                
    var body: some View {
        
        GeometryReader { geometry in
            
            let width = geometry.size.width
            let height = geometry.size.height
            
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
                        }.frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .frame(height: squareImageSize)
                    .padding(.all, 20.0)
                    
                    Text("TEMP Settings View")
                    
                    Button(action: {
                        //
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: largeButtonHeight/2)
                                .frame(width: width * 0.9, height: largeButtonHeight, alignment: .center)
                                .foregroundColor(BrainwalletColor.surface)
                            
                            Text(S.Onboarding.readyNextButton.localize())
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
