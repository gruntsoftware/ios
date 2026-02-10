//
//  WalkthroughStep5View.swift
//  brainwallet
//
//  Created by Kerry Washington on 23/01/2026.
//  Copyright © 2026 Grunt Software, LTD. All rights reserved.
//
import SwiftUI
import FirebaseAnalytics

struct WalkthroughStep5View: View {

    @Binding
    var selectedStep: Int

    @Binding
    var userPrefersDarkTheme: Bool

    private let titleStep5 = String(localized: "Go Gaming")
    private let descriptionStep5 = """
                                   Tap on the Game Hub to try out Brainwallet's games. \
                                   Check back regularly to see what's new!
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
                    Spacer()
                    HStack {
                        CalloutTextView(title: titleStep5,
                                        description: descriptionStep5,
                                        corner: .constant(.bottomLeft),
                                        userPrefersDarkTheme: $userPrefersDarkTheme)
                        .frame(width: calloutWidth)
                        .padding([.leading], pointToBalanceOffset)
                      Spacer()
                    }
                    .frame(height: calloutHeight, alignment: .top)
                    .padding(.bottom, brainwalletNavBarHeight + balanceBentoHeight)
                }
            }
        }
        .onAppear {
            Analytics
                .logEvent("user_completed_walkthrough_tutorial",
                parameters: [
                    "platform": "ios",
                    "app_version": AppVersion.string
                ])
        }
    }
}
