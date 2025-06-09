//
//  ReceiveAddressView.swift
//  brainwallet
//
//  Created by Kerry Washington on 07/06/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

import Foundation
import SwiftUI

struct ReceiveAddressView: View {
    
    @ObservedObject var viewModel: NewReceiveViewModel
    
    @Binding
    var newAddress: String
    
    @Binding
    var  qrPlaceholder: UIImage
    
    @FocusState.Binding
    var keyboardFocused: Bool
     
    let ginormousFont: Font = .barlowSemiBold(size: 22.0)
    let subDetailFont: Font = .barlowRegular(size: 14.0)
    let padding = 8.0
    init(viewModel: NewReceiveViewModel, newAddress: Binding<String>, qrPlaceholder: Binding<UIImage>, keyboardFocused: FocusState<Bool>.Binding) {
        self.viewModel = viewModel
        _newAddress = newAddress
        _qrPlaceholder = qrPlaceholder
        _keyboardFocused = keyboardFocused
    }
    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
                        
            ZStack {
                HStack {
                    VStack {
                        Image(uiImage: viewModel.newReceiveAddressQR ?? qrPlaceholder)
                            .resizable()
                            .scaledToFit()
                            .frame(width: (width / 2) - padding)
                    }
                    .frame(width: width / 2, alignment: .top)
                    VStack {
                        Text(newAddress)
                            .font(ginormousFont)
                            .kerning(0.3)
                            .lineLimit(3)
                            .multilineTextAlignment(.leading)
                            .frame(height: 100)
                            .foregroundColor(BrainwalletColor.content)
                        
                        VStack {
                            HStack {
                                
                                Text("Copy Address: ")
                                    .font(subDetailFont)
                                    .lineLimit(3)
                                    .multilineTextAlignment(.leading)
                                    .foregroundColor(BrainwalletColor.content)
                                
                                Button(action: {
                                    UIPasteboard.general.string = viewModel.newReceiveAddress
                                }) {
                                    ZStack {
                                        Ellipse()
                                            .frame(width: 40,
                                                   height: 40)
                                            .overlay(
                                                Ellipse()
                                                    .stroke(BrainwalletColor.content, lineWidth: 1)
                                                    .frame(width: 40,
                                                           height: 40)
                                            )
                                        
                                        Image(systemName: "document.on.document")
                                            .resizable()
                                            .frame(width: 23, height: 23)
                                            .foregroundColor(BrainwalletColor.content)
                                    }
                                }
                            }
                            
                            Spacer()
                        }
                        Spacer()
                    }
                    .frame(width: width / 2, alignment: .top)
                    .onChange(of: viewModel.newReceiveAddress) { address in
                        newAddress = address
                    }
                    
                }
                .frame(width: width, height: height, alignment: .top)
                .opacity(keyboardFocused ? 0 : 1)
            }
        }
    }
}
