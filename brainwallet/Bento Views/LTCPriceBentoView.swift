//
//  LTCPriceBentoView.swift
//  brainwallet
//
//  Created by Kerry Washington on 07/10/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

import SwiftUI
import FirebaseAnalytics

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
                                    .modifier(BWIPSSemiBold(size: 20.0))
                                    .foregroundStyle( userPrefersDarkTheme ? .white: BrainwalletColor.nearBlack.opacity(0.8))
                            }
                        }
                        .pickerStyle(.wheel)
                        .onChange(of: pickedCurrency) { _,_ in
                            delay(0.2) {
                                newMainViewModel.userDidSetCurrencyPreference(currency: pickedCurrency)
                                Analytics
                                    .logEvent("user_set_preferred_fiat",
                                    parameters: [
                                        "platform": "ios",
                                        "app_version": AppVersion.string
                                    ])
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding([.leading, .trailing], trailingPad)

                    }
                    .padding(.trailing, trailingPad)

                    Text(newMainViewModel.currentFiatValue)//  "RP1,516,863,885.40"
                        .modifier(BWIPSSemiBold(size: 32.0))
                        .padding([.leading, .trailing], trailingPad)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .foregroundStyle( userPrefersDarkTheme ? .white : BrainwalletColor.nearBlack.opacity(0.8))
                        .contentTransition(.opacity)
                        .animation(.easeInOut, value: newMainViewModel.currentFiatValue)
                        .padding(.bottom, 2)

                    HStack {
                        Spacer()
                        Text(currentDateLabel)
                            .modifier(BWIPSThin(size: 11.0))
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                            .frame(maxWidth: .infinity, alignment: .trailing)
                            .foregroundStyle( userPrefersDarkTheme ? .white: BrainwalletColor.nearBlack.opacity(0.8))
                            .contentTransition(.opacity)
                            .animation(.easeInOut, value: currentDateLabel)
                    }
                    .padding(.trailing, trailingPad)
                    .padding(.bottom, 8)

                }
            }
            .cornerRadius(bentoCornerRadius)
            .onAppear {
                mainGradientStyle = userPrefersDarkTheme ? .darkStyle : .lightStyle
                if let dateFormatter = newMainViewModel.dateFormatter {
                    currentDateLabel = "as of " + String(describing: dateFormatter.string(from: Date()))
                    pickedCurrency = newMainViewModel.currentGlobalFiat
                }
            }
            .onChange(of: newMainViewModel.currentFiatValue) { _,_ in
                if let dateFormatter = newMainViewModel.dateFormatter {
                    currentDateLabel = "as of " + String(describing: dateFormatter.string(from: Date()))
                }
            }
        }
    }
}
