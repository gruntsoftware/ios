//
//  EmptyTransactionRow.swift
//  brainwallet
//
//  Created by Kerry Washington on 02/11/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

import SwiftUI

struct EmptyTransactionRow: View {

    @Binding
    var userPrefersDarkTheme: Bool

    init(userPrefersDarkTheme: Binding<Bool>) {
        _userPrefersDarkTheme = userPrefersDarkTheme
    }

    var body: some View {
        GeometryReader { _ in

            ZStack {
                BentoBackgroundView(userPrefersDarkTheme: $userPrefersDarkTheme).edgesIgnoringSafeArea(.all)
                VStack {
                    Spacer()
                    HStack {
                        Text("TRANSACTION HISTORY")
                            .font(.ibmPlexSansBold(size: 17.0))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundStyle( userPrefersDarkTheme ? .white: BrainwalletColor.nearBlack.opacity(0.8))

                        Spacer()
                    }
                    .padding(.leading, 16)

                    HStack {
                        Text("Nothing yet. Top up now!")
                            .font(.ibmPlexSansThin(size: 15.0))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .foregroundStyle( userPrefersDarkTheme ? .white: BrainwalletColor.nearBlack.opacity(0.8))
                            Spacer()
                    }
                    .padding(.leading, 16)
                    Spacer()

                }
            }
        }
    }
}
