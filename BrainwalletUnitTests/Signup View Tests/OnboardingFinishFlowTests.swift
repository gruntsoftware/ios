//
//  OnboardingFinishFlowTests.swift
//  brainwalletUnitTests
//
//  Copyright © 2026 Grunt Software, LTD. All rights reserved.
//

import XCTest
@testable import brainwallet

final class OnboardingFinishFlowTests: XCTestCase {

    // MARK: - Passcode confirmed → next screen

    func test_passcodeConfirmed_newWallet_goesToYourSeedWords() {
        XCTAssertEqual(Onboarding.destinationAfterPasscodeConfirmed(isRestoringAnOldWallet: false),
                       .yourSeedWordsView)
    }

    func test_passcodeConfirmed_restoringWallet_goesToInputWords() {
        XCTAssertEqual(Onboarding.destinationAfterPasscodeConfirmed(isRestoringAnOldWallet: true),
                       .inputWordsView)
    }

    // MARK: - Prove-it phrase matching

    private func slots(filled filledCount: Int) -> [Int: [DraggableSeedWord]] {
        var result: [Int: [DraggableSeedWord]] = [:]
        for index in 1...12 {
            let word = index <= filledCount ? "word\(index)" : ""
            result[index] = [DraggableSeedWord(id: UUID(), tagNumber: index, word: word, doesMatch: !word.isEmpty)]
        }
        return result
    }

    func test_isPhraseMatched_allTwelveFilled_isTrue() {
        XCTAssertTrue(YourSeedProveItView.isPhraseMatched(slots(filled: 12)))
    }

    func test_isPhraseMatched_elevenFilled_isFalse() {
        XCTAssertFalse(YourSeedProveItView.isPhraseMatched(slots(filled: 11)))
    }

    func test_isPhraseMatched_noneFilled_isFalse() {
        XCTAssertFalse(YourSeedProveItView.isPhraseMatched(slots(filled: 0)))
    }

    func test_isPhraseMatched_missingSlot_isFalse() {
        var words = slots(filled: 12)
        words[7] = nil
        XCTAssertFalse(YourSeedProveItView.isPhraseMatched(words))
    }

    // MARK: - Prove-it button title

    func test_primaryButtonTitle_matched_isDone() {
        XCTAssertEqual(YourSeedProveItView.primaryButtonTitle(isPhraseMatched: true),
                       String(localized: "Done"))
    }

    func test_primaryButtonTitle_notMatched_isReset() {
        XCTAssertEqual(YourSeedProveItView.primaryButtonTitle(isPhraseMatched: false),
                       String(localized: "RESET / START OVER"))
    }
}
