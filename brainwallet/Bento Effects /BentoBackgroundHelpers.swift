//
//  BentoBackgrountHelpers.swift
//  brainwallet
//
//  Created by Kerry Washington on 17/10/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit

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
             return [BrainwalletColor.midnight, BentoColor.purple3, BentoColor.purple4,.black]
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

    init(userPrefersDarkTheme: Binding<Bool>) {
        _userPrefersDarkTheme = userPrefersDarkTheme
    }

    var body: some View {
        ZStack {

            Group {
                Color.white.opacity(0.03).edgesIgnoringSafeArea(.all)
                RoundedRectangle(cornerRadius: bentoCornerRadius)
                    .stroke(Color.white.opacity(0.25)
                            ,lineWidth: 1.5)
            }
            .opacity(userPrefersDarkTheme ? 1.0 : 0.0)

            Group {
                Color.white.edgesIgnoringSafeArea(.all)
                RoundedRectangle(cornerRadius: bentoCornerRadius)
                    .stroke(BentoColor.grayBorder,
                            lineWidth:  1.5)
            }
            .opacity(userPrefersDarkTheme ? 0.0 : 1.0)
        }
    }
}

struct BalanceBackgroundView: View {

    @Binding
    var userPrefersDarkTheme: Bool

    init(userPrefersDarkTheme: Binding<Bool>) {
        _userPrefersDarkTheme = userPrefersDarkTheme
    }

    var body: some View {
        ZStack {
            Group {
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
            }
            .opacity(userPrefersDarkTheme ? 1.0 : 0.0)
            Group {
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
            .opacity(userPrefersDarkTheme ? 0.0 : 1.0)
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
               Group {
                    RadialGradient(stops:
                                    [Gradient.Stop(color: .black.opacity(0.5), location: 0.0),
                                     Gradient.Stop(color: BentoColor.balanceBackgroundPurple.opacity(0.3), location: 0.950)
                                    ], center: .topLeading, startRadius: 90.0, endRadius: 400)
                    Image("game-hub-stars")
                        .resizable()
                        .opacity(0.7)
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
                }
                .opacity(userPrefersDarkTheme ? 1.0 : 0.0)

                Group {
                    RoundedRectangle(cornerRadius: bentoCornerRadius)
                        .fill(LinearGradient(
                            colors: [BentoColor.purple4,
                                     BentoColor.purple3],
                            startPoint: .bottom,
                            endPoint: .top
                        ))
                        .edgesIgnoringSafeArea(.all)
                    Image("game-hub-stars")
                        .resizable()
                        .opacity(0.7)
                        .frame(width: width, height: height)
                    RoundedRectangle(cornerRadius: bentoCornerRadius)
                        .stroke(BentoColor.grayBorder,
                                lineWidth:  1.5)
                }
                .opacity(userPrefersDarkTheme ? 0.0 : 1.0)
            }
        }
    }
}

struct StaticBackgroundView: View {
    
    @Binding
    var userPrefersDarkTheme: Bool
    var imageName: String = "game-hub-stars"
     
    var body: some View {
        
        GeometryReader { geometry in
            
            let width = geometry.size.width
            ZStack {
                Group {
                    RoundedRectangle(cornerRadius: bentoCornerRadius)
                        .fill(LinearGradient(
                            colors: [BentoColor.purple4,
                                     BentoColor.purple3],
                            startPoint: .bottom,
                            endPoint: .top
                        ))
                        .edgesIgnoringSafeArea(.all)
                    GeometryReader { geometry in
                        Image(imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .offset(y: -5)
                            .frame(width: geometry.size.width,
                                   height: geometry.size.height)
                            .clipped()
                    }
                    RoundedRectangle(cornerRadius: bentoCornerRadius)
                        .stroke(BentoColor.grayBorder,
                                lineWidth:  1.5)
                }
                .opacity(userPrefersDarkTheme ? 0.0 : 1.0)
            }
        }
    }
}

struct ShopBackgroundView: View {
    
    @Binding
    var userPrefersDarkTheme: Bool
    var imageName: String = "shop_background_01"
    
    var body: some View {
        
        GeometryReader { geometry in
            
            ZStack {
                Group {
                    GeometryReader { geometry in
                        Image(imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geometry.size.width,
                                   height: geometry.size.height)
                            .clipped()
                        
                    }
                    RoundedRectangle(cornerRadius: bentoCornerRadius)
                        .stroke(BentoColor.grayBorder.opacity(0.4),
                                lineWidth:  1.5)
                }
                .opacity(userPrefersDarkTheme ? 1.0 : 0.0)
                
                Group {
                    GeometryReader { geometry in
                        Image(imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geometry.size.width,
                                   height: geometry.size.height)
                            .clipped()
                            .opacity(0.02)
                        
                    }
                    RoundedRectangle(cornerRadius: bentoCornerRadius)
                        .stroke(Color.gray.opacity(0.4)
                                ,lineWidth: 1.5)
                }
                .opacity(userPrefersDarkTheme ? 0.0 : 1.0)
            }
        }
    }
}
