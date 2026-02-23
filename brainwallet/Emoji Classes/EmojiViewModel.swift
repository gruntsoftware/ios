//
//  EmojiViewModel.swift
//  brainwallet
//
//  Created by Kerry Washington on 22/02/2026.
//  Copyright © 2026 Grunt Software, LTD. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit

struct EmojiSection: Encodable, Equatable, Hashable {
    var sectionTitle: String = ""
    var emojiObjects: [EmojiObject]?
}

struct EmojiObject: Encodable, Equatable, Hashable {
    var emoji: String = ""
    var wordCloud: [String] = [""]
    var unicodeKeywords: String = ""
    var codePoints: [String]
    var hexCodePoints32: [UInt32]
    var order: Int?
}

struct LiteEmojiObject: Equatable, Hashable, Identifiable {
    var emoji: Character
    var tagID = UUID()
    var id: UUID { tagID }
}

enum EmojiTriplet: String, CaseIterable {
    case first
    case second
    case third
    case fourth

    var index: Int {
        switch self {
        case .first:
            return 1
        case .second:
            return 2
        case .third:
            return 3
        case .fourth:
            return 4
        }
    }

    var boxNumbers: [Int] {
        switch self {
        case .first:
            return [1,2,3]
        case .second:
            return [4,5,6]
        case .third:
            return [7,8,9]
        case .fourth:
            return [10,11,12]
        }
    }

    var guideTitle: String {
        switch self {
        case .first:
            return String(localized: "Set your first emojis!")
        case .second:
            return String(localized: "Pick your next emojis.")
        case .third:
            return String(localized: "You are on your way!")
        case .fourth:
            return String(localized: "This is your final set!")
        }
    }

    var guideDetail: String {
        switch self {
        case .first:
            return String(localized: "Tap 🍔 > Security > Seed Phrase > PIN to recall your first 3 words.")
        case .second:
            return String(localized: "Now you know the deal.")
        case .third:
            return String(localized: "Hey? Aren't you the expert.")
        case .fourth:
            return String(localized: "Let's go! 12 seed words.")
        }
    }

    var guideDetail2: String {
        switch self {
        case .first:
            return String(localized: "Pick emojis that mean something personal to you.")
        case .second:
            return String(localized: "Pick your next 3!")
        case .third:
            return String(localized: "Now pick 3 emojis to get to 9")
        case .fourth:
            return String(localized: "Add 3 more emojis, and you have a dozen.")
        }
    }
}

class EmojiViewModel: ObservableObject {

    // MARK: - Public Variables

    @Published
    var currentEmojiTriplet: EmojiTriplet = .first

    @Published
    var didSelectTriplet: Bool = false

    @Published
    var canSelect: Bool = false

    init() {

    }

}
