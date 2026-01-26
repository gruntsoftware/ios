//
//  WalkthroughStep3View.swift
//  brainwallet
//
//  Created by Kerry Washington on 23/01/2026.
//  Copyright © 2026 Grunt Software, LTD. All rights reserved.
//
import SwiftUI

struct WalkthroughStep3View: View {

    @Binding
    var selectedStep: Int

    @Binding
    var userPrefersDarkTheme: Bool

    private let titleStep3A = String(localized: "3. Set the values")
    private let descriptionStep3A = String(localized: "You have some LTC? Change your local fiat to figure out how much you can send. Or, calculate in LTC. Go to settings to adjust your preferred network fee")

    private let titleStep3B = String(localized: "Verify before sending!")
    private let descriptionStep3B = String(localized: "Scan or Paste the destination address. Double check! Change your local fiat to figure out how much you can send. Add a memo as a handy reminder. Tap Continue.")

    init(selectedStep: Binding<Int>,
         userPrefersDarkTheme: Binding<Bool>) {
        _userPrefersDarkTheme = userPrefersDarkTheme
        _selectedStep = selectedStep
    }

    var body: some View {
        GeometryReader { geometry in

            let width = geometry.size.width
            let calloutWidth = width * 0.7
            ZStack {
                VStack {
                    HStack {

                        Spacer()

                        CalloutTextView(title: titleStep3A,
                                        description: descriptionStep3A,
                                        corner: .constant(.none),
                                        userPrefersDarkTheme: $userPrefersDarkTheme)
                        .frame(width: calloutWidth)
                        Spacer()

                    }
                    .padding(.top, brainwalletNavBarHeight)
                    Spacer()
                    HStack {
                        Spacer()

                        Image("tutorial-send-set")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: width * 0.4)
                            .clipShape(RoundedRectangle(cornerRadius: 8.0,
                                                        style: .continuous))
                            .shadow(color: .black.opacity(0.6),
                                    radius: 3.0, x: 0, y: 5)
                        Spacer()

                    }
                    Spacer()
                    HStack {
                        Spacer()

                        CalloutTextView(title: titleStep3B,
                                        description: descriptionStep3B,
                                        corner: .constant(.none),
                                        userPrefersDarkTheme: $userPrefersDarkTheme)
                        .frame(width: calloutWidth)
                        Spacer()

                    }
                    .padding(.top, brainwalletNavBarHeight)

                }
            }
        }
    }
}
