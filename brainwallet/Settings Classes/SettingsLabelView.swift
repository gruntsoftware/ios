//
//  SettingsLabelView.swift
//  brainwallet
//
//  Created by Kerry Washington on 19/06/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//
import SwiftUI

struct SettingsLabelView: View {

    private let title: String
    private let detailText: String
    let largeFont: Font = .barlowSemiBold(size: 19.0)
    let detailFont: Font = .barlowLight(size: 19.0)
    let rowBackgroundColor: Color

    init(title: String, detailText: String, rowBackgroundColor: Color? = nil) {
        self.title = title
        self.detailText = detailText
        self.rowBackgroundColor = rowBackgroundColor ?? BrainwalletColor.surface
    }

    var body: some View {
        NavigationStack {
            GeometryReader { _ in
                ZStack {
                    rowBackgroundColor.edgesIgnoringSafeArea(.all)
                    VStack {
                        Text(title)
                            .font(largeFont)
                            .foregroundColor(BrainwalletColor.content)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 4.0)
                            .padding(.bottom, 1.0)
                        Text(detailText)
                            .font(detailFont)
                            .kerning(0.3)
                            .foregroundColor(BrainwalletColor.content)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.bottom, 8.0)
                        Spacer()
                    }
                }
            }
        }
    }
}
