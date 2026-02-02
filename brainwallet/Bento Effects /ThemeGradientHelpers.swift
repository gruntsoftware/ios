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

struct BentoSurface: ViewModifier {

    @Binding
    var userPrefersDarkTheme: Bool

    let darkModeColor = LinearGradient(colors: [BentoColor.purple2.opacity(0.25),
                                                 BentoColor.purple2.opacity(0.07)],
                                                               startPoint: .topLeading,
                                                               endPoint: .bottomTrailing)
    let lightModeColor = LinearGradient(colors: [BentoColor.grayBackground],
                                                               startPoint: .topLeading,
                                                               endPoint: .bottomTrailing)

    func body(content: Content) -> some View {
        content
            .foregroundStyle(userPrefersDarkTheme ? darkModeColor : lightModeColor)
    }
}

struct BentoBackgroundView: View {

    @Binding
    var userPrefersDarkTheme: Bool

    var body: some View {
        ZStack {
            if userPrefersDarkTheme {

                Color.white.opacity(0.03).edgesIgnoringSafeArea(.all)
                RoundedRectangle(cornerRadius: bentoCornerRadius)
                    .stroke(Color.white.opacity(0.25)
                    ,lineWidth: 1.5)
            } else {
                Color.white.edgesIgnoringSafeArea(.all)
                RoundedRectangle(cornerRadius: bentoCornerRadius)
                    .stroke(BentoColor.grayBorder,
                            lineWidth:  1.5)
            }
        }
    }
}

struct BalanceBackgroundView: View {

    @Binding
    var userPrefersDarkTheme: Bool

    var body: some View {
        ZStack {
            if userPrefersDarkTheme {
                RadialGradient(stops:
                                [Gradient.Stop(color: .black.opacity(0.5), location: 0.0),
                                         Gradient.Stop(color: BentoColor.balanceBackgroundPurple.opacity(0.3), location: 0.950)
                                        ], center: .topLeading, startRadius: 90.0, endRadius: 400)
                RoundedRectangle(cornerRadius: bentoCornerRadius)
                    .stroke(
                        LinearGradient(colors: [.white,
                                                BentoColor.darkModeBorder2.opacity(0.8),
                                                BentoColor.darkModeBorder3,
                                                BentoColor.darkModeBorder4.opacity(0.8),
                                                BentoColor.darkModeBorder5.opacity(0.8)
                                        ], startPoint: .topLeading,
                                       endPoint: .bottomTrailing),
                        lineWidth: 1.5)

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
                    .stroke(BentoColor.grayBorder,
                            lineWidth:  1.5)
            }
        }
    }
}
struct GameBackgroundView: View {

    @Binding
    var userPrefersDarkTheme: Bool

    var body: some View {

        GeometryReader { geometry in

            let width = geometry.size.width
            let height = geometry.size.height
            ZStack {
                if userPrefersDarkTheme {
                    RadialGradient(stops:
                                    [Gradient.Stop(color: .black.opacity(0.5), location: 0.0),
                                     Gradient.Stop(color: BentoColor.balanceBackgroundPurple.opacity(0.3), location: 0.950)
                                    ], center: .topLeading, startRadius: 90.0, endRadius: 400)
                    Image("game-hub-stars")
                        .resizable()
                        .opacity(0.5)
                        .frame(width: width, height: height)
                    RoundedRectangle(cornerRadius: bentoCornerRadius)
                        .stroke(
                            LinearGradient(colors: [.white,
                                                    BentoColor.darkModeBorder2.opacity(0.8),
                                                    BentoColor.darkModeBorder3,
                                                    BentoColor.darkModeBorder4.opacity(0.8),
                                                    BentoColor.darkModeBorder5.opacity(0.8)
                                                   ], startPoint: .topLeading,
                                           endPoint: .bottomTrailing),
                            lineWidth: 1.5)

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
                        .stroke(BentoColor.grayBorder,
                                lineWidth:  1.5)
                }
            }
        }
    }
}
