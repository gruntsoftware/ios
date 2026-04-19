//
//  EmojiViewTests.swift
//  BrainwalletUnitTests
//
//  Created by Kerry Washington on 22/02/2026.
//  Copyright © 2026 Grunt Software, LTD. All rights reserved.
//

import XCTest
import Combine
@testable import brainwallet

final class EmojiViewModelTests: XCTestCase {

    var sut: EmojiViewModel!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        sut = EmojiViewModel()
        cancellables = []
    }

    override func tearDown() {
        sut = nil
        cancellables = nil
        super.tearDown()
    }

    // MARK: - Initial State

    func test_initialState_currentEmojiTriplet_isFirst() {
        XCTAssertEqual(sut.currentEmojiTriplet, .first)
    }

    func test_initialState_didSelectTriplet_isFalse() {
        XCTAssertFalse(sut.didSelectTriplet)
    }

    func test_initialState_canSelect_isFalse() {
        XCTAssertFalse(sut.canSelect)
    }

    // MARK: - EmojiTriplet Index

    func test_emojiTriplet_first_hasCorrectIndex() {
        XCTAssertEqual(EmojiTriplet.first.index, 1)
    }

    func test_emojiTriplet_second_hasCorrectIndex() {
        XCTAssertEqual(EmojiTriplet.second.index, 2)
    }

    func test_emojiTriplet_third_hasCorrectIndex() {
        XCTAssertEqual(EmojiTriplet.third.index, 3)
    }

    func test_emojiTriplet_fourth_hasCorrectIndex() {
        XCTAssertEqual(EmojiTriplet.fourth.index, 4)
    }

    // MARK: - EmojiTriplet Box Numbers

    func test_emojiTriplet_first_hasCorrectBoxNumbers() {
        XCTAssertEqual(EmojiTriplet.first.boxNumbers, [1, 2, 3])
    }

    func test_emojiTriplet_second_hasCorrectBoxNumbers() {
        XCTAssertEqual(EmojiTriplet.second.boxNumbers, [4, 5, 6])
    }

    func test_emojiTriplet_third_hasCorrectBoxNumbers() {
        XCTAssertEqual(EmojiTriplet.third.boxNumbers, [7, 8, 9])
    }

    func test_emojiTriplet_fourth_hasCorrectBoxNumbers() {
        XCTAssertEqual(EmojiTriplet.fourth.boxNumbers, [10, 11, 12])
    }

    func test_emojiTriplet_allBoxNumbers_containsTwelveUniqueNumbers() {
        let allBoxNumbers = EmojiTriplet.allCases.flatMap { $0.boxNumbers }
        XCTAssertEqual(allBoxNumbers.count, 12)
        XCTAssertEqual(Set(allBoxNumbers).count, 12, "Box numbers should all be unique across triplets")
    }

    func test_emojiTriplet_boxNumbers_eachHasThreeEntries() {
        EmojiTriplet.allCases.forEach { triplet in
            XCTAssertEqual(triplet.boxNumbers.count, 3, "\(triplet.rawValue) should have exactly 3 box numbers")
        }
    }

    // MARK: - EmojiTriplet Guide Strings

    func test_emojiTriplet_allCases_haveMeaningfulGuideTitles() {
        EmojiTriplet.allCases.forEach { triplet in
            XCTAssertFalse(triplet.guideTitle.isEmpty, "\(triplet.rawValue) guideTitle should not be empty")
        }
    }

    func test_emojiTriplet_allCases_haveMeaningfulGuideDetails() {
        EmojiTriplet.allCases.forEach { triplet in
            XCTAssertFalse(triplet.guideDetail.isEmpty, "\(triplet.rawValue) guideDetail should not be empty")
            XCTAssertFalse(triplet.guideDetail2.isEmpty, "\(triplet.rawValue) guideDetail2 should not be empty")
        }
    }

    func test_emojiTriplet_guideTitles_areAllUnique() {
        let titles = EmojiTriplet.allCases.map { $0.guideTitle }
        XCTAssertEqual(Set(titles).count, titles.count, "Each triplet should have a unique guideTitle")
    }

    // MARK: - EmojiTriplet CaseIterable

    func test_emojiTriplet_hasExactlyFourCases() {
        XCTAssertEqual(EmojiTriplet.allCases.count, 4)
    }

    func test_emojiTriplet_rawValues_areCorrect() {
        XCTAssertEqual(EmojiTriplet.first.rawValue, "first")
        XCTAssertEqual(EmojiTriplet.second.rawValue, "second")
        XCTAssertEqual(EmojiTriplet.third.rawValue, "third")
        XCTAssertEqual(EmojiTriplet.fourth.rawValue, "fourth")
    }

    // MARK: - @Published Observation

    func test_currentEmojiTriplet_publishesChange_toSecond() {
        let expectation = expectation(description: "currentEmojiTriplet publishes .second")

        sut.$currentEmojiTriplet
            .dropFirst()
            .sink { value in
                XCTAssertEqual(value, .second)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        sut.currentEmojiTriplet = .second

        waitForExpectations(timeout: 1)
    }

    func test_currentEmojiTriplet_publishesAllTransitions() {
        var published: [EmojiTriplet] = []
        let expectation = expectation(description: "all triplet transitions published")
        expectation.expectedFulfillmentCount = 3 // .second, .third, .fourth

        sut.$currentEmojiTriplet
            .dropFirst()
            .sink { value in
                published.append(value)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        sut.currentEmojiTriplet = .second
        sut.currentEmojiTriplet = .third
        sut.currentEmojiTriplet = .fourth

        waitForExpectations(timeout: 1)
        XCTAssertEqual(published, [.second, .third, .fourth])
    }

    func test_didSelectTriplet_publishesChange_toTrue() {
        let expectation = expectation(description: "didSelectTriplet publishes true")

        sut.$didSelectTriplet
            .dropFirst()
            .sink { value in
                XCTAssertTrue(value)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        sut.didSelectTriplet = true

        waitForExpectations(timeout: 1)
    }

    func test_canSelect_publishesChange_toTrue() {
        let expectation = expectation(description: "canSelect publishes true")

        sut.$canSelect
            .dropFirst()
            .sink { value in
                XCTAssertTrue(value)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        sut.canSelect = true

        waitForExpectations(timeout: 1)
    }

    func test_canSelect_publishesChange_backToFalse() {
        sut.canSelect = true

        let expectation = expectation(description: "canSelect publishes false")

        sut.$canSelect
            .dropFirst()
            .sink { value in
                XCTAssertFalse(value)
                expectation.fulfill()
            }
            .store(in: &cancellables)

        sut.canSelect = false

        waitForExpectations(timeout: 1)
    }

    // MARK: - EmojiObject

    func test_emojiObject_equatable_sameValues() {
        let obj1 = EmojiObject(emoji: "🍔", wordCloud: ["burger"], unicodeKeywords: "food", codePoints: ["1F354"], hexCodePoints32: [0x1F354])
        let obj2 = EmojiObject(emoji: "🍔", wordCloud: ["burger"], unicodeKeywords: "food", codePoints: ["1F354"], hexCodePoints32: [0x1F354])
        XCTAssertEqual(obj1, obj2)
    }

    func test_emojiObject_equatable_differentEmoji() {
        let obj1 = EmojiObject(emoji: "🍔", wordCloud: ["burger"], unicodeKeywords: "food", codePoints: ["1F354"], hexCodePoints32: [0x1F354])
        let obj2 = EmojiObject(emoji: "🍕", wordCloud: ["pizza"], unicodeKeywords: "food", codePoints: ["1F355"], hexCodePoints32: [0x1F355])
        XCTAssertNotEqual(obj1, obj2)
    }

    // MARK: - EmojiSection

    func test_emojiSection_equatable_emptySections() {
        let section1 = EmojiSection(sectionTitle: "Food", emojiObjects: nil)
        let section2 = EmojiSection(sectionTitle: "Food", emojiObjects: nil)
        XCTAssertEqual(section1, section2)
    }

    func test_emojiSection_equatable_differentTitles() {
        let section1 = EmojiSection(sectionTitle: "Food", emojiObjects: nil)
        let section2 = EmojiSection(sectionTitle: "Animals", emojiObjects: nil)
        XCTAssertNotEqual(section1, section2)
    }

    // MARK: - LiteEmojiObject

    func test_liteEmojiObject_hasUniqueIDs() {
        let obj1 = LiteEmojiObject(emoji: "🍔")
        let obj2 = LiteEmojiObject(emoji: "🍔")
        XCTAssertNotEqual(obj1.id, obj2.id, "Each LiteEmojiObject should have a unique UUID")
    }

    func test_liteEmojiObject_storesEmoji() {
        let obj = LiteEmojiObject(emoji: "🌮")
        XCTAssertEqual(obj.emoji, "🌮")
    }
}
