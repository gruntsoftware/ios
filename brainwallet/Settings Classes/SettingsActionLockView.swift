//
//  SettingsActionLockView.swift
//  brainwallet
//
//  Created by Kerry Washington on 19/06/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//
import SwiftUI

struct SettingsActionLockView: View {

    private let title: String
    private let detailText: String

    let action: SettingsAction

    @Binding
    var didTriggerLock: Bool

    init(title: String, detailText: String, action: SettingsAction, didTriggerLock: Binding<Bool>) {
        self.title = title
        self.detailText = detailText
        self.action = action
        _didTriggerLock = didTriggerLock
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
                    Button(action: {
                        didTriggerLock.toggle()
                    }) {
                            Image(systemName: didTriggerLock ? action.isOnSystemImage : action.isOffSystemImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 30.0,
                                       height: 30.0)
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
