//
//  SettingsActionToggleView.swift
//  brainwallet
//
//  Created by Kerry Washington on 24/06/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//
import SwiftUI

struct SettingsActionToggleView: View {

    private let title: String
    private let detailText: String

    let detailFont: Font = .ibmPlexSansLight(size: 15.0)
    let action: SettingsAction

    @Binding
    var isOn: Bool

    init(title: String, detailText: String, action: SettingsAction, isOn: Binding<Bool>) {
        self.title = title
        self.detailText = detailText
        self.action = action
        _isOn = isOn
    }

    var body: some View {
        NavigationStack {
            GeometryReader { _ in
                ZStack {
                    HStack {
                        VStack {
                            Text(title)
                                .modifier(BWIPSSemiBold(size: 19.0))
                                .foregroundColor(BrainwalletColor.content)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top, 4.0)
                            Text(detailText)
                                .modifier(BWIPSLight(size: 18.0))
                                .kerning(0.6)
                                .foregroundColor(BrainwalletColor.content)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.bottom, 1.0)
                            Spacer()
                        }

                        Spacer()
                        VStack {
                            Toggle(isOn: $isOn) {
                            }
                            .toggleStyle(.switch)
                            .padding(.top, 4.0)
                            Spacer()
                        }
                        .padding(.trailing, 1.0)

                    }
                }
            }
        }
    }
}
