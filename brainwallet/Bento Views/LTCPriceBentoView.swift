//
//  TutorialsBentoView.swift
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
            let height = geometry.size.height

            ZStack {
                BentoBackgroundView(userPrefersDarkTheme: $userPrefersDarkTheme).edgesIgnoringSafeArea(.all)
                VStack {
                    Text(newMainViewModel.currencyCode + "/LTC")
                        .font(.system(size: 30, weight: .semibold, design: .default))
                        .lineLimit(1)
                        .minimumScaleFactor(0.3)// Shrinks to 30% of original
                        .padding([.leading,.top], 10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundStyle( userPrefersDarkTheme ? .white.opacity(0.8): BrainwalletColor.nearBlack.opacity(0.8))
                    Text(newMainViewModel.currentFiatValue)//  "RP1,516,863,885.40"
                        .font(.system(size: 40, weight: .semibold, design: .default))
                        .lineLimit(1)
                        .minimumScaleFactor(0.3)// Shrinks to 30% of original
                        .padding(.top, 12)
                        .padding([.leading,.trailing], 10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundStyle( userPrefersDarkTheme ? .white.opacity(0.8): BrainwalletColor.nearBlack.opacity(0.8))
                    Text(currentDateLabel)
                        .font(.system(size: 11, weight: .ultraLight, design: .default))
                        .lineLimit(1)
                        .minimumScaleFactor(0.9)// Shrinks to 80% of original
                        .padding(.leading, 10)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundStyle( userPrefersDarkTheme ? .white.opacity(0.8): BrainwalletColor.nearBlack.opacity(0.8))
                    Spacer()
                }

            }
            .cornerRadius(bentoCornerRadius)
            .onAppear {
                mainGradientStyle = userPrefersDarkTheme ? .darkStyle : .lightStyle
                let lastedUpdateDate = Date()

                if let dformatter = newMainViewModel.dateFormatter {
                    currentDateLabel = String(describing: dformatter.string(from: lastedUpdateDate))
                }

            }
            .onChange(of: newMainViewModel.currentFiatValue) { _,_ in
                let lastedUpdateDate = Date()

                if let dformatter = newMainViewModel.dateFormatter {
                    currentDateLabel = String(describing: dformatter.string(from: lastedUpdateDate))
                }
            }
        }
    }
}
