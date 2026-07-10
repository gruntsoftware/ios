//
//  GameHubBentoView.swift
//  brainwallet
//
//  Created by Kerry Washington on 07/10/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

import SwiftUI

struct GameHubBentoView: View {

    @Binding
    var userPrefersDarkTheme: Bool
    
    @Binding
    var selectedStep: Int

    @State
    private var mainGradientStyle: MainGradientStyle = .lightStyle
 
    private let buttonSize: CGFloat = 20.0

    private let buttonPlatformFactor: CGFloat = 2.1

    private let tagLabelWidth: CGFloat = 80.0

    init(userPrefersDarkTheme: Binding<Bool>,
         selectedStep: Binding<Int>) {
        _userPrefersDarkTheme = userPrefersDarkTheme
        _selectedStep = selectedStep
    }
    var body: some View {
        GeometryReader { geometry in

            let width = geometry.size.width
            let height = geometry.size.height

            let labelBackground = Color.white.opacity(0.1)
            let labelForeground = Color.white

            ZStack {
                GameBackgroundView(userPrefersDarkTheme: $userPrefersDarkTheme)
                    .edgesIgnoringSafeArea(.all)
                    VStack(alignment: .center) {
                        HStack {
                            ZStack {
                                RoundedRectangle(cornerRadius: 6)
                                    .frame(width: tagLabelWidth, height: 18, alignment: .center)
                                    .foregroundColor(labelBackground)
                                    .padding(8)
                                Text("GAME HUB")
                                    .modifier(BWIPSRegular(size: 10.0))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.5)
                                    .padding([.leading, .trailing], 4)
                                    .frame(maxWidth: width * 0.25, maxHeight: 20, alignment: .center)
                                    .foregroundColor(labelForeground)
                            }
                            Spacer()
                        }
                        Spacer()
                    }
                    
                    VStack(alignment: .center) {
                        HStack {
                            VStack {
                                Text("FALLINMOJI")
                                    .font(.lilitaOne(size: 100))
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.3)
                                    .padding(.leading, 16)
                                    .frame(alignment: .leading)
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.white,.white, BentoColor.gameBlue1.opacity(0.2)],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                                
                                Text("ARE YOU GOOD ENOUGH TO BE #1?")
                                    .modifier(BWIPSMedium(size: 16.0))
                                    .padding(.leading, 16)
                                    .frame(alignment: .leading)
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [.white,.white,.white,BentoColor.gameBlue1.opacity(0.1)],
                                            startPoint: .top,
                                            endPoint: .bottom
                                        )
                                    )
                            }
                            .frame(width: width * 0.6)
                            .fixedSize(horizontal: true, vertical: false)
                            .padding(.top, 5)
                            Spacer()
                        }
                    }
                    
                    HStack {
                        Spacer()
                        FallinMojiDemoView(width: width * 0.8,
                                           height: height)
                        .frame(width: width * 0.8, alignment: .trailing)
                        .clipped()
                    }
            }
            .cornerRadius(bentoCornerRadius)
            .frame(minHeight: gameBentoHeight * 0.9, idealHeight: gameBentoHeight * 1.4, maxHeight: gameBentoHeight * 2, alignment: .center)
            .frame(maxWidth: .infinity, alignment: .init(horizontal: .center, vertical: .center))
            .onAppear {
                mainGradientStyle = userPrefersDarkTheme ? .darkStyle : .lightStyle
            }
        }
    }
}
