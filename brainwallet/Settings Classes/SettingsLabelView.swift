//
//  SettingsLabelView.swift
//  brainwallet
//
//  Created by Kerry Washington on 19/06/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//
import SwiftUI

struct SettingsLabelView: View {

    @State
    private var title = ""

    @State
    private var detailText = ""

    let largeFont: Font = .barlowBold(size: 24.0)
    let detailFont: Font = .barlowLight(size: 14.0)

    init(title: String, detailText: String) {
        self.title = title
        self.detailText = detailText

        debugPrint(":::\(title)")
        debugPrint(":::\(detailText)")

    }

    var body: some View {

        NavigationStack {
            GeometryReader { geometry in

                let width = geometry.size.width
                ZStack {
                    BrainwalletColor.chili.edgesIgnoringSafeArea(.all)
                    HStack {
                        VStack {
                            Text(title)
                                .font(largeFont)
                                .padding()
                            Spacer()
                            Text(detailText)
                                .font(detailFont)
                                .padding()
                        }
                        Spacer()
                    }

                }
            }
        }
    }
}
