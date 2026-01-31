//
//  ReceiveStep1View.swift
//  brainwallet
//
//  Created by Kerry Washington on 23/01/2026.
//  Copyright © 2026 Grunt Software, LTD. All rights reserved.
//
import SwiftUI

struct ReceiveStep1View: View {

    @Binding
    var selectedStep: Int

    @Binding
    var userPrefersDarkTheme: Bool

    private let titleStep1 = String(localized: "1. Fresh LTC Address")
    private let descriptionStep1 = String(localized: "Brainwallet makes a new address each time. Tap on Buy/Receive Tab show or copy the QR code in the screen that shows.")

    init(selectedStep: Binding<Int>,
         userPrefersDarkTheme: Binding<Bool>) {
        _userPrefersDarkTheme = userPrefersDarkTheme
        _selectedStep = selectedStep
    }

    var body: some View {
        GeometryReader { geometry in

            let width = geometry.size.width
            let height = geometry.size.height
            let calloutWidth = width * 0.6
            ZStack {
                VStack {
                    Spacer()
                    HStack {
                        CalloutTextView(title: titleStep1,
                                        description: descriptionStep1,
                                        corner: .constant(.bottomLeft),
                                        userPrefersDarkTheme: $userPrefersDarkTheme)
                        .frame(width: calloutWidth, alignment: .bottom)
                        .padding([.leading], height * 0.2)
                      Spacer()
                    }
                    .frame(height: calloutHeight, alignment: .bottom)
                    .padding(.bottom, brainwalletNavBarHeight)
                }
            }
        }
    }
}
