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
    private var isLocked: Bool = false

    @State
    private var userPrefersDarkMode: Bool = false

    let footerRowHeight: CGFloat = 55.0

    let squareButtonSize: CGFloat = 55.0
    let squareImageSize: CGFloat = 25.0
    let themeBorderSize: CGFloat = 44.0
    let largeButtonHeight: CGFloat = 65.0
    let largeButtonFont: Font = .barlowBold(size: 24.0)

    init(viewModel: NewMainViewModel) {
        self.newMainViewModel = viewModel
    }

    var body: some View {

        NavigationStack {
            GeometryReader { geometry in

                let width = geometry.size.width
                ZStack {
                    BrainwalletColor.surface.edgesIgnoringSafeArea(.all)
                    VStack {
                        List {
//                            SettingsActionView(title: String(localized: "Update PIN"),
//                                detailText: "PIN", action: .lock,
//                                     isSelected: $isLocked)
//                                         .frame(height: closedRowHeight)
//                            SettingsActionView(title: String(localized: "Seed Phrase"),
//                                detailText: "", action: .preferDarkMode,
//                                               isSelected: $userPrefersDarkMode)
//                                        .frame(height: closedRowHeight)
//                            SettingsActionView(title: String(localized: "Brainwallet Phrase"),
//                                detailText: "", action: .lock,
//                                     isSelected: $isLocked)
//                                         .frame(height: closedRowHeight)
//                            SettingsActionView(title: String(localized: "Share Data"),
//                                detailText: "", action: .lock,
//                                     isSelected: $isLocked)
//                                         .frame(height: closedRowHeight)

                        }
                        .listStyle(.plain)
                    }

                }
            }
        }
    }
}
