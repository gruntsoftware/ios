//
//  ReceiveStep2View.swift
//  brainwallet
//
//  Created by Kerry Washington on 23/01/2026.
//  Copyright © 2026 Grunt Software, LTD. All rights reserved.
//
import SwiftUI

struct ReceiveStep2View: View {

    @Binding
    var selectedStep: Int

    @Binding
    var userPrefersDarkTheme: Bool

    private let titleStep2 = String(localized: "2. Show or share the address")
    private let descriptionStep2 = String(localized: "Balance over zero? Switch to currency or LTC to figure out how much to send. Adjust the network fee in settings")

    init(selectedStep: Binding<Int>,
         userPrefersDarkTheme: Binding<Bool>) {
        _userPrefersDarkTheme = userPrefersDarkTheme
        _selectedStep = selectedStep
    }

    var body: some View {
        GeometryReader { geometry in

            let width = geometry.size.width
            let height = geometry.size.height

            let calloutWidth = width * 0.7
            let pointToBalanceOffset = 85.0
            ZStack {
                VStack {
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
                    .frame(height: calloutHeight, alignment: .bottom)
                    .padding(.bottom, brainwalletNavBarHeight)
                    HStack {

                        CalloutTextView(title: titleStep2,
                                        description: descriptionStep2,
                                        corner: .constant(.bottomLeft),
                                        userPrefersDarkTheme: $userPrefersDarkTheme)
                        .frame(width: calloutWidth, alignment: .bottom)
                      Spacer()

                    }
                    .frame(height: calloutHeight, alignment: .bottom)
                    .padding(.bottom, brainwalletNavBarHeight)
                }
            }
        }
    }
}
