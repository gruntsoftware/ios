//
//  EmojiPhraseView.swift
//  brainwallet
//
//  Created by Kerry Washington on 22/02/2026.
//  Copyright © 2026 Grunt Software, LTD. All rights reserved.
//
import Foundation
import SwiftUI

struct EmojiPhraseView: View {
    let emojiItem: String
    let emojiNumber: Int
    let genericPad = 16.0
    let cellHeight = 40.0
    let userPrefersDarkTheme = UserDefaults.userPreferredDarkTheme

    var body: some View {
        GeometryReader { geometry in

            let width = geometry.size.width
            let height = geometry.size.height
            ZStack {
                VStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: cellHeight / 2)
                            .frame(height: cellHeight, alignment: .center)
                            .foregroundColor(BrainwalletColor.background.opacity(0.4))

                        Text("\(emojiItem)")
                            .frame(height: cellHeight, alignment: .center)
                            .modifier(BWIPSLight(size: 15.0))
                            .foregroundColor(userPrefersDarkTheme ? .white :
                                BrainwalletColor.content)
                        VStack {
                            HStack {
                                Text("\(emojiNumber)")
                                    .modifier(BWIPSLight(size: 10.0))
                                    .foregroundColor(userPrefersDarkTheme ? .white :
                                        BrainwalletColor.content)
                                    .frame(width: 18,
                                           height: cellHeight,
                                           alignment: .topLeading)
                                    .padding(.leading, genericPad)
                                    .offset(x: -4, y: 3)
                                Spacer()
                            }
                        }
                    }
                }
                .frame(width: width, height: height)
                .padding(.all, genericPad)
            }
            .frame(width: width, height: height)
        }
    }
}
