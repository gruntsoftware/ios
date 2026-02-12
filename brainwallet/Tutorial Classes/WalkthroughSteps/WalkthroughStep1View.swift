//
//  WalkthroughStep1View.swift
//  brainwallet
//
//  Created by Kerry Washington on 23/01/2026.
//  Copyright © 2026 Grunt Software, LTD. All rights reserved.
//
import SwiftUI
import FirebaseAnalytics

struct WalkthroughStep1View: View {

    @Binding
    var selectedStep: Int

    @Binding
    var userPrefersDarkTheme: Bool

    private let titleStep1 = String(localized: "1. Check your balance")
    private let descriptionStep1 = String(localized: "You cannot send if it's zero or it's syncing.\nTop up in 5 minutes with MoonPay if needed.")

    init(selectedStep: Binding<Int>,
         userPrefersDarkTheme: Binding<Bool>) {
        _userPrefersDarkTheme = userPrefersDarkTheme
        _selectedStep = selectedStep
    }

    var body: some View {
        GeometryReader { geometry in

            let width = geometry.size.width
            let calloutWidth = width * 0.7
            let pointToBalanceOffset = 65.0
            ZStack {
                VStack {
                    HStack {

                        CalloutTextView(title: titleStep1,
                                        description: descriptionStep1,
                                        corner: .constant(.topLeft),
                                        userPrefersDarkTheme: $userPrefersDarkTheme)
                        .frame(width: calloutWidth)
                        .padding([.leading], pointToBalanceOffset)
                      Spacer()

                    }
                    .padding(.top, brainwalletNavBarHeight + balanceBentoHeight)
                    Spacer()
                }
            }
        }
    }
}
