//
//  FavouritesBentoView.swift
//  brainwallet
//
//  Created by Kerry Washington on 07/10/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

import SwiftUI

struct FavouritesBentoView: View {

    @ObservedObject
    var newMainViewModel: NewMainViewModel

    @State
    var shouldShowSettings: Bool = false

    @Binding
    var userPrefersDarkTheme: Bool

    @State
    private var mainGradientStyle: MainGradientStyle = .lightStyle

    private let buttonPlatformFactor: CGFloat = 2.1

    private let tagLabelWidth: CGFloat = 80.0

    init(viewModel: NewMainViewModel, userPrefersDarkTheme: Binding<Bool>) {
        _userPrefersDarkTheme = userPrefersDarkTheme
        newMainViewModel = viewModel
    }
    var body: some View {
        GeometryReader { geometry in

            let width = geometry.size.width
            let height = geometry.size.height

            let favoriteTileSize: CGFloat = height * 0.4

            let labelBackground =  userPrefersDarkTheme ? BrainwalletColor.content.opacity(0.1) :
            BentoColor.tutorialGreen1
            let labelForeground = userPrefersDarkTheme ? BrainwalletColor.content : BentoColor.tutorialGreen2

            ZStack {
                BentoBackgroundView(userPrefersDarkTheme: $userPrefersDarkTheme).edgesIgnoringSafeArea(.all)
                VStack {
                    HStack {
                        ZStack {
                        RoundedRectangle(cornerRadius: 6)
                            .frame(width: tagLabelWidth, height: 18, alignment: .center)
                            .foregroundColor(labelBackground)
                            .padding(8)
                        Text("TOP SECRET")
                            .modifier(BWIPSRegular(size: 10.0))
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)// Shrinks to 50% of original
                            .padding([.leading, .trailing], 4)
                            .frame(maxWidth: width * 0.5, maxHeight: 24, alignment: .center)
                            .foregroundColor(labelForeground)
                    }
                    Spacer()
                }
                    Spacer()
                }

                Group {
                    HStack {
                        Ellipse()
                            .fill(BrainwalletColor.pesto)
                            .frame(width: favoriteTileSize, height: favoriteTileSize)
                            .padding(4)
                            .offset(x: 20, y: 0)

                        Spacer()
                    }
                    HStack {
                        Ellipse()
                            .fill(BrainwalletColor.cheddar)
                            .frame(width: favoriteTileSize, height: favoriteTileSize)
                            .padding(4)
                            .offset(x: 40, y: 0)
                        Spacer()
                    }
                    HStack {
                        Ellipse()
                            .fill(BrainwalletColor.grape)
                            .frame(width: favoriteTileSize, height: favoriteTileSize)
                            .padding(4)
                            .offset(x: 60, y: 0)
                        Spacer()
                    }
                    HStack {
                        ZStack {
                            Ellipse()
                                .fill(BrainwalletColor.gray)
                                .frame(width: favoriteTileSize, height: favoriteTileSize)
                                .padding(4)
                                .offset(x: 80, y: 0)
                            Image(systemName: "plus")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundStyle(.white)
                                .frame(width: favoriteTileSize * 0.5, height: favoriteTileSize * 0.5)
                                .padding(4)
                                .offset(x: 80, y: 0)
                        }

                        Spacer()

                    }
                }
                .opacity(userPrefersDarkTheme ? 0.8 : 0.7)
                .padding(.top, 16)
                .onAppear {
                    debugPrint("::: favoriteTileSize: \(favoriteTileSize)")
                }
            }
            .cornerRadius(bentoCornerRadius)
            .onAppear {
                mainGradientStyle = userPrefersDarkTheme ? .darkStyle : .lightStyle
            }
        }
    }
}
