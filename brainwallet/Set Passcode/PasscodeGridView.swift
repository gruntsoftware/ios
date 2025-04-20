//
//  PasscodeGridView.swift
//  brainwallet
//
//  Created by Kerry Washington on 23/04/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//
import SwiftUI
struct PasscodeGridView: View {
     
     
    let detailFont: Font = .barlowRegular(size: 28.0)
    let buttonSize = 44.0
    
    var columns: [GridItem] = [
        GridItem(.flexible(minimum: seedViewWidth)),
        GridItem(.flexible(minimum: seedViewWidth)),
        GridItem(.flexible(minimum: seedViewWidth)),
        GridItem(.flexible(minimum: seedViewWidth)),
    ]
    

    var body: some View {
        
        LazyHGrid(rows: Array(repeating: GridItem(.flexible(minimum: 100)), count: 12), spacing: 0) {
            
            ForEach(0..<11, id: \.self) { index in
                
                Button {
                    //
                } label: {
                    ZStack {
                        Ellipse()
                            .frame(maxWidth: .infinity,
                                   maxHeight: .infinity)
                            .foregroundColor(BrainwalletColor.content.opacity(0.2))
                        Text("\(index)")
                            .font(detailFont)
                            .foregroundColor(BrainwalletColor.content)
                            .frame(maxWidth: .infinity,
                                   maxHeight: .infinity)
                            .padding()
                    }
                }
                .frame(width: buttonSize,
                       height: buttonSize)
            }
        }
    }
    
}
