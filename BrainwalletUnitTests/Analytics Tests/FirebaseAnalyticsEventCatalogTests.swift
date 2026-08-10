//
//  FirebaseAnalyticsEventCatalogTests.swift
//  brainwallet
//
//  Copyright © 2026 Grunt Software, LTD. All rights reserved.
//

import XCTest

/// One `Analytics.logEvent(...)` call site found in the app target's source.
///
/// This is a manually-curated catalog, not a runtime scan, because a number of
/// `Analytics.logEvent` / `LWAnalytics.logEventWithParameters` call sites live in
/// legacy files (e.g. top-level `ApplicationController.swift`, `BuyViewModel.swift`,
/// `LWAnalytics.swift`) that are **not** referenced by the Xcode project and are
/// therefore never compiled into the app. Those are intentionally excluded below.
///
/// When you add, rename, or remove a `Analytics.logEvent(...)` call in the app
/// target, update `FirebaseAnalyticsEventCatalogTests.knownEvents` to match —
/// `testEventCatalogMatchesKnownEventCount` will fail otherwise as a tripwire.
private struct AnalyticsEventRecord {
    let eventName: String
    let sourceFile: String
}

final class FirebaseAnalyticsEventCatalogTests: XCTestCase {

    /// Every `Analytics.logEvent(...)` call site currently compiled into the `brainwallet` app target.
    private static let knownEvents: [AnalyticsEventRecord] = [
        AnalyticsEventRecord(eventName: "wallet_not_initialized", sourceFile: "WalletManager.swift"),
        AnalyticsEventRecord(eventName: "service_data_error", sourceFile: "PartnerData.swift"),
        AnalyticsEventRecord(eventName: "did_play_game", sourceFile: "App Launch Classes/ApplicationController.swift"),
        AnalyticsEventRecord(eventName: "user_did_complete_sync", sourceFile: "New Main Classes/SyncSubBentoViewModel.swift"),
        AnalyticsEventRecord(eventName: "wallet_manager_error", sourceFile: "New Main Classes/NewMainViewModel.swift"),
        AnalyticsEventRecord(eventName: "wallet_creation_error", sourceFile: "Start Welcome Classes/StartView.swift"),
        AnalyticsEventRecord(eventName: "did_start_resync", sourceFile: "Settings Classes/SettingsLitecoinDetailView.swift"),
        AnalyticsEventRecord(eventName: "user_did_tap_buyreceive_sheet", sourceFile: "New Receive Classes/BuyReceiveView.swift"),
        AnalyticsEventRecord(eventName: "did_unlock", sourceFile: "New Lock Screen Classes/LockScreenHostingController.swift"),
        AnalyticsEventRecord(eventName: "user_did_tap_send_sheet", sourceFile: "New Send Classes/Send Views/BentoSendViews/BentoSendModalView.swift"),
        AnalyticsEventRecord(eventName: "user_did_tap_nosend_sheet", sourceFile: "New Send Classes/Send Views/BentoSendViews/BentoNoSendModalView.swift"),
        AnalyticsEventRecord(eventName: "user_did_tap_shop_bento", sourceFile: "Bento Views/Shop Bentos/ShopBentoView.swift"),
        AnalyticsEventRecord(eventName: "user_did_tap_linktree", sourceFile: "Bento Views/Game Hub Bentos/SocialsView.swift")
    ]

    /// Expected number of *call sites* (tracked separately from the distinct-name count
    /// below in case a future event ends up logged from more than one place). Update
    /// alongside `knownEvents`.
    private static let expectedCallSiteCount = 13

    /// Expected number of *distinct* Firebase event names sent to Analytics.
    private static let expectedUniqueEventCount = 13

    // MARK: - Informational catalog

    /// Prints and asserts the full catalog of Firebase Analytics events fired by the app.
    ///
    /// This test is intentionally informational: its primary purpose is to make the
    /// full list of events visible in test output/CI logs, and to fail loudly (as a
    /// tripwire) if the catalog above drifts out of sync with the source.
    func testEventCatalogMatchesKnownEventCount() {
        let callSites = Self.knownEvents
        let uniqueEventNames = Set(callSites.map(\.eventName))

        print("=== Firebase Analytics Event Catalog ===")
        print("\(callSites.count) call site(s) logging \(uniqueEventNames.count) distinct event(s):")
        for record in callSites.sorted(by: { $0.eventName < $1.eventName }) {
            print(" - \(record.eventName)  [\(record.sourceFile)]")
        }
        print("=========================================")

        XCTAssertEqual(
            callSites.count,
            Self.expectedCallSiteCount,
            "Analytics.logEvent call site count changed — update FirebaseAnalyticsEventCatalogTests.knownEvents."
        )
        XCTAssertEqual(
            uniqueEventNames.count,
            Self.expectedUniqueEventCount,
            "Distinct Firebase event name count changed — update FirebaseAnalyticsEventCatalogTests.knownEvents."
        )
    }

    /// Guards against typos/whitespace slipping into an event name (Firebase event
    /// names must be non-empty, ≤ 40 characters, and use only letters, digits, and underscores).
    func testEventNamesAreValidFirebaseIdentifiers() {
        let validCharacters = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyz0123456789_")

        for record in Self.knownEvents {
            XCTAssertFalse(record.eventName.isEmpty, "Event name in \(record.sourceFile) is empty.")
            XCTAssertLessThanOrEqual(
                record.eventName.count,
                40,
                "Firebase event names must be 40 characters or fewer: \(record.eventName)"
            )
            XCTAssertTrue(
                CharacterSet(charactersIn: record.eventName).isSubset(of: validCharacters),
                "Event name '\(record.eventName)' in \(record.sourceFile) contains characters other than lowercase letters, digits, and underscores."
            )
        }
    }
}
