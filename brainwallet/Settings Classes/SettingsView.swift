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

    let closedRowHeight: CGFloat = 55.0

    let squareButtonSize: CGFloat = 55.0
    let squareImageSize: CGFloat = 25.0
    let themeBorderSize: CGFloat = 44.0
    let largeButtonHeight: CGFloat = 65.0
    let largeButtonFont: Font = .barlowBold(size: 24.0)

    init(viewModel: NewMainViewModel, path: Binding<[Onboarding]>) {
        self.newMainViewModel = viewModel
        _path = path
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
                                Section(footer: Text("Footer")) {
                                    SettingsLabelView(title: String(localized: "Security"),
                                                      detailText: "")
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
                                                      detailText: "suppor.brainwallet.co")
                                    .frame(height: closedRowHeight)
                                    SettingsLabelView(title: String(localized: "Lock"),
                                                      detailText: "")
                                    .frame(height: closedRowHeight)
                                }
                            }
                            .listStyle(.plain)
                            Spacer()
                        }
                        .frame(width: width * 0.9)
                    }

                }
            }
        }
    }
}
