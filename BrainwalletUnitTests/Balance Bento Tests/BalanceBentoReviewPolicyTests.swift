//
//  BalanceBentoReviewPolicyTests.swift
//  brainwallet
//
//  Copyright © 2026 Grunt Software, LTD. All rights reserved.
//

import XCTest
@testable import brainwallet

final class BalanceBentoReviewPolicyTests: XCTestCase {

    // MARK: - Balance visibility toggle (eye icon)

    func testRequestsReviewWhenBalanceVisibilityToggledToShown() {
        XCTAssertTrue(
            BalanceBentoReviewPolicy.shouldRequestReview(afterTogglingBalanceVisibilityTo: true)
        )
    }

    func testDoesNotRequestReviewWhenBalanceVisibilityToggledToHidden() {
        XCTAssertFalse(
            BalanceBentoReviewPolicy.shouldRequestReview(afterTogglingBalanceVisibilityTo: false)
        )
    }

    // MARK: - Currency emphasis toggle (tap balance to swap LTC/fiat)

    func testRequestsReviewWhenCurrencyEmphasisToggledToLTC() {
        XCTAssertTrue(
            BalanceBentoReviewPolicy.shouldRequestReview(afterTogglingCurrencyEmphasisTo: true)
        )
    }

    func testDoesNotRequestReviewWhenCurrencyEmphasisToggledToFiat() {
        XCTAssertFalse(
            BalanceBentoReviewPolicy.shouldRequestReview(afterTogglingCurrencyEmphasisTo: false)
        )
    }
}
