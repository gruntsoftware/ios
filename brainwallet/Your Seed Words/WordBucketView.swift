//
//  WordBucketView.swift
//  brainwallet
//
//  Created by Kerry Washington on 09/07/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

import Foundation
import SwiftUI

struct WordBucketView: View {
    let seedWord: [DraggableSeedWord]

    @State
    private var word: String = ""

    let wordNumber: Int
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

                        Text(word)
                            .font(.barlowRegular(size: 16.0))
                            .foregroundColor(userPrefersDarkTheme ? .white :
                                BrainwalletColor.content)

                        VStack {
                            HStack {
                                Text("\(wordNumber)")
                                    .font(.barlowRegular(size: 12.0))
                                    .foregroundColor(userPrefersDarkTheme ? .white :
                                        BrainwalletColor.content)
                                    .frame(width: 22,
                                           height: cellHeight,
                                           alignment: .leading)
                                    .padding(.leading, genericPad)
                                Spacer()
                            }
                        }
                    }
                    .onChange(of: seedWord) { seedWord in
                        if let draggableWord = seedWord.first,
                           !draggableWord.word.isEmpty {
                            word = draggableWord.word
                        } else {
                            word = ""
                        }
                    }
                }
                .frame(width: width, height: height)
                .padding(.all, genericPad)
            }
            .frame(width: width, height: cellHeight)
        }
    }
}
