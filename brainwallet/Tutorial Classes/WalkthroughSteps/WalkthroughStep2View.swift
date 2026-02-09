//
//  WalkthroughStep2View.swift
//  brainwallet
//
//  Created by Kerry Washington on 23/01/2026.
//  Copyright © 2026 Grunt Software, LTD. All rights reserved.
//
import SwiftUI

struct WalkthroughStep2View: View {

    @Binding
    var selectedStep: Int

    @Binding
    var userPrefersDarkTheme: Bool

    private let titleStep2 = String(localized: "2. Settings & Dark Mode")
    private let descriptionStep2 = """
    Fine tune by tapping on Settings to the top right. \
    Set your Dark Mode preference by tapping on the ☀️ on the top left.
    """

    init(selectedStep: Binding<Int>,
         userPrefersDarkTheme: Binding<Bool>) {
        _userPrefersDarkTheme = userPrefersDarkTheme
        _selectedStep = selectedStep
    }

    var body: some View {
        GeometryReader { geometry in

            let width = geometry.size.width

            let calloutWidth = width * 0.7
            let pointToBalanceOffset = 85.0
            ZStack {
                VStack {
                    HStack {
                        CalloutTextView(title: titleStep2,
                                        description: descriptionStep2,
                                        corner: .constant(.topRight),
                                        userPrefersDarkTheme: $userPrefersDarkTheme)
                        .frame(width: calloutWidth, alignment: .bottom)
                        .padding([.leading], pointToBalanceOffset)
                      Spacer()
                    }
                    .frame(height: calloutHeight, alignment: .bottom)
                    .padding(.top, brainwalletNavBarHeight)
                  Spacer()
                }
            }
        }
    }
}
