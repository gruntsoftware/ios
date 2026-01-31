//
//  WalkthroughStep4View.swift
//  brainwallet
//
//  Created by Kerry Washington on 23/01/2026.
//  Copyright © 2026 Grunt Software, LTD. All rights reserved.
//
import SwiftUI

struct WalkthroughStep4View: View {

    @Binding
    var selectedStep: Int

    @Binding
    var userPrefersDarkTheme: Bool

    private let titleStep4 = String(localized: "Check the LTC Price")
    private let descriptionStep4 = """
                                    Brainwallet updates the market price of Litecoin (LTC) regularly. \
                                    Pick your local currency to get the exchange rate by swiping.
                                    Use your countries flag as a guide!
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
            let pointToBalanceOffset = 65.0
            ZStack {
                VStack {
                    HStack {
                        CalloutTextView(title: titleStep4,
                                        description: descriptionStep4,
                                        corner: .constant(.bottomRight),
                                        userPrefersDarkTheme: $userPrefersDarkTheme)
                        .frame(width: calloutWidth)
                        .padding([.leading], pointToBalanceOffset)
                      Spacer()

                    }
                    .frame(height: calloutHeight, alignment: .top)
                    .padding(.top, brainwalletNavBarHeight + balanceGameBentoHeight + transactionsBentoHeight * 0.5)
                    Spacer()
                }
            }
        }
    }
}

// Spacer()
// HStack {
//    Spacer()
//    CalloutTextView(title: titleStep3A,
//                    description: descriptionStep3A,
//                    corner: .constant(.bottomRight),
//                    userPrefersDarkTheme: $userPrefersDarkTheme)
//    .frame(width: calloutWidth)
//    Spacer()
// }
// .frame(height: calloutHeight, alignment: .bottom)
// .padding(.bottom, brainwalletNavBarHeight)
