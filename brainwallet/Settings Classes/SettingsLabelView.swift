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
        NavigationStack {
            GeometryReader { _ in
                ZStack {
                    rowBackgroundColor.edgesIgnoringSafeArea(.all)
                    VStack {
                        Text(title)
                            .modifier(BWIPSSemiBold(size: 19.0))
                            .foregroundColor(BrainwalletColor.content)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .frame(height: 25.0)
                            .padding(.top, 8.0)
                        Text(detailText)
                            .modifier(BWIPSRegular(size: 19.0))
                            .kerning(0.2)
                            .foregroundColor(BrainwalletColor.content)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .frame(height: 21.0, alignment: .center)
                            .padding(.bottom, 11.0)
                    }
                }
            }
        }
    }
}
