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
    private var shouldLock: Bool = false

    @State
    private var didTriggerLock: Bool = false

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
    private var shouldShowSocialSheet: Bool = false

    @State
    private var shouldShowSupportSheet: Bool = false

    @State
    private var tempRowHeight: CGFloat = closedRowHeight

    let footerRowHeight: CGFloat = 55.0

    let squareButtonSize: CGFloat = 55.0
    let squareImageSize: CGFloat = 25.0
    let themeBorderSize: CGFloat = 44.0
    let largeButtonHeight: CGFloat = 65.0
    let largeButtonFont: Font = .barlowBold(size: 24.0)

    private let supportURL = URL(string: "https://brainwallet.co/support.html")!

    private let socialsURL = URL(string: "https://linktr.ee/brainwallet")!

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
                                // TBD For when games are live
                                //    SettingsExpandingGamesView(title: String(localized: "Games"),
                                //        viewModel: newMainViewModel, shouldExpandGames: $shouldExpandGames)
                                //    .frame(height: shouldExpandGames ? 200 : tempRowHeight)
                                //    .listRowBackground(shouldExpandGames ? BrainwalletColor.background : BrainwalletColor.surface)
                                //    .listRowInsets(EdgeInsets())
                                //    .listRowSeparatorTint(BrainwalletColor.content)
                                //    .padding(.leading, leadRowPad)
                                //    .padding(.trailing, trailRowPad)
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
                                .onTapGesture {
                                    shouldShowSocialSheet.toggle()
                                }
                                SettingsLabelView(title: String(localized: "Support"),
                                                  detailText: "support.brainwallet.co")
                                .frame(height: tempRowHeight)
                                .listRowBackground(BrainwalletColor.surface)
                                .listRowInsets(EdgeInsets())
                                .listRowSeparatorTint(BrainwalletColor.content)
                                .padding(.leading, leadRowPad)
                                .padding(.trailing, trailRowPad)
                                .onTapGesture {
                                    shouldShowSupportSheet.toggle()
                                }
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
                                    detailText: "", action: .lock, didTriggerLock: $didTriggerLock)
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
                        .onChange(of: didTriggerLock) { _ in
                            shouldLock = true
                            if shouldLock {
                                delay(0.9) {
                                    newMainViewModel.lockBrainwallet()
                                    delay(1.2) {
                                        didTriggerLock = false
                                    }
                                }
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .trailing)
                    .padding(.trailing, 1.0)
                }
            }
        }
        .sheet(isPresented: $shouldShowSocialSheet) {
            ZStack {
                BrainwalletColor.background.edgesIgnoringSafeArea(.all)
                WebView(url: socialsURL, scrollToSignup: .constant(false))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .cornerRadius(8.0)
                    .padding(.top, 12.0)
                    .padding(8.0)
            }
        }
        .sheet(isPresented: $shouldShowSupportSheet) {
            ZStack {
                BrainwalletColor.background.edgesIgnoringSafeArea(.all)
                WebView(url: supportURL, scrollToSignup: .constant(false))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .cornerRadius(8.0)
                    .padding(.top, 12.0)
                    .padding(8.0)
            }
        }
    }
}
