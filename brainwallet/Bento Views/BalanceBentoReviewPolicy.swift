//
//  BalanceBentoReviewPolicy.swift
//  brainwallet
//
//  Copyright © 2026 Grunt Software, LTD. All rights reserved.
//

/// Decides when BalanceBentoView's two balance toggles should prompt for an
/// App Store review. Kept separate from the view so the directional guards
/// (fire only when revealing/emphasizing, never on the reverse toggle) are
/// unit-testable without a SwiftUI environment.
enum BalanceBentoReviewPolicy {
    static func shouldRequestReview(afterTogglingBalanceVisibilityTo isBalanceNowShown: Bool) -> Bool {
        isBalanceNowShown
    }

    static func shouldRequestReview(afterTogglingCurrencyEmphasisTo isLTCValueNowShown: Bool) -> Bool {
        isLTCValueNowShown
    }
}
