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
                                SettingsExpandingSecView(title: String(localized: "Security"),
                                     viewModel: newMainViewModel, shouldExpandSecurity: $shouldExpandSecurity)
                                          .frame(height: closedRowHeight)
                                SettingsLabelView(title: String(localized: "Currency"),
                                                  detailText: "")
                                .frame(height: closedRowHeight)
                                SettingsLabelView(title: String(localized: "Games"),
                                                  detailText: "")
                                .frame(height: closedRowHeight)
                                SettingsLabelView(title: String(localized: "Blockchain: Litecoin"),
                                                  detailText: "")
                                .frame(height: closedRowHeight)
                                SettingsLabelView(title: String(localized: "Social"),
                                                  detailText: "linktr.ee/brainwallet")
                                .frame(height: closedRowHeight)
                                SettingsLabelView(title: String(localized: "Support"),
                                                  detailText: "support.brainwallet.co")
                                .frame(height: closedRowHeight)
                                SettingsActionView(title: String(localized: "Dark Mode"),
                                    detailText: "", action: .preferDarkMode,
                                                   isSelected: $userPrefersDarkMode)
                                            .frame(height: closedRowHeight)
                                SettingsActionView(title: String(localized: "Lock"),
                                    detailText: "", action: .lock,
                                         isSelected: $isLocked)
                                             .frame(height: closedRowHeight)

                            }
                            .listStyle(.plain)
                            .buttonStyle(PlainButtonStyle())
                            SettingsFooterView()
                                .frame(width: width * 0.9,
                                       height: footerRowHeight)
                                .padding(.bottom, 1.0)
                        }
                        .frame(width: width * 0.9)
                    }

                }
            }
        }
    }
}
