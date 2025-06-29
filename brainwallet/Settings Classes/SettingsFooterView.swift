//
//  SettingsFooterView.swift
//  brainwallet
//
//  Created by Kerry Washington on 19/06/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//
import SwiftUI

struct SettingsFooterView: View {

    private let titleFont: Font = .barlowSemiBold(size: 19.0)
    private let detailFont: Font = .barlowLight(size: 18.0)
    private let darkBackgroundColor: Color = BrainwalletColor.nearBlack
    private let lightBackgroundColor: Color = BrainwalletColor.grape
    private var setBackgroundColor: Color = BrainwalletColor.grape

    let userPreferredDarkMode = UserDefaults.userPreferredDarkTheme
    init() {
        setBackgroundColor = userPreferredDarkMode ? darkBackgroundColor : lightBackgroundColor
    }

    var body: some View {
            GeometryReader { _ in

                ZStack {
                    setBackgroundColor.edgesIgnoringSafeArea(.all)
                    HStack {
                        Text("App Version:")
                            .foregroundColor(.white)
                            .font(titleFont)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 44.0)
                        Spacer()
                        Text("\(AppVersion.string)")
                            .foregroundColor(.white)
                            .font(detailFont)
                            .padding(.trailing, 16.0)

                    }
                }
            }
        }
}
