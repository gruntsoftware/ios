//
// EmojiView.swift
//
// Grunt Software, Ltd.
// Copyright (c) 2026

import SwiftUI

struct EmojiView: View {
    var emoji: String

    var fontSize: CGFloat = 24.0
    var sizeFactor: CGFloat = 1.0
    var viewColor: Color

    init(emoji: String,
         fontSize: CGFloat = 48.0,
         color: Color = .white,
         factor: CGFloat = 1.0) {
        self.emoji = emoji
        self.fontSize = fontSize
        sizeFactor = factor
        viewColor = color
    }

    var body: some View {
        GeometryReader { geometry in

            let factoredSize = geometry.size.width * sizeFactor

            ZStack {
                Text(emoji)
                    .modifier(BWIPSRegular(size: 30))
            }
        }
    }
}
