//
//  SendProgressBarView.swift
//  brainwallet
//
//  Created by Kerry Washington on 14/02/2026.
//  Copyright © 2026 Grunt Software, LTD. All rights reserved.
//

import SwiftUI

struct SendProgressBarView: View {

    @Binding
    var stepIndex: Int

    @Binding
    var userPrefersDarkTheme: Bool

    @State
    private var backgroundColor: Color = BentoColor.tutorialGreen2

    @State
    private var foregroundColor: Color = .white

    var body: some View {
         GeometryReader { geometry in

             let width = geometry.size.width
             let dotSize = 16.0
             let dotLine = 2.0
             let topPadding = 24.0
             let capsuleHeight = 4.0

             ZStack {
                 VStack(alignment: .center) {
                     Capsule()
                         .fill(backgroundColor)
                         .frame(width: width * 0.5, height: capsuleHeight, alignment: .center)
                         .padding([.leading, .trailing],  12)
                         .padding(.top, topPadding + dotSize/4 + dotLine)
                     Spacer()
                 }
                 .frame(width: width, alignment: .center)

                 VStack(alignment: .center) {
                     HStack {

                         Ellipse()
                             .frame(width: dotSize,
                                    height: dotSize)
                             .foregroundColor(stepIndex > 0 ? backgroundColor : .white)
                             .overlay(
                                ZStack {
                                    Ellipse()
                                        .stroke(backgroundColor, lineWidth: dotLine)
                                        .frame(width: dotSize,
                                               height: dotSize)
                                    Image(systemName: "checkmark")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .foregroundStyle(.white)
                                        .frame(width: dotSize * 0.6,
                                               height: dotSize * 0.6)
                                        .opacity(stepIndex > 0 ? 1.0 : 0.0)
                                }
                             )

                         Spacer()

                         Ellipse()
                             .frame(width: dotSize,
                                    height: dotSize)
                             .foregroundColor(stepIndex > 1 ? backgroundColor : .white)
                             .overlay(
                                ZStack {
                                    Ellipse()
                                        .stroke(backgroundColor, lineWidth: dotLine)
                                        .frame(width: dotSize,
                                               height: dotSize)
                                    Image(systemName: "checkmark")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .foregroundStyle(.white)
                                        .frame(width: dotSize * 0.6,
                                               height: dotSize * 0.6)
                                        .opacity(stepIndex > 1 ? 1.0 : 0.0)
                                }
                             )
                         Spacer()
                         Ellipse()
                             .frame(width: dotSize,
                                    height: dotSize)
                             .foregroundColor(stepIndex > 2 ? backgroundColor : .white)
                             .overlay(
                                ZStack {
                                    Ellipse()
                                        .stroke(backgroundColor, lineWidth: dotLine)
                                        .frame(width: dotSize,
                                               height: dotSize)
                                    Image(systemName: "checkmark")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .foregroundStyle(.white)
                                        .frame(width: dotSize * 0.6,
                                               height: dotSize * 0.6)
                                        .opacity(stepIndex > 2 ? 1.0 : 0.0)
                                }
                             )

                     }
                     .frame(width: width * 0.5, height: dotSize, alignment: .center)
                     .padding([.leading, .trailing],  12)
                     .padding(.top, topPadding)

                    Spacer()
                 }
                 .frame(width: width, alignment: .center)

             }
             .onAppear {
                 backgroundColor = userPrefersDarkTheme ? BentoColor.tutorialGreen2 : BentoColor.purple4
             }
        }
    }
}
