//
//  NetworkHelperSignUrlTests.swift
//  brainwallet
//
//  Copyright © 2026 Grunt Software, LTD. All rights reserved.
//

import XCTest
@testable import brainwallet

final class NetworkHelperSignUrlTests: XCTestCase {

    private func makeSigningData(ipAddress: String) -> MoonpaySigningData {
        MoonpaySigningData(baseCurrencyCode: "USD",
                            baseCurrencyAmount: "100.0",
                            language: "en",
                            walletAddress: "LTCTestAddress123",
                            ipAddress: ipAddress,
                            userPreferredCurrencyCode: "ltc",
                            externalTransactionId: "test-external-id",
                            currencyCode: "ltc",
                            themeId: "main-v1.0.0",
                            theme: "dark")
    }

    func testSignUrlRequestStringIncludesIPAddress() {
        let signingData = makeSigningData(ipAddress: "203.0.113.42")

        let urlString = NetworkHelper.signUrlRequestString(baseURL: "https://api.brainwallet.co/",
                                                             mpData: signingData)

        XCTAssertTrue(urlString.contains("ipAddress=203.0.113.42"),
                       "sign-url request must include the resolved ipAddress: \(urlString)")
    }

    func testSignUrlRequestStringOmitsNothingWhenIPAddressIsEmpty() {
        // Documents current (pre-fetch) behavior: an empty ipAddress still
        // produces a well-formed query parameter rather than being dropped.
        let signingData = makeSigningData(ipAddress: "")

        let urlString = NetworkHelper.signUrlRequestString(baseURL: "https://api.brainwallet.co/",
                                                             mpData: signingData)

        XCTAssertTrue(urlString.contains("ipAddress=&"),
                      "expected an explicit, empty ipAddress parameter: \(urlString)")
    }

    func testSignUrlRequestStringIsAValidURL() {
        let signingData = makeSigningData(ipAddress: "203.0.113.42")

        let urlString = NetworkHelper.signUrlRequestString(baseURL: "https://api.brainwallet.co/",
                                                             mpData: signingData)

        XCTAssertNotNil(URL(string: urlString))
    }

    func testSignUrlRequestStringIncludesAllSigningFields() {
        let signingData = makeSigningData(ipAddress: "203.0.113.42")

        let urlString = NetworkHelper.signUrlRequestString(baseURL: "https://api.brainwallet.co/",
                                                             mpData: signingData)

        XCTAssertTrue(urlString.contains("baseCurrencyCode=USD"))
        XCTAssertTrue(urlString.contains("baseCurrencyAmount=100.0"))
        XCTAssertTrue(urlString.contains("language=en"))
        XCTAssertTrue(urlString.contains("walletAddress=LTCTestAddress123"))
        XCTAssertTrue(urlString.contains("ipAddress=203.0.113.42"))
        XCTAssertTrue(urlString.contains("userPreferredCurrencyCode=ltc"))
        XCTAssertTrue(urlString.contains("externalTransactionId=test-external-id"))
        XCTAssertTrue(urlString.contains("currencyCode=ltc"))
        XCTAssertTrue(urlString.contains("themeId=main-v1.0.0"))
        XCTAssertTrue(urlString.contains("theme=dark"))
    }
}
