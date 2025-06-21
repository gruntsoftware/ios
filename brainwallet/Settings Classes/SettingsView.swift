//
//  SettingsView.swift
//  brainwallet
//
//  Created by Kerry Washington on 08/05/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//
//
import SwiftUI

let closedRowHeight: CGFloat = 50.0
let expandedRowHeight: CGFloat = 240.0
let rowLeadingPad: CGFloat = 30.0
let expandArrowSize: CGFloat = 20.0

enum SettingsAction: CaseIterable {
    case preferDarkMode
    case wipeData
    case lock

    var isOnSystemImage: String {
        switch self {
        case .preferDarkMode:
            return "moon.circle"
        case .wipeData:
            return "trash"
        case .lock:
            return "lock"
        }
    }

    var isOffSystemImage: String {
        switch self {
        case .preferDarkMode:
            return "sun.max.circle"
        case .wipeData:
            return "trash"
        case .lock:
            return "lock.open"
        }
    }
}

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
    private var expandedRowHeight: CGFloat = 44.0

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
                    BrainwalletColor.surface.edgesIgnoringSafeArea(.all)
                    HStack {
                        Spacer()
                        VStack {
                            List {
                                SettingsExpandingSecurityView(title: String(localized: "Security"),
                                     viewModel: newMainViewModel, shouldExpandSecurity: $shouldExpandSecurity)
                                .frame(height: shouldExpandSecurity ? 200 : 44.0)
                                .background(BrainwalletColor.surface)
                                .listRowBackground(BrainwalletColor.surface)
                                .listRowSeparatorTint(BrainwalletColor.content)
                                SettingsExpandingCurrencyView(title: String(localized: "Fiat Currency"),
                                    viewModel: newMainViewModel, shouldExpandCurrency: $shouldExpandCurrency)
                                .frame(height: shouldExpandCurrency ? 200 : 44.0)
                                .background(BrainwalletColor.surface)
                                .listRowBackground(BrainwalletColor.surface)
                                .listRowSeparatorTint(BrainwalletColor.content)
                                SettingsExpandingGamesView(title: String(localized: "Games"),
                                    viewModel: newMainViewModel, shouldExpandGames: $shouldExpandGames)
                                .frame(height: shouldExpandGames ? 200 : 44.0)
                                .background(BrainwalletColor.surface)
                                .listRowBackground(BrainwalletColor.surface)
                                .listRowSeparatorTint(BrainwalletColor.content)
                                SettingsExpandingBlockchainView(title: String(localized: "Blockchain: Litecoin"),
                                    viewModel: newMainViewModel, shouldExpandBlockchain: $shouldExpandBlockchain)
                                .frame(height: shouldExpandBlockchain ? 200 : 44.0)
                                .background(BrainwalletColor.surface)
                                .listRowBackground(BrainwalletColor.surface)
                                .listRowSeparatorTint(BrainwalletColor.content)
                                SettingsLabelView(title: String(localized: "Social"),
                                                  detailText: "linktr.ee/brainwallet")
                                .frame(height: closedRowHeight)
                                .background(BrainwalletColor.surface)
                                .listRowBackground(BrainwalletColor.surface)
                                .listRowSeparatorTint(BrainwalletColor.content)
                                SettingsLabelView(title: String(localized: "Support"),
                                                  detailText: "support.brainwallet.co")
                                .frame(height: closedRowHeight)
                                .background(BrainwalletColor.surface)
                                .listRowBackground(BrainwalletColor.surface)
                                .listRowSeparatorTint(BrainwalletColor.content)
                                SettingsActionThemeView(title:
                                    userPrefersDarkMode ?
                                    String(localized: "Dark Mode")
                                    : String(localized: "Light Mode"),
                                    detailText: "",
                                    action: .preferDarkMode,
                                    userPrefersDark: $userPrefersDarkMode)
                                        .frame(height: closedRowHeight)
                                        .background(BrainwalletColor.surface)
                                        .listRowBackground(BrainwalletColor.surface)
                                        .listRowSeparatorTint(BrainwalletColor.content)

                                SettingsActionLockView(title: String(localized: "Lock"),
                                    detailText: "", action: .lock, isLocked: $isLocked)
                                .frame(height: closedRowHeight)
                                .background(BrainwalletColor.surface)
                                .listRowBackground(BrainwalletColor.surface)
                                .listRowSeparatorTint(BrainwalletColor.content)

                            }
                            .background(BrainwalletColor.surface)
                            .listStyle(.plain)
                            .scrollIndicators(.hidden)
                            .buttonStyle(PlainButtonStyle())
                            SettingsFooterView()
                                .frame(width: width * 0.9,
                                       height: footerRowHeight)
                                .padding(.bottom, 1.0)
                        }
                        .frame(width: width * 0.9)
                        .onChange(of: userPrefersDarkMode) { hasDarkPreference in
                            newMainViewModel.updateTheme(shouldBeDark: hasDarkPreference)
                        }
                        .onChange(of: isLocked) { _ in
                            newMainViewModel.lockBrainwallet()
                        }
                        Divider()
                            .frame(width: 1.5)
                            .overlay(BrainwalletColor.content)
                    }
                }

            }
        }
    }
}
