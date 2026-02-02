//
//  SendStep1View.swift
//  brainwallet
//
//  Created by Kerry Washington on 23/01/2026.
//  Copyright © 2026 Grunt Software, LTD. All rights reserved.
//
import SwiftUI

struct SendStep1View: View {

    @Binding
    var selectedStep: Int

    @Binding
    var userDidTapMP: Bool

    @Binding
    var userPrefersDarkTheme: Bool

    @Environment(\.dismiss)
    var dismiss

    private let titleStep1 = String(localized: "1. Check your balance")
    private let descriptionStep1 = String(localized: "You cannot send if it's zero or it's syncing.\nTop up in 5 minutes with MoonPay if needed.")

    init(selectedStep: Binding<Int>,
         userDidTapMP: Binding<Bool>,
         userPrefersDarkTheme: Binding<Bool>) {
        _userDidTapMP = userDidTapMP
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
                    .padding(.top, brainwalletNavBarHeight + balanceGameBentoHeight)
                    Spacer()
                    Button {
                        userDidTapMP.toggle()
                        dismiss()
                    } label: {
                        VStack {
                            Text(String(localized:" Tap here & top up!"))
                                .font(.ibmPlexSansRegular(size: 16.0))
                                .minimumScaleFactor(0.9)
                                .frame(alignment: .center)
                                .foregroundColor(.white)
                                .padding([.bottom], 20)
                                .accessibilityIdentifier("sendStep1ViewTitle")
                            Image("moonpay-white-logo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: width * 0.4)
                                .shadow(color: .black.opacity(0.6),
                                        radius: 3.0, x: 0, y: 5)
                                .accessibilityIdentifier("sendStep1ViewMoonPayImage")

                        }
                        .padding(20.0)
                        .background(BrainwalletColor.surface.opacity(0.7))
                        .cornerRadius(20.0)
                    }
                    .padding(.bottom, brainwalletNavBarHeight + balanceGameBentoHeight)
                    Spacer()
                }
            }
        }
    }
}
