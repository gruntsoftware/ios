//
//  PINRowView.swift
//  brainwallet
//
//  Created by Kerry Washington on 24/04/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//
import SwiftUI

struct PINRowView: View {
    
    @Binding var pinState: [Bool]

    @State
    private var digitOneEmpty: Bool = true
    
    @State
    private var digitTwoEmpty: Bool = true
    
    @State
    private var digitThreeEmpty: Bool = true
    
    @State
    private var digitFourEmpty: Bool = true
    
    var dotSize: CGFloat = 20.0
    
    private func updatePIN() {
            digitOneEmpty = pinState[0]
            digitTwoEmpty = pinState[1]
            digitThreeEmpty = pinState[2]
            digitFourEmpty = pinState[3]
    }
    
    init(pinState: Binding<[Bool]>) {
        _pinState = pinState
        
    }
    var body: some View {
        HStack {
            Ellipse()
                .frame(width: dotSize,
                   height: dotSize)
                .foregroundColor(digitOneEmpty ? BrainwalletColor.content.opacity(0.9) : BrainwalletColor.content.opacity(0.1))
                .overlay(
                    Ellipse()
                        .stroke(BrainwalletColor.content, lineWidth: 1)
                        .frame(width: dotSize,
                           height: dotSize)
                )
            
            Ellipse()
                .frame(width: dotSize,
                       height: dotSize)
                .foregroundColor( digitTwoEmpty ? BrainwalletColor.content.opacity(0.9) : BrainwalletColor.content.opacity(0.1))
                .overlay(
                    Ellipse()
                        .stroke(BrainwalletColor.content, lineWidth: 1)
                        .frame(width: dotSize,
                           height: dotSize)
                )

            Ellipse()
                .frame(width: dotSize,
                       height: dotSize)
                .foregroundColor(digitThreeEmpty ? BrainwalletColor.content.opacity(0.9) : BrainwalletColor.content.opacity(0.1))
                .overlay(
                    Ellipse()
                        .stroke(BrainwalletColor.content, lineWidth: 1)
                        .frame(width: dotSize,
                           height: dotSize)
                )
            
            Ellipse()
                .frame(width: dotSize,
                       height: dotSize)
                .foregroundColor(digitFourEmpty ? BrainwalletColor.content.opacity(0.9) : BrainwalletColor.content.opacity(0.1))
                .overlay(
                    Ellipse()
                        .stroke(BrainwalletColor.content, lineWidth: 1)
                        .frame(width: dotSize,
                           height: dotSize)
                )

            }
            .frame(maxWidth: 280.0, alignment: .center)
            .onChange(of: pinState ) { _ in
                updatePIN()
            }.onAppear {
                self.updatePIN()
            }

    }
}
