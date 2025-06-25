//
//  SecurityListView.swift
//  brainwallet
//
//  Created by Kerry Washington on 08/05/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//
//
import SwiftUI

struct SecurityListView: View {

    @ObservedObject
    var newMainViewModel: NewMainViewModel

    @State
    private var willChangePIN: Bool = false

    @State
    private var willShowSeedPhrase: Bool = false

    @State
    private var willShowBrainwalletPhrase: Bool = false

    @State
    private var willShareData: Bool = false

    @State
    private var userPrefersDarkMode: Bool = false

    let footerRowHeight: CGFloat = 55.0

    let squareButtonSize: CGFloat = 55.0
    let squareImageSize: CGFloat = 25.0
    let themeBorderSize: CGFloat = 44.0
    let largeButtonHeight: CGFloat = 65.0
    let largeButtonFont: Font = .barlowBold(size: 24.0)
    let rowBackground: Color = BrainwalletColor.background
    init(viewModel: NewMainViewModel) {
        self.newMainViewModel = viewModel
    }

    var body: some View {

        NavigationStack {
            GeometryReader { geometry in

                    let width = geometry.size.width
                    let height = geometry.size.height

                ZStack {
                    BrainwalletColor.surface.edgesIgnoringSafeArea(.all)
                        List {
                            SettingsResetPINView(title: String(localized: "Update PIN"),
                                detailText: String(localized: "PIN"),
                                action: .toggle, isOn: $willChangePIN)
                                .frame(height: updatePINRowHeight)
                                .background(BrainwalletColor.background)
                                .listRowBackground(BrainwalletColor.background)
                                .listRowSeparatorTint(BrainwalletColor.content)
                            SettingsActionToggleView(title: String(localized: "Seed Phrase"),
                                detailText: String(localized: "Show my seed phrase"),
                                action: .toggle, isOn: $willShowSeedPhrase)
                                .frame(height: toggleRowHeight)
                                .background(BrainwalletColor.background)
                                .listRowBackground(BrainwalletColor.background)
                                .listRowSeparatorTint(BrainwalletColor.content)
                            SettingsActionToggleView(title: String(localized: "Brainwallet Phrase"),
                                detailText: String(localized: "Show my emojis"),
                                action: .toggle, isOn: $willShowBrainwalletPhrase)
                                .frame(height: toggleRowHeight)
                                .background(BrainwalletColor.background)
                                .listRowBackground(BrainwalletColor.background)
                                .listRowSeparatorTint(BrainwalletColor.content)
                            SettingsActionToggleView(title: String(localized: "Share Anonymous Data"),
                                detailText: "to improve Brainwallet",
                                action: .toggle, isOn: $willShareData)
                                .frame(height: toggleRowHeight)
                                .background(BrainwalletColor.background)
                                .listRowBackground(BrainwalletColor.background)
                                .listRowSeparatorTint(BrainwalletColor.content)
                                .padding(.bottom, 44.0)
                        }
                        .listStyle(.plain)
                        .scrollIndicators(.hidden)

                }
            }
        }
    }
}
