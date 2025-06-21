//
//  SettingsExpandingGamesView.swift
//  brainwallet
//
//  Created by Kerry Washington on 19/06/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//
import SwiftUI

struct SettingsExpandingGamesView: View {

    @ObservedObject
    var viewModel: NewMainViewModel
    @Binding
    var shouldExpandGames: Bool

    @State
    private var rotationAngle: Double = 0

    private var title: String
    let largeFont: Font = .barlowSemiBold(size: 19.0)
    let detailFont: Font = .barlowLight(size: 18.0)

    var securityListView: SecurityListView

    init(title: String, viewModel: NewMainViewModel, shouldExpandGames: Binding <Bool>) {
        self.title = title
        _shouldExpandGames = shouldExpandGames
        self.viewModel = viewModel
        self.securityListView = SecurityListView(viewModel: viewModel)
    }

    var body: some View {
        NavigationStack {
            GeometryReader { _ in
                ZStack {
                    VStack {
                        HStack {
                            Text(title)
                                .font(largeFont)
                                .foregroundColor(BrainwalletColor.content)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.leading, rowLeadingPad)
                            Spacer()

                            VStack {
                                Button(action: {
                                    shouldExpandGames.toggle()
                                }) {
                                    VStack {
                                        HStack {
                                            Image(systemName: "chevron.right")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: expandArrowSize, height: expandArrowSize)
                                                .foregroundColor(BrainwalletColor.content)
                                                .rotationEffect(Angle(degrees: shouldExpandGames ? 90 : 0))
                                        }
                                    }
                                    .frame(width: 30.0, height: 30.0)
                                }
                                .frame(width: 30.0, height: 30.0)
                            }
                        }
                        .frame(height: 44.0)
                        .padding(.top, 1.0)
                        GamesListView(viewModel: viewModel)
                            .transition(.opacity)
                            .transition(.slide)
                            .animation(.easeInOut(duration: 0.7))
                            .frame(height: shouldExpandGames ? 110.0 : 0.1)
                        Spacer()
                    }

                }
            }
        }
    }
}
