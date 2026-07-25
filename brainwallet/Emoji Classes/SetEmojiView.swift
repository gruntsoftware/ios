//
//  SetEmojiView.swift
//  brainwallet
//
//  Created by Kerry Washington on 7/20/26.
//  Copyright © 2026 Grunt Software, LTD. All rights reserved.
//

import SwiftUI

struct SetEmojiView: View {
    
    let seedWord: String
    var viewIndex: Int
    
    @Binding
   var emoji: String
    
    @State
    private var shouldShowSeedWord: Bool = false
     
    @Binding
    var isSelected: Bool
    
    @Binding
    var shouldShowWord: Bool

    
    private let emojisViewGradient = LinearGradient(colors: [BentoColor.color14134C.opacity(0.5),
                                                                BentoColor.color5827E2.opacity(0.1),
                                                                Color.white.opacity(0.1)],
                                                       startPoint: .leading, endPoint: .trailing)
    
    init(isSelected: Binding<Bool>,
         seedWord: String,
         emojiString: Binding<String>,
         shouldShowWord: Binding<Bool>,
         viewIndex: Int) {
        _isSelected = isSelected
        _shouldShowWord = shouldShowWord
        _emoji = emojiString
        self.seedWord = seedWord
        self.viewIndex = viewIndex
    }
    
    var body: some View {
        VStack {
            
            Button(action: {
                isSelected.toggle()
            }) {
                if shouldShowWord {
                    HStack {
                        ZStack {
                            
                            RoundedRectangle(cornerRadius: 16.0)
                                .stroke(isSelected ? .white :.clear, lineWidth: 2.0)
                            Text(seedWord)
                                .modifier(BWIPSRegular(size: 16, lineLimit: 1))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20.0)
                                .padding(.vertical, 8.0)
                                .overlay(alignment: .topLeading) {
                                    Text("\(viewIndex)")
                                        .modifier(BWIPSRegular(size: 9, lineLimit: 1))
                                        .foregroundColor(.white.opacity(0.7))
                                        .offset(x: 8, y: 6)
                                        .accessibilityIdentifier("seedWordIndexNumber\(viewIndex)Label")

                                }
                                .background(
                                    GeometryReader { geometry in
                                        let radius = geometry.size.height / 2
                                        RoundedRectangle(cornerRadius: radius)
                                            .fill(Color.white.opacity(0.1))
                                    }
                                )
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .accessibilityIdentifier("seedWordIndex\(viewIndex)Label")
                        }
                    }
                } else {
                    HStack {
                        ZStack {
                            
                            RoundedRectangle(cornerRadius: 16.0)
                                .stroke(isSelected ? .white :.clear, lineWidth: 2.0)
                                
                                EmojiTextField(text: $emoji,
                                               userPrefersDarkTheme: .constant(true))
                                    .onChange(of: emoji) { _,_ in
                                        
                                        if !emoji.isEmpty {
                                            let firstCharIndex = emoji.index(emoji.startIndex, offsetBy: 1)
                                            let firstChar = String(emoji[..<firstCharIndex])
                                            emoji = firstChar
                                        }
                                    }
                                    .accessibilityIdentifier("emojiIndex\(viewIndex)Label")
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
    }
}
