//
//  InputWo.swift
//  brainwallet
//
//  Created by Kerry Washington on 16/07/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//
import SwiftUI

struct InputSeedWordView: View {
    let numberPad = 14.0
    let genericPad = 15.0

    let wordNumber: Int
    let clearSize = 20.0
    let cellHeight = 40.0
    let userPrefersDarkTheme = UserDefaults.userPreferredDarkTheme
    let subDetailFont: Font = .barlowSemiBold(size: 17.0)

    @Binding
    var seedWord: String

    @FocusState
    var isFocused: Bool

    @Binding
    var wordIsSet: Bool

    init(seedWord: Binding<String>, wordIsSet: Binding<Bool>, wordNumber: Int) {
        _seedWord = seedWord
        _wordIsSet = wordIsSet
        self.wordNumber = wordNumber
    }

    var body: some View {
        GeometryReader { geometry in

            let width = geometry.size.width
            let height = geometry.size.height
            let fieldWidth = abs(width - 45.0)
            ZStack {
                VStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: cellHeight / 2)
                            .frame(height: cellHeight, alignment: .center)
                            .foregroundColor(BrainwalletColor.background.opacity(0.4))
                            .overlay(
                                RoundedRectangle(cornerRadius: cellHeight / 2)
                                    .stroke(BrainwalletColor.content.opacity(0.9), lineWidth: 1.5)
                                    .opacity(wordIsSet ? 1.0 : 0.0)
                            )
                        VStack {
                            HStack {
                                Text("\(wordNumber)")
                                    .font(.barlowRegular(size: 12.0))
                                    .foregroundColor(userPrefersDarkTheme ? .white :
                                        BrainwalletColor.content)
                                    .frame(width: 18,
                                           height: cellHeight,
                                           alignment: .leading)
                                    .padding(.leading, numberPad)
                                    .offset(y: -6.0)

                                Spacer()
                            }
                        }
                        HStack {
                            TextField("", text: $seedWord)
                                .frame(width: fieldWidth, height: cellHeight, alignment: .center)
                                .font(subDetailFont)
                                .foregroundColor(BrainwalletColor.content)
                                .keyboardType(.alphabet)
                                .disableAutocorrection(true)
                                .textFieldStyle(PlainTextFieldStyle())
                                .textCase(.lowercase)
                                .padding(.leading, genericPad)
                        }
                    }
                }
                .frame(width: width, height: height)
                .padding(.all, genericPad)
                .onChange(of: seedWord) { _ in
                    if seedWord.count < 2 {
                        wordIsSet = false
                    }
                }
            }
            .frame(width: width, height: height)
        }
    }
}
