//
//  GamesListView.swift
//  brainwallet
//
//  Created by Kerry Washington on 08/05/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//
//
import SwiftUI

struct GamesListView: View {

    @ObservedObject
    var newMainViewModel: NewMainViewModel

    let rowBackground: Color = BrainwalletColor.background

    init(viewModel: NewMainViewModel) {
        self.newMainViewModel = viewModel
    }

    var body: some View {

        NavigationStack {
            GeometryReader { geometry in

                let width = geometry.size.width
                ZStack {
                    BrainwalletColor.surface.edgesIgnoringSafeArea(.all)
                    HStack {
                        VStack {
                            List {
                                SettingsLabelView(title: String(localized: "Game 1"),
                                                  detailText: String(localized: "Coming soon... 🤩"),
                                                  rowBackgroundColor: rowBackground)
                                .frame(height: closedRowHeight)
                                .background(BrainwalletColor.background)
                                .listRowBackground(BrainwalletColor.background)
                                .listRowSeparatorTint(BrainwalletColor.content)
                                SettingsLabelView(title: String(localized: "Game 2"),
                                                  detailText: String(localized: "Coming soon... 🍔"),
                                                  rowBackgroundColor: rowBackground)
                                .frame(height: closedRowHeight)
                                .background(BrainwalletColor.background)
                                .listRowBackground(BrainwalletColor.background)
                                .listRowSeparatorTint(BrainwalletColor.content)
                                SettingsLabelView(title: String(localized: "Game 3"),
                                                  detailText: String(localized: "Coming soon... 🪲"),
                                                  rowBackgroundColor: rowBackground)
                                .frame(height: closedRowHeight)
                                .background(BrainwalletColor.background)
                                .listRowBackground(BrainwalletColor.background)
                                .listRowSeparatorTint(BrainwalletColor.content)
                                SettingsLabelView(title: String(localized: "Game 4"),
                                                  detailText: String(localized: "Coming soon... 👺"),
                                                  rowBackgroundColor: rowBackground)
                                .frame(height: closedRowHeight)
                                .background(BrainwalletColor.background)
                                .listRowBackground(BrainwalletColor.background)
                                .listRowSeparatorTint(BrainwalletColor.content)
                            }
                            .listStyle(.plain)
                        }
                    }

                }
            }
        }
    }
}
