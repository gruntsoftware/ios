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
            checkEmojiCount()
        }
    }

    @Published
    var userEmojisAreSet: Bool = false

    // Session-only: true for the single transition right after the user
    // finishes PickEmojisView. Distinct from userEmojisAreSet, which is
    // re-derived from the Keychain on every launch and would otherwise
    // look identical to a fresh completion.
    @Published
    var didJustCompleteEmojiSetup: Bool = false

    @Published
    var currentEmojiTriplet: EmojiTriplet = .first

    init(walletManager: WalletManager? = nil) {
        
        if let manager = walletManager {
            self.walletManager = manager
        }
    }

    @objc func checkEmojiCount() {
        guard let walletManager = self.walletManager else { return }
        userEmojisAreSet = (walletManager.emojiStringCount() == 3) ? true : false
    }
    
    func setEmojiTriplet(first: String, second: String, third: String) -> Bool {
        guard let walletManager = self.walletManager else { return false }
        
        if first.isEmpty || second.isEmpty || third.isEmpty {
            return false
        }
        return walletManager.updateEmojiString("\(first)\(second)\(third)")
    }

}
