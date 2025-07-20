//
//  TopUpView.swift
//  brainwallet
//
//  Created by Kerry Washington on 20/04/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

import SwiftUI

struct TopUpView: View {

    @ObservedObject
    var viewModel: NewMainViewModel

    @Binding
    var path: [Onboarding]

    @State
    private var quotePriceString: String = ""

    @State
    private var quoteTimestampString: String = ""

    let selectorFont: Font = .barlowSemiBold(size: 16.0)
    let buttonLightFont: Font = .barlowLight(size: 16.0)
    let regularButtonFont: Font = .barlowRegular(size: 20.0)
    let largeButtonFont: Font = .barlowSemiBold(size: 24.0)
    let detailFont: Font = .barlowRegular(size: 22.0)
    let billboardFont: Font = .barlowSemiBold(size: 50.0)

    let versionFont: Font = .barlowSemiBold(size: 16.0)
    let verticalPadding: CGFloat = 20.0
    let squareButtonSize: CGFloat = 55.0
    let squareImageSize: CGFloat = 25.0
    let themeButtonSize: CGFloat = 28.0
    let themeBorderSize: CGFloat = 44.0
    let largeButtonHeight: CGFloat = 65.0

    let arrowSize: CGFloat = 40.0

    let userPrefersDarkTheme = UserDefaults.userPreferredDarkTheme

    init(viewModel: NewMainViewModel, path: Binding<[Onboarding]>) {
        self.viewModel = viewModel
        _path = path
    }
    var body: some View {

            GeometryReader { geometry in

                let width = geometry.size.width

                ZStack {
                    BrainwalletColor.surface.edgesIgnoringSafeArea(.all)

                    VStack {
                        HStack {
                            Button(action: {
                                path.removeLast()
                            }) {
                                HStack {
                                    Image(systemName: "arrow.backward")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: squareImageSize,
                                               height: squareImageSize,
                                               alignment: .center)
                                        .foregroundColor(userPrefersDarkTheme ? .white : BrainwalletColor.nearBlack)
                                    Spacer()
                                }
                            }
                            Spacer()
                        }
                        .padding(.all, 20.0)

                        HStack {
                            VStack {
                                Text(quotePriceString)
                                    .font(billboardFont)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .foregroundColor(userPrefersDarkTheme ? .white : BrainwalletColor.nearBlack)
                                    .padding(.bottom, 5.0)

                                Text(quoteTimestampString)
                                    .font(detailFont)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .foregroundColor(userPrefersDarkTheme ? .white.opacity(0.5) : BrainwalletColor.nearBlack.opacity(0.5))
                                    .padding(.top, 5.0)
                                    .onChange(of: viewModel.currentFiatValue) { newValue in
                                        quotePriceString = String(format: String(localized: "%@"), newValue)
                                        let recentDate = Date()
                                        if let formattedDate = viewModel.dateFormatter?.string(from: recentDate) {
                                            quoteTimestampString = String(localized: "as of \(formattedDate)")
                                        } else {
                                            quoteTimestampString = String(localized: "as of \(Date().formatted())")
                                        }
                                    }

                                Spacer()
                                HStack {
                                    Image(systemName: "arrow.down.right")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .font(Font.system(size: 35, weight: .light))
                                        .frame(width: arrowSize,
                                               alignment: .leading)
                                    Spacer()
                                }
                                .frame(maxHeight: .infinity, alignment: .bottomLeading)
                                .padding(.bottom, 10.0)
                                HStack {
                                    Text("Top up?")
                                        .font(billboardFont)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .foregroundColor(userPrefersDarkTheme ? .white : BrainwalletColor.nearBlack)
                                }
                                .padding(.bottom, 10.0)
                                Text("Get some Litecoin for your Brainwallet")
                                    .font(detailFont)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .foregroundColor(userPrefersDarkTheme ? .white.opacity(0.5) : BrainwalletColor.nearBlack.opacity(0.5))
                                    .padding(.all, 10.0)
                            }
                            Spacer()
                        }
                        .padding(.bottom, 40.0)
                        .padding(.leading, 20.0)

                        Button(action: {
                            path.append(.topUpSetAmountView)
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: largeButtonHeight/2)
                                    .frame(width: width * 0.9, height: largeButtonHeight, alignment: .center)
                                    .foregroundColor(BrainwalletColor.grape)

                                Text("Get Litecoin through MoonPay")
                                    .frame(width: width * 0.9, height: largeButtonHeight, alignment: .center)
                                    .font(regularButtonFont)
                                    .foregroundColor(.white)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: largeButtonHeight/2)
                                            .stroke(.white, lineWidth: 1.0)
                                    )
                            }
                            .padding(.all, 8.0)
                        }

                        Button(action: {
                            path.removeAll()
                        }) {
                            ZStack {
                                Text("Maybe later (Skip)")
                                    .frame(width: width * 0.9, height: largeButtonHeight, alignment: .trailing)
                                    .font(regularButtonFont)
                                    .foregroundColor(userPrefersDarkTheme ? .white.opacity(0.5) : BrainwalletColor.nearBlack.opacity(0.5))
                                    .padding(.all, 16.0)
                            }
                        }
                        .frame(width: width, height: largeButtonHeight, alignment: .trailing)
                    }
                }
            }
        }
    }
