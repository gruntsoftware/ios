//
//  NetworkFeeTierTests.swift
//  brainwallet
//
//  Covers the fee-tier math backing the Network Fee picker in
//  SettingsLitecoinDetailView (litoshis-per-tier, nearest-tier lookup for a
//  persisted preference, and litoshi -> fiat formatting).
//
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.

@testable import brainwallet
import XCTest

class NetworkFeeTierTests: XCTestCase {

    private let fees = Fees(luxury: 66746, regular: 25000, economy: 8000, timestamp: 0)
    private let usdRate = Rate(code: "USD", name: "US Dollar", rate: 60.0, lastTimestamp: Date())

    // MARK: - litoshis(from:)

    func testLitoshisFromMapsEachTierToItsFeesField() {
        XCTAssertEqual(NetworkFeeTier.economy.litoshis(from: fees), fees.economy)
        XCTAssertEqual(NetworkFeeTier.regular.litoshis(from: fees), fees.regular)
        XCTAssertEqual(NetworkFeeTier.luxury.litoshis(from: fees), fees.luxury)
    }

    // MARK: - closest(to:in:)

    func testClosestReturnsExactTierOnExactMatch() {
        XCTAssertEqual(NetworkFeeTier.closest(to: Int(fees.economy), in: fees), .economy)
        XCTAssertEqual(NetworkFeeTier.closest(to: Int(fees.regular), in: fees), .regular)
        XCTAssertEqual(NetworkFeeTier.closest(to: Int(fees.luxury), in: fees), .luxury)
    }

    func testClosestPicksNearerNeighborBetweenTwoTiers() {
        // Between economy (8000) and regular (25000); nearer to economy.
        XCTAssertEqual(NetworkFeeTier.closest(to: 10_000, in: fees), .economy)
        // Between regular (25000) and luxury (66746); nearer to luxury.
        XCTAssertEqual(NetworkFeeTier.closest(to: 60_000, in: fees), .luxury)
    }

    func testClosestClampsToEconomyBelowLowestTier() {
        XCTAssertEqual(NetworkFeeTier.closest(to: 0, in: fees), .economy)
    }

    func testClosestClampsToLuxuryAboveHighestTier() {
        XCTAssertEqual(NetworkFeeTier.closest(to: 1_000_000, in: fees), .luxury)
    }

    func testClosestBreaksTiesTowardTheLowerTier() {
        // Exactly halfway between economy (8000) and regular (25000) is 16500;
        // a tie should favor the lower (economy) tier.
        let tieFees = Fees(luxury: 30000, regular: 20000, economy: 10000, timestamp: 0)
        XCTAssertEqual(NetworkFeeTier.closest(to: 15000, in: tieFees), .economy)
        // Halfway between regular (20000) and luxury (30000) is 25000.
        XCTAssertEqual(NetworkFeeTier.closest(to: 25000, in: tieFees), .regular)
    }

    func testClosestFallsBackToDefaultValuesWhenNothingIsStored() {
        // UserDefaults.userSetPreferredNetworkFee falls back to Fees.usingDefaultValues.luxury
        // when the user has never picked a fee — confirm that round-trips to .luxury.
        let defaults = Fees.usingDefaultValues
        let storedFee = Int(defaults.luxury)
        XCTAssertEqual(NetworkFeeTier.closest(to: storedFee, in: defaults), .luxury)
    }

    // MARK: - formattedFiatAmount(litoshis:rate:)

    func testFormattedFiatAmountConvertsLitoshisThroughLTCToFiat() {
        // 100_000_000 litoshis == 1 LTC == $60 at a $60/LTC rate.
        let result = NetworkFeeTier.formattedFiatAmount(litoshis: 100_000_000, rate: usdRate)
        XCTAssertEqual(result, "60.000 USD")
    }

    func testFormattedFiatAmountForRealisticRegularFee() {
        // 25000 litoshis at $60/LTC = 0.00025 LTC * 60 = 0.015.
        let result = NetworkFeeTier.formattedFiatAmount(litoshis: fees.regular, rate: usdRate)
        XCTAssertEqual(result, "0.015 USD")
    }

    func testFormattedFiatAmountIsEmptyWhenFeeIsZero() {
        XCTAssertEqual(NetworkFeeTier.formattedFiatAmount(litoshis: 0, rate: usdRate), "")
    }

    func testFormattedFiatAmountIsEmptyWhenRateIsZero() {
        let noRate = Rate(code: "", name: "", rate: 0.0, lastTimestamp: Date())
        XCTAssertEqual(NetworkFeeTier.formattedFiatAmount(litoshis: fees.luxury, rate: noRate), "")
    }

    // MARK: - CaseIterable ordering (Picker tags rely on rawValue == 0/1/2)

    func testAllCasesOrderMatchesPickerTagOrder() {
        XCTAssertEqual(NetworkFeeTier.allCases.map(\.rawValue), [0, 1, 2])
        XCTAssertEqual(NetworkFeeTier.economy.rawValue, 0)
        XCTAssertEqual(NetworkFeeTier.regular.rawValue, 1)
        XCTAssertEqual(NetworkFeeTier.luxury.rawValue, 2)
    }
}
