//
//  ThemeGradientHelpers.swift
//  brainwallet
//
//  Created by Kerry Washington on 17/10/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

import Foundation
import SwiftUI

 enum MainGradientStyle {
    case darkStyle
    case lightStyle

    var colorThemeArray: [Color] {
        switch self {
        case .darkStyle:
            return  [BrainwalletColor.surface.opacity(0.2), BrainwalletColor.grape.opacity(0.2), BrainwalletColor.midnight.opacity(0.1)]
        case .lightStyle:
            return [BrainwalletColor.surface.opacity(0.1), BrainwalletColor.grape.opacity(0.1), BrainwalletColor.midnight.opacity(0.1)]
        }
    }

     var maskGradientStops: [Color] {
         switch self {
         case .darkStyle:
             return [.black,.black,.black,.black,.clear]
         case .lightStyle:
             return [.black,.black,.clear,.clear,.clear]
         }
     }
 }

struct BentoShadow: ViewModifier {

    @Binding
    var userPrefersDarkTheme: Bool
    func body(content: Content) -> some View {
        content
            .shadow(color: userPrefersDarkTheme ? Color.black.opacity(0.8) :
                        BentoColor.purple5.opacity(0.12),
                    radius: 2, x: 1, y: 2.4)
    }
}

struct BentoSurface: ViewModifier {

    @Binding
    var userPrefersDarkTheme: Bool
    func body(content: Content) -> some View {
        content
            .foregroundStyle(userPrefersDarkTheme ? LinearGradient(colors: [BentoColor.purple2.opacity(0.25),
                                                                            BentoColor.purple2.opacity(0.07)],
                                                                   startPoint: .topLeading,
                                                                   endPoint: .bottomTrailing) :
                                LinearGradient(
                                    colors: [.white, BentoColor.gray1],
                                    startPoint: .top,
                                    endPoint: .bottom
                                )
            )

        /// Dark Mode : #000000 at 40% Opacity
        /// Light  Mode : #5754FF1F at 12% Opacity
    }
}

struct BentoBackgroundView: View {

    @Binding
    var userPrefersDarkTheme: Bool

    var body: some View {
        ZStack {
            if userPrefersDarkTheme {
                LinearGradient(colors: [BentoColor.purple2.opacity(0.25),
                                        BentoColor.purple2.opacity(0.07)],
                               startPoint: .topLeading, endPoint: .bottomTrailing)
                                        .edgesIgnoringSafeArea(.all)
                RoundedRectangle(cornerRadius: bentoCornerRadius)
                    .stroke( LinearGradient(
                        colors: [BentoColor.purple1
                                 ,BentoColor.purple2],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),lineWidth: 1.5)
            } else {
                LinearGradient(
                    colors: [.white, BentoColor.gray1],
                    startPoint: .top,
                    endPoint: .bottom
                ).edgesIgnoringSafeArea(.all)
                RoundedRectangle(cornerRadius: bentoCornerRadius)
                    .stroke(BentoColor.gray2,
                            lineWidth: 1.5)
            }
        }
    }
}

struct BalanceGameBackgroundView: View {

    @Binding
    var userPrefersDarkTheme: Bool

    var body: some View {
        ZStack {
            if userPrefersDarkTheme {
                LinearGradient(colors: [BentoColor.purple3.opacity(0.8),
                                        BentoColor.purple4.opacity(0.3)],
                               startPoint: .top, endPoint: .bottom)
                                        .edgesIgnoringSafeArea(.all)
                RoundedRectangle(cornerRadius: bentoCornerRadius)
                    .stroke( LinearGradient(
                        colors: [BentoColor.purple1,
                                 BentoColor.purple2],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),lineWidth: 1.5)
            } else {
                RoundedRectangle(cornerRadius: bentoCornerRadius)
                    .fill(LinearGradient(
                        colors: [BentoColor.purple4,
                                 BentoColor.purple3],
                        startPoint: .bottom,
                        endPoint: .top
                    ))
                    .edgesIgnoringSafeArea(.all)
                RoundedRectangle(cornerRadius: bentoCornerRadius)
                    .stroke(BentoColor.gray2,
                            lineWidth: 1.5)
            }
        }
    }
}
