//
//  GameHubViewModel.swift
//  brainwallet
//
//  Created by Kerry Washington on 18/02/2026.
//  Copyright © 2026 Grunt Software, LTD. All rights reserved.
//

import Combine
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
    @Published
    var didJustCompleteEmojiSetup: Bool = false

    @Published
    var currentEmojiTriplet: EmojiTriplet = .first

    private var emojiChangeObserver: AnyCancellable?

    init(walletManager: WalletManager? = nil) {
        
        if let manager = walletManager {
            self.walletManager = manager
        }

        // Keeps userEmojisAreSet in sync when emojis are deleted in Settings
        emojiChangeObserver = NotificationCenter.default
            .publisher(for: .emojiStringDidChangeNotification)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                MainActor.assumeIsolated { self?.checkEmojiCount() }
            }
    }

    @objc func checkEmojiCount() {
        guard let walletManager = self.walletManager else { return }
        userEmojisAreSet = (walletManager.emojiStringCount() >= 3) ? true : false
    }
    
    func setFirstEmojiTriplet(first: String, second: String, third: String) -> Bool {
        guard let walletManager = self.walletManager else { return false }
        
        if first.isEmpty || second.isEmpty || third.isEmpty {
            return false
        }
        return walletManager.updateEmojiString("\(first)\(second)\(third)")
    }
    
    func setSecondEmojiTriplet(fourth: String, fifth: String, sixth: String) -> Bool {
        // Only append to the first 3, otherwise a second tap would store 9
        guard let walletManager = self.walletManager,
              walletManager.emojiStringCount() == 3 else { return false }
        
        if fourth.isEmpty || fifth.isEmpty || sixth.isEmpty {
            return false
        }
        return walletManager.updateEmojiString("\(fourth)\(fifth)\(sixth)")
    }

}
