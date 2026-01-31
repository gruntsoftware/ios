//
//  ReceiveStep2View.swift
//  brainwallet
//
//  Created by Kerry Washington on 23/01/2026.
//  Copyright © 2026 Grunt Software, LTD. All rights reserved.
//
import SwiftUI
import FirebaseAnalytics

struct ReceiveStep2View: View {

    @Binding
    var selectedStep: Int

    @Binding
    var userPrefersDarkTheme: Bool

    private let titleStep2 = String(localized: "2. Pick the amount and payment method")
    private let descriptionStep2 = String(localized: "The whole process will be done on in 5 mins!")

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
                    Spacer()
                    HStack {
                        Spacer()
                        Image("moonpay-sheet")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: width * 0.8)
                            .clipShape(RoundedRectangle(cornerRadius: 12.0,
                                                        style: .continuous))
                            .shadow(color: .black.opacity(0.6),
                                    radius: 3.0, x: 0, y: 5)
                        Spacer()
                    }
                    .padding(.bottom, brainwalletNavBarHeight)
                    HStack {
                        Spacer()
                        CalloutTextView(title: titleStep2,
                                        description: descriptionStep2,
                                        corner: .constant(.none),
                                        userPrefersDarkTheme: $userPrefersDarkTheme)
                        .frame(width: calloutWidth, alignment: .bottom)
                      Spacer()

                    }
                    .frame(height: calloutHeight, alignment: .bottom)
                    .padding(.bottom, brainwalletNavBarHeight)
                }
            }
        }
        .onAppear {
            Analytics
                .logEvent("user_completed_receive_tutorial",
                parameters: [
                    "platform": "ios",
                    "app_version": AppVersion.string
                ])
        }
    }
}
