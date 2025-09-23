import Foundation
import SwiftUI

// Draft list of mock data to inject into tests
struct MockSeeds {
	static let date100 = Date(timeIntervalSince1970: 1000)
	static let rate100 = Rate(code: "USD", name: "US Dollar", rate: 43.3833, lastTimestamp: date100)
	static let amount100 = Amount(amount: 100, rate: rate100, maxDigits: 4_443_588_634)
	static let walletManager: WalletManager = try! WalletManager(store: Store(), dbPath: nil)
    static let twelveWords = [  SeedWord(word: "banana", tagNumber: 1), SeedWord(word: "apple", tagNumber: 2),
                                SeedWord(word: "orange", tagNumber: 3), SeedWord(word: "banana", tagNumber: 4),
                                SeedWord(word: "apple", tagNumber: 5), SeedWord(word: "orange", tagNumber: 6),
                                SeedWord(word: "banana", tagNumber: 7), SeedWord(word: "apple", tagNumber: 8),
                                SeedWord(word: "orange", tagNumber: 9), SeedWord(word: "banana", tagNumber: 10),
                                SeedWord(word: "apple", tagNumber: 11), SeedWord(word: "orange", tagNumber: 12)]
}

struct MockData {
	static let cardImage: Image = .init("litecoin-front-card-border")
	static let cardImageString: String = "litecoin-front-card-border"
	static let smallBalance: Double = 0.055122
	static let largeBalance: Double = 48235.059349
	static let testLTCAddress: String = "QieeWYTdgF7tJu6suEnpyoWry1YxJ3Egvs"
}

let mockDraggableArray : [DraggableSeedWord] = [
    DraggableSeedWord(id: UUID(), tagNumber: 1, word: "these", doesMatch: false),
    DraggableSeedWord(id: UUID(), tagNumber: 2, word: "are", doesMatch: false),
    DraggableSeedWord(id: UUID(), tagNumber: 3, word: "not", doesMatch: false),
    DraggableSeedWord(id: UUID(), tagNumber: 4, word: "the", doesMatch: false),
    DraggableSeedWord(id: UUID(), tagNumber: 5, word: "droids", doesMatch: false),
    DraggableSeedWord(id: UUID(), tagNumber: 6, word: "you", doesMatch: false),
    DraggableSeedWord(id: UUID(), tagNumber: 7, word: "are", doesMatch: false),
    DraggableSeedWord(id: UUID(), tagNumber: 8, word: "looking", doesMatch: false),
    DraggableSeedWord(id: UUID(), tagNumber: 9, word: "for", doesMatch: false),
    DraggableSeedWord(id: UUID(), tagNumber: 10, word: "he", doesMatch: false),
    DraggableSeedWord(id: UUID(), tagNumber: 11, word: "can", doesMatch: false),
    DraggableSeedWord(id: UUID(), tagNumber: 12, word: "go", doesMatch: false) ]
