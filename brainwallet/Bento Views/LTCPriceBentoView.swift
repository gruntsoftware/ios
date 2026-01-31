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
    private var pickedCurrency: GlobalCurrency = .USD

    @State
    private var selectedFiat: Bool = false

    let globalCurrencies: [GlobalCurrency] = GlobalCurrency.allCases

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

    init(viewModel: NewMainViewModel,
        userPrefersDarkTheme: Binding<Bool>) {
        _userPrefersDarkTheme = userPrefersDarkTheme
        newMainViewModel = viewModel
    }

    var body: some View {
        GeometryReader { _ in

            let trailingPad: CGFloat = 12

            ZStack {
                BentoBackgroundView(userPrefersDarkTheme: $userPrefersDarkTheme).edgesIgnoringSafeArea(.all)
                VStack {
                    Spacer()
                    HStack {
                        Picker("", selection: $pickedCurrency) {
                            ForEach(globalCurrencies, id: \.self) {
                                Text("\($0.countryFlag)   \($0.code) / LTC")
                                    .font(.system(size: 20, weight: .semibold, design: .default))
                                    .foregroundStyle( userPrefersDarkTheme ? .white: BrainwalletColor.nearBlack.opacity(0.8))
                            }
                        }
                        .pickerStyle(.wheel)
                        .onChange(of: pickedCurrency) { _,_ in
                            delay(0.2) {
                                newMainViewModel.userDidSetCurrencyPreference(currency: pickedCurrency)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .bottom)
                        .padding([.leading, .trailing], trailingPad)

                    }
                    .padding(.trailing, trailingPad)

                    Text(newMainViewModel.currentFiatValue)//  "RP1,516,863,885.40"
                        .font(.system(size: 40, weight: .semibold, design: .default))
                        .lineLimit(1)
                        .minimumScaleFactor(0.2)
                        .padding([.leading, .trailing], trailingPad)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .foregroundStyle( userPrefersDarkTheme ? .white : BrainwalletColor.nearBlack.opacity(0.8))
                        .contentTransition(.opacity)
                        .animation(.easeInOut, value: newMainViewModel.currentFiatValue)
                    HStack {
                        Spacer()
                        Text(currentDateLabel)
                            .font(.system(size: 12, weight: .light, design: .default))
                            .lineLimit(1)
                            .minimumScaleFactor(0.9)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .foregroundStyle( userPrefersDarkTheme ? .white: BrainwalletColor.nearBlack.opacity(0.8))
                            .contentTransition(.opacity)
                            .animation(.easeInOut, value: currentDateLabel)
                            .padding(.bottom, 8)
                    }
                    .padding(.trailing, trailingPad)

                }
            }
            .cornerRadius(bentoCornerRadius)
            .onAppear {
                mainGradientStyle = userPrefersDarkTheme ? .darkStyle : .lightStyle
                if let dateFormatter = newMainViewModel.dateFormatter {
                    currentDateLabel = String(describing: dateFormatter.string(from: Date()))
                    pickedCurrency = newMainViewModel.currentGlobalFiat
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
