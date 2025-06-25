//
//  SettingsView.swift
//  brainwallet
//
//  Created by Kerry Washington on 08/05/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//
//
import SwiftUI

struct SettingsView: View {

    @ObservedObject
    var newMainViewModel: NewMainViewModel

    @Binding var path: [Onboarding]

    @State
    private var isLocked: Bool = false

    @State
    private var userPrefersDarkMode: Bool = false

    @State
    private var shouldExpandSecurity: Bool = false

    @State
    private var shouldExpandCurrency: Bool = false

    @State
    private var shouldExpandGames: Bool = false

    @State
    private var shouldExpandBlockchain: Bool = false

    @State
    private var tempRowHeight: CGFloat = closedRowHeight

    let footerRowHeight: CGFloat = 55.0

    let squareButtonSize: CGFloat = 55.0
    let squareImageSize: CGFloat = 25.0
    let themeBorderSize: CGFloat = 44.0
    let largeButtonHeight: CGFloat = 65.0
    let largeButtonFont: Font = .barlowBold(size: 24.0)

    init(viewModel: NewMainViewModel, path: Binding<[Onboarding]>) {
        self.newMainViewModel = viewModel
        _path = path

        userPrefersDarkMode = UserDefaults.userPreferredDarkTheme
    }

    var body: some View {

        NavigationStack {
            GeometryReader { geometry in
                let width = geometry.size.width
                ZStack {
                    BrainwalletColor.content.edgesIgnoringSafeArea(.all)
                    BrainwalletColor.surface.edgesIgnoringSafeArea(.all)
                        .padding(.trailing, 1.0)

                    HStack {
                        VStack {
                            List {
                                SettingsExpandingSecurityView(title: String(localized: "Security"),
                                     viewModel: newMainViewModel, shouldExpandSecurity: $shouldExpandSecurity)
                                .frame(height: shouldExpandSecurity ? 300 : tempRowHeight)
                                .listRowBackground(shouldExpandSecurity ? BrainwalletColor.background : BrainwalletColor.surface)
                                .listRowInsets(EdgeInsets())
                                .listRowSeparatorTint(BrainwalletColor.content)
                                .padding(.leading, leadRowPad)
                                .padding(.trailing, trailRowPad)
                                SettingsExpandingCurrencyView(title: String(localized: "Fiat Currency"),
                                    viewModel: newMainViewModel, shouldExpandCurrency: $shouldExpandCurrency)
                                .frame(height: shouldExpandCurrency ? pickerViewHeight : tempRowHeight)
                                .listRowBackground(shouldExpandCurrency ? BrainwalletColor.background : BrainwalletColor.surface)
                                .listRowInsets(EdgeInsets())
                                .listRowSeparatorTint(BrainwalletColor.content)
                                .padding(.leading, leadRowPad)
                                .padding(.trailing, trailRowPad)
                                SettingsExpandingGamesView(title: String(localized: "Games"),
                                    viewModel: newMainViewModel, shouldExpandGames: $shouldExpandGames)
                                .frame(height: shouldExpandGames ? 200 : tempRowHeight)
                                .listRowBackground(shouldExpandGames ? BrainwalletColor.background : BrainwalletColor.surface)
                                .listRowInsets(EdgeInsets())
                                .listRowSeparatorTint(BrainwalletColor.content)
                                .padding(.leading, leadRowPad)
                                .padding(.trailing, trailRowPad)
                                SettingsExpandingBlockchainView(title: String(localized: "Blockchain: Litecoin"),
                                    viewModel: newMainViewModel, shouldExpandBlockchain: $shouldExpandBlockchain)
                                .frame(maxWidth: .infinity)
                                .frame(height: shouldExpandBlockchain ? 200 : tempRowHeight)
                                .listRowBackground(shouldExpandBlockchain ? BrainwalletColor.background : BrainwalletColor.surface)
                                .listRowInsets(EdgeInsets())
                                .listRowSeparatorTint(BrainwalletColor.content)
                                .padding(.leading, leadRowPad)
                                .padding(.trailing, trailRowPad)
                                SettingsLabelView(title: String(localized: "Social"),
                                                  detailText: "linktr.ee/brainwallet")
                                .frame(height: tempRowHeight)
                                .listRowBackground(BrainwalletColor.surface)
                                .listRowInsets(EdgeInsets())
                                .listRowSeparatorTint(BrainwalletColor.content)
                                .padding(.leading, leadRowPad)
                                .padding(.trailing, trailRowPad)
                                SettingsLabelView(title: String(localized: "Support"),
                                                  detailText: "support.brainwallet.co")
                                .frame(height: tempRowHeight)
                                .listRowBackground(BrainwalletColor.surface)
                                .listRowInsets(EdgeInsets())
                                .listRowSeparatorTint(BrainwalletColor.content)
                                .padding(.leading, leadRowPad)
                                .padding(.trailing, trailRowPad)
                                SettingsActionThemeView(title:
                                    userPrefersDarkMode ?
                                    String(localized: "Dark Mode")
                                    : String(localized: "Light Mode"),
                                    detailText: "",
                                    action: .preferDarkMode,
                                    userPrefersDark: $userPrefersDarkMode)
                                        .frame(height: tempRowHeight)
                                        .listRowBackground(BrainwalletColor.surface)
                                        .listRowInsets(EdgeInsets())
                                        .listRowSeparatorTint(BrainwalletColor.content)
                                        .padding(.leading, leadRowPad)
                                        .padding(.trailing, trailRowPad)

                                SettingsActionLockView(title: String(localized: "Lock"),
                                    detailText: "", action: .lock, isLocked: $isLocked)
                                .frame(height: tempRowHeight)
                                .listRowBackground(BrainwalletColor.surface)
                                .listRowInsets(EdgeInsets())
                                .listRowSeparatorTint(BrainwalletColor.content)
                                .padding(.leading, leadRowPad)
                                .padding(.trailing, trailRowPad)
                            }
                            .listStyle(.plain)
                            .scrollIndicators(.hidden)
                            .buttonStyle(PlainButtonStyle())
                            SettingsFooterView()
                                .frame(height: footerRowHeight * 0.4, alignment: .bottom)
                                .padding(.bottom, 1.0)
                                .padding(.top, 24.0)

                        }
                        .frame(width: width * 0.9)
                        .onChange(of: userPrefersDarkMode) { hasDarkPreference in
                            newMainViewModel.updateTheme(shouldBeDark: hasDarkPreference)
                        }
                        .onChange(of: isLocked) { _ in
                            newMainViewModel.lockBrainwallet()
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.trailing, 1.0)

                }

            }
        }
    }
}

// .frame(width: width * 0.9)
//
// Divider()
//    .frame(width: 1.5)
//    .overlay(BrainwalletColor.content)
