import Foundation

import AVFoundation
import SwiftUI
import UIKit

class SeedViewModel: ObservableObject {
	// MARK: - Combine Variables

	@Published
	var seedWords: [SeedWord] = []

	@Binding
	var enteredPIN: String

	init(enteredPIN: Binding<String>) {
		_enteredPIN = enteredPIN

	}

	func fetchWords(walletManager: WalletManager, appPIN: String) -> [SeedWord]? {
		if let words = walletManager.seedPhrase(pin: appPIN) {
			let wordArray = words.components(separatedBy: " ")
			seedWords.removeAll()

			for (index, word) in wordArray.enumerated() {
				seedWords.append(SeedWord(word: "\(word)", tagNumber: index + 1))
			}
			return seedWords
		} else {
            debugPrint("::: FAILED TO FETCH SEED WORDS")
        }
		return nil
	}

    func loadSeedWords(seedPhrase: [SeedWord]) {
        seedWords.removeAll()
            for wordElement in seedPhrase {
                seedWords.append(SeedWord(word: "\(wordElement.word)",
                    tagNumber: wordElement.tagNumber))
            }
    }
}
