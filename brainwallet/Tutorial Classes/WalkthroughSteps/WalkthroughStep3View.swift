//
//  WalkthroughStep3View.swift
//  brainwallet
//
//  Created by Kerry Washington on 23/01/2026.
//  Copyright © 2026 Grunt Software, LTD. All rights reserved.
//
import SwiftUI

struct WalkthroughStep3View: View {

    @Environment(\.requestReview)
    private var requestReview

    @Binding
    var selectedStep: Int

    @Binding
    var userPrefersDarkTheme: Bool

    private let titleStep3 = String(localized: "Review your Transactions")
    private let descriptionStep3 = """
    When you make transactions, they show up here. \
    Swipe up and down to make a quick check.
    Tap lower left corner to toggle All, Receive or Sent transactions.
    """

    private let titleStep3A = String(localized: "Go Deep!")
    private let descriptionStep3A = """
    Tap on History to show more detail and expand the view. \
    Swipe up or down to scroll through the all information.
    """

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
            ZStack {
                VStack {
                    HStack {
                        Spacer()
                        CalloutTextView(title: titleStep3,
                                        description: descriptionStep3,
                                        corner: .constant(.bottomLeft),
                                        userPrefersDarkTheme: $userPrefersDarkTheme)
                        .frame(width: calloutWidth)
                        Spacer()
                    }
                    .padding(.top, brainwalletNavBarHeight)
                    Spacer()
                    HStack {
                        Spacer()
                        CalloutTextView(title: titleStep3A,
                                        description: descriptionStep3A,
                                        corner: .constant(.bottomRight),
                                        userPrefersDarkTheme: $userPrefersDarkTheme)
                        .frame(width: calloutWidth)
                        Spacer()
                    }
                    .frame(height: calloutHeight, alignment: .bottom)
                    .padding(.bottom, brainwalletNavBarHeight)

                }
                .frame(height: height)
            }
        }
        .onAppear {
            requestReview()
            debugPrint("did_request_rating")
        }

    }
}
