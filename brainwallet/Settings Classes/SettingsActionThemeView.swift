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

    let action: SettingsAction

    @Binding
    var userPrefersDark: Bool

    init(title: String, action: SettingsAction, userPrefersDark: Binding<Bool>) {
        self.title = title
        self.action = action
        _userPrefersDark = userPrefersDark
    }

    var body: some View {
        
        VStack(alignment: .leading, spacing: 0.0) {
            Divider()
                .frame(height: 1)
                .overlay(Color.white)
            Text(title)
                .modifier(BWIPSSemiBold(size: 15.0))
                .foregroundColor(BrainwalletColor.content)
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(height: closedRowHeight)
                .overlay(alignment: .trailing) {
                    Button(action: { userPrefersDark.toggle() }) {
                        Image(systemName: userPrefersDark ? action.isOffSystemImage : action.isOnSystemImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 30.0, height: 30.0)
                            .foregroundColor(BrainwalletColor.content)
                    }
                    .frame(width: 30.0, height: 30.0)
                    .contentShape(Rectangle())
                }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .fixedSize(horizontal: false, vertical: true)
    }
}
