//
//  EmojiSetViewModifier.swift
//
//  Created by Kerry Washington on 23/02/2026.
//  Copyright © 2026 Grunt Software, LTD. All rights reserved.
//

import SwiftUI

struct EmojiSetViewModifier<OverlayView: View>: ViewModifier {
 let showEmojiSetView: Bool
 let emojiSetView: OverlayView
   func body(content: Content) -> some View {
        ZStack {
            content
            if showEmojiSetView {
                    emojiSetView
                        .background(.ultraThinMaterial)
                        .zIndex(1)
            }
        }
    }
}

extension View {
    func showEmojiPicker(showEmojiSetView: Bool, emojiSetView: EmojiSetView) -> some View {
        modifier(EmojiSetViewModifier(showEmojiSetView: showEmojiSetView, emojiSetView: emojiSetView))
    }
}
