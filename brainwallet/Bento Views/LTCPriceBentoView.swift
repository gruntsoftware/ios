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
    private var selectedFiat: Bool = false

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
        GeometryReader { geometry in
            let height = geometry.size.height
            let trailingPad: CGFloat = 12

            ZStack {
                BentoBackgroundView(userPrefersDarkTheme: $userPrefersDarkTheme).edgesIgnoringSafeArea(.all)
                VStack(alignment: .leading, spacing: 0) {
                    Spacer()
                    HStack {
                        Picker("", selection: $newMainViewModel.currentGlobalFiat) {
                            ForEach(newMainViewModel.globalCurrencies, id: \.self) { currency in
                                Text(verbatim: "\(currency.countryFlag)   \(currency.code) / LTC")
                                    .modifier(BWIPSSemiBold(size: 18.0))
                                    .frame(maxHeight: 19.0, alignment: .leading)
                                    .foregroundStyle( userPrefersDarkTheme ? .white: BrainwalletColor.nearBlack.opacity(0.8))
                            }
                        }
                        .pickerStyle(.wheel)
                        .onChange(of: newMainViewModel.currentGlobalFiat) { _,_ in
                                newMainViewModel
                                .userDidSetCurrencyPreference(currency: newMainViewModel.currentGlobalFiat)
                        }
                        .frame(alignment: .leading)
                        .frame(minHeight: height * 0.2, idealHeight: height * 0.3, maxHeight: height * 0.35)
                        .padding([.leading, .trailing], 8.0)

                    }
                    .frame(minHeight: height * 0.30,
                           idealHeight: height * 0.40,
                           maxHeight: height * 0.5)
                    .padding(.bottom, 2.0)
                    if height > 200 {
                        Text(newMainViewModel.currentGlobalFiat.fullCurrencyName)
                            .modifier(BWIPSLight(size: 16.0, lineLimit: 2))
                            .padding([.leading, .trailing], 8.0)
                            .padding(.bottom, 2.0)
                    }
                    Text(newMainViewModel.currentFiatValue)
                        .modifier(BWIPSSemiBold(size: 30.0))
                        .padding([.leading, .trailing], 8.0)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .frame(minHeight: 34.0, idealHeight: 38.0, maxHeight: 50.0)
                        .foregroundStyle( userPrefersDarkTheme ? .white : BrainwalletColor.nearBlack.opacity(0.8))
                        .contentTransition(.opacity)
                        .layoutPriority(1.0)
                        .animation(.easeInOut, value: newMainViewModel.currentFiatValue)
                        .padding(.bottom, 2.0)

                    HStack {
                        Spacer()
                        Text(currentDateLabel)
                            .modifier(BWIPSThin(size: 11.0))
                            .frame(minHeight: 9.0, idealHeight: 13.0, maxHeight: 14.0)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundStyle( userPrefersDarkTheme ? .white: BrainwalletColor.nearBlack.opacity(0.8))
                            .contentTransition(.opacity)
                            .animation(.easeInOut, value: currentDateLabel)
                    }
                    .padding(.trailing, trailingPad)
                    .padding(.bottom, 6.0)
                }
            }
            .cornerRadius(bentoCornerRadius)
            .onAppear {
                mainGradientStyle = userPrefersDarkTheme ? .darkStyle : .lightStyle
                if let dateFormatter = newMainViewModel.dateFormatter {
                    currentDateLabel = "as of " + String(describing: dateFormatter.string(from: Date()))
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
