//
//  RowHowToSetEmoji.swift
//  brainwallet
//
//  Created by Kerry Washington on 7/19/26.
//  Copyright © 2026 Grunt Software, LTD. All rights reserved.
//
import SwiftUI

struct RowHowToSetEmoji: View {
    
    let rowTitle: String
    let rowDescription: String
    let iconName: String
    let rowIndex: Int
    var body: some View {
        GeometryReader { geometry in
            let height = geometry.size.height
            let width = geometry.size.width
            let iconBorderRatio = 2.3
            let iconSize: CGFloat = 26.0
            
            HStack {
                ZStack(alignment: .center) {
                    Ellipse()
                        .stroke(Color.white.opacity(0.5),
                                lineWidth: 0.8)
                        .fill(Color.white.opacity(0.1))
                        .frame(width: iconSize * iconBorderRatio,
                               height: iconSize * iconBorderRatio)
                    Image(systemName: iconName)
                        .resizable()
                        .frame(width: iconSize, height: iconSize)
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading) {
                    Text(rowTitle)
                        .modifier(BWIPSSemiBold(size: 17, lineLimit: 2))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.leading)
                        .padding([.leading,.trailing], 12.0)
                        .padding(.top, 12.0)
                        .padding(.bottom, 4.0)
                        .accessibilityIdentifier("howItWorksStep\(rowIndex)Title")
                    Text(rowDescription)
                        .modifier(BWIPSLight(size: 16, lineLimit: 4))
                        .multilineTextAlignment(.leading)
                        .padding(.leading, 12.0)
                        .foregroundColor(.white)
                        .accessibilityIdentifier("howItWorksStep\(rowIndex)Description")
                    Spacer()
                }
            }
            .padding(.leading, 40.0)
            .padding(.trailing, 40.0)
        }
    }
}
