//
//  LTCFiatToggleView.swift
//  brainwallet
//
//  Created by Kerry Washington on 14/02/2026.
//  Copyright © 2026 Grunt Software, LTD. All rights reserved.
//

import SwiftUI

struct LTCFiatToggleView: View {

    @Binding
    var userPrefersDarkTheme: Bool

    @Binding
    var isLTCValueShown: Bool

    @Binding
    var fiatCodeString: String

    var body: some View {

        if isLTCValueShown {
            Group {
                Spacer()
                Image(systemName: "arrow.trianglehead.swap")
                    .resizable()
                    .frame(width: 15, height: 15)
                    .foregroundColor(userPrefersDarkTheme ? .white : .black)
                    .scaleEffect(x: 1, y: -1)
                    .animation(.easeInOut(duration: 0.5), value: isLTCValueShown)
                Image("litecoin_cutout24")
                    .ltcIconImageModifier()
                    .foregroundColor(userPrefersDarkTheme ? .white : .black)
                    .padding(.trailing, 8)
            }
        } else {
            Group {
                Spacer()
                Image(systemName: "arrow.trianglehead.swap")
                    .resizable()
                    .frame(width: 15, height: 15)
                    .foregroundColor(userPrefersDarkTheme ? .white : .black)
                    .animation(.easeInOut(duration: 0.5), value: isLTCValueShown)
                Text(fiatCodeString)
                    .modifier(BWIPSBold(size: 18.0))
                    .foregroundColor(userPrefersDarkTheme ? .white : .black)
                    .frame(height: 28, alignment: .center)
                    .padding(.trailing, 8)
            }
        }
    }
}

// #Preview {
//    LTCFiatToggleView()
// }
