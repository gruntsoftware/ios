//
//  GameHubViewModel.swift
//  brainwallet
//
//  Created by Kerry Washington on 18/02/2026.
//  Copyright © 2026 Grunt Software, LTD. All rights reserved.
//

import SwiftUI

@MainActor
class GameHubViewModel: ObservableObject {

    // MARK: - Public Variables
    var walletManager: WalletManager? {
        didSet {
            showEmojiPicker()
        }
    }

    @Published
    var shouldUserSetEmojis: Bool = false

    @Published
    var currentEmojiTriplet: EmojiTriplet = .first

    init(walletManager: WalletManager? = nil) {
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
     }

    @objc func showEmojiPicker() {

        guard let walletManager = self.walletManager else { return }

        /// TBD After the Unity code is ready
        if walletManager.wallet != nil,
           ((walletManager.emojiStringCount() % 3) == 0) {

            switch walletManager.emojiStringCount() / 3 {
            case 0:
                currentEmojiTriplet = .first
                shouldUserSetEmojis.toggle()
            case 1:
                currentEmojiTriplet = .second
            case 2:
                currentEmojiTriplet = .third
            case 3:
                currentEmojiTriplet = .fourth
            default :
                break
            }
        }

    }
}
