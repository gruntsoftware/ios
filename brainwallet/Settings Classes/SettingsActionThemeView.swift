//
//  SettingsActionThemeView.swift
//  brainwallet
//
//  Created by Kerry Washington on 19/06/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//
import SwiftUI

struct SettingsActionThemeView: View {

    private let title: String
    private let detailText: String
    let largeFont: Font = .barlowSemiBold(size: 19.0)
    let detailFont: Font = .barlowLight(size: 18.0)
    let action: SettingsAction

    @Binding
    var userPrefersDark: Bool

    init(title: String, detailText: String, action: SettingsAction, userPrefersDark: Binding<Bool>) {
        self.title = title
        self.detailText = detailText
        self.action = action
        _userPrefersDark = userPrefersDark
    }

    var body: some View {
        NavigationStack {
            GeometryReader { _ in
                ZStack {
                    HStack {
                        VStack {
                            Text(title)
                                .font(largeFont)
                                .foregroundColor(BrainwalletColor.content)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top, 4.0)
                            Text(detailText)
                                .font(detailFont)
                                .foregroundColor(BrainwalletColor.content)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding([.top, .bottom], 1.0)
                            Spacer()
                        }

                        Spacer()
                        VStack {
                            Button(action: { userPrefersDark.toggle() }) {
                                VStack {
                                    Image(systemName: userPrefersDark ? action.isOffSystemImage : action.isOnSystemImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 30.0,
                                               height: 30.0)
                                        .foregroundColor(BrainwalletColor.content)
                                        .padding(20.0)
                                    Spacer()
                                }
                            }
                            .frame(width: 30.0, height: 30.0)
                        }
                    }.onAppear {
                        userPrefersDark = UserDefaults.userPreferredDarkTheme
                    }
                }
            }
        }
    }
}
