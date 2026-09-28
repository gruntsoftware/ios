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
    let rowBackgroundColor: Color

    init(title: String, detailText: String, rowBackgroundColor: Color? = nil) {
        self.title = title
        self.detailText = detailText
        self.rowBackgroundColor = rowBackgroundColor ?? BrainwalletColor.surface
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0.0) {
            Divider()
                .frame(height: 1)
                .overlay(Color.white)
            VStack(alignment: .leading, spacing: 2.0) {
                Text(title)
                    .modifier(BWIPSSemiBold(size: 15.0))
                    .foregroundColor(BrainwalletColor.content)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(detailText)
                    .modifier(BWIPSRegular(size: 14.0))
                    .kerning(0.2)
                    .foregroundColor(BrainwalletColor.content.opacity(0.8))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: closedRowHeight)
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .fixedSize(horizontal: false, vertical: true)
        .background(rowBackgroundColor)
    }
}
