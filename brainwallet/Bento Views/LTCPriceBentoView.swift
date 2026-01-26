//
//  LTCPriceBentoView.swift
//  brainwallet
//
//  Created by Kerry Washington on 07/10/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

import SwiftUI

struct LTCPriceBentoView: View {

    @ObservedObject
    var newMainViewModel: NewMainViewModel

    @State
    var shouldShowSettings: Bool = false

    @State
    var currentDateLabel = ""

    @Binding
    var userPrefersDarkTheme: Bool

    @State
    private var mainGradientStyle: MainGradientStyle = .lightStyle

    private let buttonSize: CGFloat = 20.0

    private let buttonPlatformFactor: CGFloat = 2.1

    init(viewModel: NewMainViewModel, userPrefersDarkTheme: Binding<Bool>) {
        _userPrefersDarkTheme = userPrefersDarkTheme
        newMainViewModel = viewModel
    }
    var body: some View {
        GeometryReader { geometry in

            let width = geometry.size.width

            ZStack {
                BentoBackgroundView(userPrefersDarkTheme: $userPrefersDarkTheme).edgesIgnoringSafeArea(.all)
                VStack {
                    Spacer()
                        Text(newMainViewModel.currencyCode)
                            .font(.system(size: 21, weight: .semibold, design: .default))
                            .padding([.leading,.top], 16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundStyle( userPrefersDarkTheme ? .white.opacity(0.8): BrainwalletColor.nearBlack.opacity(0.8))
                    Spacer()
                    Text(newMainViewModel.currentFiatValue)//  "RP1,516,863,885.40"
                        .font(.system(size: 40, weight: .semibold, design: .default))
                        .lineLimit(1)
                        .minimumScaleFactor(0.3)
                        .padding(.top, 12)
                        .padding([.leading,.trailing], 16)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundStyle( userPrefersDarkTheme ? .white : BrainwalletColor.nearBlack.opacity(0.8))

                    HStack {
                        Text(currentDateLabel)
                            .font(.system(size: 11, weight: .ultraLight, design: .default))
                            .lineLimit(1)
                            .minimumScaleFactor(0.9)
                            .padding(.leading, 16)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundStyle( userPrefersDarkTheme ? .white: BrainwalletColor.nearBlack.opacity(0.8))
                            .padding(.bottom, 8)
                        Spacer()
                        Text(newMainViewModel.currentGlobalFiat.countryFlag)
                            .font(.system(size: 14, weight: .regular, design: .default))
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                            .padding(.trailing, 16)
                            .frame(maxWidth: width * 0.3, alignment: .trailing)
                            .padding(.bottom, 8)
                    }
                }
            }
            .cornerRadius(bentoCornerRadius)
            .onAppear {
                mainGradientStyle = userPrefersDarkTheme ? .darkStyle : .lightStyle
                if let dateFormatter = newMainViewModel.dateFormatter {
                    currentDateLabel = String(describing: dateFormatter.string(from: Date()))
                }
            }
            .onChange(of: newMainViewModel.currentFiatValue) { _,_ in
                if let dateFormatter = newMainViewModel.dateFormatter {
                    currentDateLabel = String(describing: dateFormatter.string(from: Date()))
                }
            }
        }
    }
}
