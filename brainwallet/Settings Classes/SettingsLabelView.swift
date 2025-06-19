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
    let detailFont: Font = .barlowLight(size: 18.0)

    init(title: String, detailText: String) {
        self.title = title
        self.detailText = detailText
    }

    var body: some View {
        NavigationStack {
            GeometryReader { _ in
                ZStack {
                    BrainwalletColor.surface.edgesIgnoringSafeArea(.all)
                    VStack {
                        Text(title)
                            .font(largeFont)
                            .foregroundColor(BrainwalletColor.content)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 16.0)
                        Text(detailText)
                            .font(detailFont)
                            .foregroundColor(BrainwalletColor.content)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding([.top, .bottom], 1.0)
                            .padding(.leading, 16.0)
                        Spacer()
                    }
                }
            }
        }
    }
}
