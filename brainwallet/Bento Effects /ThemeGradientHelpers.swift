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
                        Color(red: 0.341176, green: 0.329411, blue: 1).opacity(0.12),
                    radius: 2, x: 1, y: 2.4)
        /// Dark Mode : #000000 at 40% Opacity
        /// Light  Mode : #5754FF1F at 12% Opacity
    }
}

struct BentoSurface: ViewModifier {

    @Binding
    var userPrefersDarkTheme: Bool
    func body(content: Content) -> some View {
        content
            .foregroundStyle(userPrefersDarkTheme ? LinearGradient(colors: [Color(red: 0.5254901960784314,
                                                           green: 0.4117647058823529,
                                                           blue: 0.7294117647058823).opacity(0.25),
                                                          Color(red: 0.5254901960784314,
                                                                green: 0.4117647058823529,
                                                                blue: 0.7294117647058823).opacity(0.07)],
                                                                   startPoint: .topLeading, endPoint: .bottomTrailing) :
                                LinearGradient(
                                    colors: [.white, Color(red: 0.91764, green: 0.91764, blue: 0.91764)],
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
                LinearGradient(colors: [Color(red: 0.5254901960784314,
                                         green: 0.4117647058823529,
                                         blue: 0.7294117647058823).opacity(0.25),
                                        Color(red: 0.5254901960784314,
                                              green: 0.4117647058823529,
                                              blue: 0.7294117647058823).opacity(0.07)],
                               startPoint: .topLeading, endPoint: .bottomTrailing)
                                        .edgesIgnoringSafeArea(.all)
                RoundedRectangle(cornerRadius: bentoCornerRadius)
                    .stroke( LinearGradient(
                        colors: [Color(red: 0.7843137254901961,
                                       green: 0.7019607843137254,
                                       blue: 0.9333333333333333)// #C8B3EE
                                 ,Color(red: 0.5254901960784314,
                                        green: 0.4117647058823529,
                                        blue: 0.7294117647058823)], // #8669BA80 50%
                        startPoint: .leading,
                        endPoint: .trailing
                    ),lineWidth: 1.5)
            } else {
                LinearGradient(
                    colors: [.white, Color(red: 0.91764, green: 0.91764, blue: 0.91764)],
                    startPoint: .top,
                    endPoint: .bottom
                ).edgesIgnoringSafeArea(.all)
                RoundedRectangle(cornerRadius: bentoCornerRadius)
                    .stroke(Color(red: 0.9098039215686274,
                                  green: 0.9176470588235294,
                                  blue: 0.9254901960784314),
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
                LinearGradient(colors: [Color(red: 0.07058823529411765,
                                         green: 0.07450980392156863,
                                         blue: 0.2823529411764706).opacity(0.8), // #121348
                                        Color(red:  0.28627450980392155,
                                              green: 0.12156862745098039,
                                              blue: 0.6392156862745098).opacity(0.3)], // #491FA3
                               startPoint: .top, endPoint: .bottom)
                                        .edgesIgnoringSafeArea(.all)
                RoundedRectangle(cornerRadius: bentoCornerRadius)
                    .stroke( LinearGradient(
                        colors: [Color(red: 0.7843137254901961,
                                       green: 0.7019607843137254,
                                       blue: 0.9333333333333333)// #C8B3EE
                                 ,Color(red: 0.5254901960784314,
                                        green: 0.4117647058823529,
                                        blue: 0.7294117647058823)], // #8669BA80 50%
                        startPoint: .leading,
                        endPoint: .trailing
                    ),lineWidth: 1.5)
            } else {
                RoundedRectangle(cornerRadius: bentoCornerRadius)
                    .fill(LinearGradient(
                        colors: [
                            Color(red: 0.28627450980392155,
                                  green: 0.12156862745098039,
                                  blue: 0.6392156862745098), // #491FA3
                            Color(red: 0.07058823529411765,
                                  green: 0.07450980392156863,
                                  blue: 0.2823529411764706)  // #121348
                        ],
                        startPoint: .bottom,
                        endPoint: .top
                    ))
                    .edgesIgnoringSafeArea(.all)
                RoundedRectangle(cornerRadius: bentoCornerRadius)
                    .stroke(Color(red: 0.9098039215686274,
                                  green: 0.9176470588235294,
                                  blue: 0.9254901960784314),
                            lineWidth: 1.5)
            }
        }
    }
}
