//
//  BentoSendModalView.swift
//  brainwallet
//
//  Created by Kerry Washington on 03/05/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

import SwiftUI
import FirebaseAnalytics

struct BentoNoSendModalView: View {

    @Binding
    var userPrefersDarkTheme: Bool

    @Binding
    var shouldShowView: Bool

    let darkModeColor = LinearGradient(colors: [BentoColor.sendTopPurple,
                                                BentoColor.sendBottomPurple],
                                       startPoint: .topLeading,
                                       endPoint: .bottomTrailing)
    let lightModeColor = LinearGradient(colors: [.white], startPoint: .topLeading,
                                        endPoint: .bottomTrailing)
    @State
    private var backgroundColor: LinearGradient = LinearGradient(colors: [.white],
                                                                 startPoint: .topLeading,
                                                                 endPoint: .bottomTrailing)

    init(userPrefersDarkTheme: Binding<Bool>,
         shouldShowView: Binding<Bool>) {
        _userPrefersDarkTheme = userPrefersDarkTheme
        _shouldShowView = shouldShowView
    }

    var body: some View {
        GeometryReader { _ in

            let sectionSpacer = 18.0
            let sectionSides = 15.0
            let sectionBottom = 30.0

            let iconSize = 65.0

            ZStack {
                backgroundColor.edgesIgnoringSafeArea(.all)
                VStack {
                    Text("Send is Disabled")
                        .modifier(BWIPSBold(size: 24.0))
                        .foregroundColor(userPrefersDarkTheme ? .white : .black)
                        .padding(sectionSpacer)

                    HStack {
                        Image(systemName: "nosign")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .fontWeight(.heavy)
                            .frame(width: iconSize,
                                   height: iconSize,
                                   alignment: .center)
                            .foregroundColor(BrainwalletColor.error)
                    }

                    HStack {
                        Text("While syncing, sending is not possible. Your local database is catching with up to the latest block adding relevant transactions.\nPlease try again later.")
                            .modifier(BWIPSSemiBold(size: 22.0, lineLimit: 4))
                            .foregroundColor(userPrefersDarkTheme ? .white : .black)
                    }
                    .padding(sectionSides * 1.1)

                    Spacer()

                    HStack {
                        Button(action: {
                            shouldShowView.toggle()
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(userPrefersDarkTheme ? .white : BentoColor.nearNearBlack)
                                    .frame(height: 48)
                                Text("Ok")
                                    .modifier(BWIPSSemiBold(size: 18.0))
                                    .foregroundColor(userPrefersDarkTheme ? .black : .white)
                            }
                        }
                        .frame(height: 48)
                        .padding([.leading, .trailing], sectionSides)
                        .padding(.bottom, sectionBottom)
                    }
                }
            }

        }
        .onAppear {
            backgroundColor = userPrefersDarkTheme ? darkModeColor : lightModeColor
            Analytics.logEvent("user_did_tap_nosend_sheet",
                parameters: nil)
        }
    }
}
