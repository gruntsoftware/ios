import XCTest
@testable import brainwallet

@MainActor
final class ConstantsTests: XCTestCase {
    
    // MARK: - Global Layout Constants
    
    func testSwiftUICellPadding() {
        XCTAssertEqual(swiftUICellPadding, 12.0)
    }
    
    func testBigButtonCornerRadius() {
        XCTAssertEqual(bigButtonCornerRadius, 15.0)
    }
    
    func testBentoCornerRadius() {
        XCTAssertEqual(bentoCornerRadius, 14.0, accuracy: 0.001)
    }
    
    func testBrainwalletNavBarHeight() {
        XCTAssertEqual(brainwalletNavBarHeight, 90.0, accuracy: 0.001)
    }
    
    func testCalloutHeight() {
        XCTAssertEqual(calloutHeight, 120.0, accuracy: 0.001)
    }
    
    func testBalanceBentoHeight() {
        XCTAssertEqual(balanceBentoHeight, 105.0, accuracy: 0.001)
    }
    
    func testGameBentoHeight() {
        XCTAssertEqual(gameBentoHeight, 120.0, accuracy: 0.001)
    }
    
    func testTransactionsBentoHeight() {
        XCTAssertEqual(transactionsBentoHeight, 70.0, accuracy: 0.001)
    }
    
    func testIconSize() {
        XCTAssertEqual(iconSize, 20.0, accuracy: 0.001)
    }
    
    func testLargeButtonHeight() {
        XCTAssertEqual(largeButtonHeight, 50.0, accuracy: 0.001)
    }
    
    // MARK: - Protocol / Domain Constants
    
    func testKPinDigitConstant() {
        XCTAssertEqual(kPinDigitConstant, 4)
    }
    
    func testKSeedPhraseLength() {
        XCTAssertEqual(kSeedPhraseLength, 12)
    }
    
    func testKTransactionsFooterHeight() {
        XCTAssertEqual(kTransactionsFooterHeight, 110.0, accuracy: 0.001)
    }
    
    // MARK: - Dust Threshold
    
    /// The standard P2PKH dust limit is 546 litoshis.
    /// Derived from Litecoin Core: (34 output bytes + 148 input bytes) * 3 * minRelayFee(1 lit/byte)
    /// Any output below this value will be rejected by the network with error code -26 (dust).
    func testLitoshiDustThresholdIsStandardP2PKH() {
        XCTAssertEqual(litoshiDustThreshold, 546,
                       "Dust threshold must equal 546 litoshis — the standard P2PKH minimum enforced by Litecoin Core")
    }
    
    func testLitoshiDustThresholdIsPositive() {
        XCTAssertGreaterThan(litoshiDustThreshold, 0)
    }
    
    // MARK: - C Struct: Monetary Constants
    
    func testMaxMoneyMatchesLitecoinSupply() {
        // 84 million LTC × 100,000,000 litoshis/LTC
        let expectedMaxMoney: UInt64 = 84_000_000 * 100_000_000
        XCTAssertEqual(C.maxMoney, expectedMaxMoney)
    }
    
    func testSatoshisPerCoin() {
        XCTAssertEqual(C.satoshis, 100_000_000)
    }
    
    func testLitoshisPerCoin() {
        XCTAssertEqual(C.litoshis, 100_000_000)
    }
    
    func testSatoshisAndLitoshisAreEqual() {
        // Litecoin uses the same 8-decimal-place base unit convention as Bitcoin
        XCTAssertEqual(C.satoshis, C.litoshis)
    }
    
    func testMaxMoneyIsNonZero() {
        XCTAssertGreaterThan(C.maxMoney, 0)
    }
    
    func testMaxMoneyDoesNotOverflowUInt64() {
        // 84M * 100M = 8.4 × 10^15, well within UInt64.max (~1.8 × 10^19)
        XCTAssertLessThan(C.maxMoney, UInt64.max)
    }
    
    // MARK: - C Struct: Identifiers
    
    func testLtcCurrencyCode() {
        XCTAssertEqual(C.ltcCurrencyCode, "LTC")
    }
    
    func testWalletQueueIdentifier() {
        XCTAssertEqual(C.walletQueue, "com.gruntsoftware.brainwalletqueue")
    }
    
    func testNullString() {
        XCTAssertEqual(C.null, "(null)")
    }
    
    func testMaxMemoLength() {
        XCTAssertEqual(C.maxMemoLength, 250)
        XCTAssertGreaterThan(C.maxMemoLength, 0)
    }
    
    func testFeedbackEmail() {
        XCTAssertEqual(C.feedbackEmail, "feedback@brainwallet.co")
        XCTAssertTrue(C.feedbackEmail.contains("@"))
    }
    
    func testSupportEmail() {
        XCTAssertEqual(C.supportEmail, "support@brainwallet.co")
        XCTAssertTrue(C.supportEmail.contains("@"))
    }
    
    // MARK: - C Struct: Timing
    
    func testAnimationDuration() {
        XCTAssertEqual(C.animationDuration, 0.3, accuracy: 0.001)
        XCTAssertGreaterThan(C.animationDuration, 0)
    }
    
    func testSecondsInDay() {
        let expectedSeconds: TimeInterval = 86_400
        XCTAssertEqual(C.secondsInDay, expectedSeconds,
                       "86400 seconds = 24 hours × 60 minutes × 60 seconds")
    }
    
    // MARK: - C Struct: Sizes
    
    func testButtonHeight() {
        XCTAssertEqual(C.Sizes.buttonHeight, 48.0, accuracy: 0.001)
    }
    
    func testSendButtonHeight() {
        XCTAssertEqual(C.Sizes.sendButtonHeight, 165.0, accuracy: 0.001)
    }
    
    func testHeaderHeight() {
        XCTAssertEqual(C.Sizes.headerHeight, 48.0, accuracy: 0.001)
    }
    
    func testLargeHeaderHeight() {
        XCTAssertEqual(C.Sizes.largeHeaderHeight, 220.0, accuracy: 0.001)
    }
    
    // MARK: - C Struct: Network Port
    
    func testStandardMainnetPort() {
        // This test is only meaningful when running against mainnet configuration.
        // Xcode Cloud and CI run unit tests in debug, not testnet, so guard accordingly.
        guard !E.isTestnet else { return }
        XCTAssertEqual(C.standardPort, 9333)
    }
    
    func testStandardTestnetPort() {
        guard E.isTestnet else { return }
        XCTAssertEqual(C.standardPort, 19335)
    }
    
    // MARK: - Padding Subscript
    
    func testPaddingIntSubscript() {
        let padding = Padding()
        XCTAssertEqual(padding[1], 8.0, accuracy: 0.001)
        XCTAssertEqual(padding[2], 16.0, accuracy: 0.001)
        XCTAssertEqual(padding[3], 24.0, accuracy: 0.001)
        XCTAssertEqual(padding[0], 0.0, accuracy: 0.001)
    }
    
    func testPaddingDoubleSubscript() {
        let padding = Padding()
        XCTAssertEqual(padding[1.5], 12.0, accuracy: 0.001)
        XCTAssertEqual(padding[0.5], 4.0, accuracy: 0.001)
    }
    
    func testCDotPaddingConsistency() {
        // C.padding and a standalone Padding() must produce identical values
        let standalone = Padding()
        XCTAssertEqual(C.padding[1], standalone[1])
        XCTAssertEqual(C.padding[2], standalone[2])
    }
    
    // MARK: - URL Strings
    
    func testBrainwalletSupportURL() {
        XCTAssertEqual(BrainwalletSupport.dashboard, "https://brainwallet.co/support.html")
        XCTAssertTrue(BrainwalletSupport.dashboard.hasPrefix("https://"))
    }
    
    func testAppStoreAdamID() {
        XCTAssertFalse(BrainwalletAppStore.adamIDString.isEmpty)
        // Adam IDs are numeric strings
        XCTAssertNotNil(Int(BrainwalletAppStore.adamIDString))
    }
    
    func testAppStoreReviewLink() {
        let link = BrainwalletAppStore.reviewLink
        XCTAssertTrue(link.hasPrefix("https://"))
        XCTAssertTrue(link.contains(BrainwalletAppStore.adamIDString),
                      "Review link should contain the app's Adam ID")
    }
    
    func testExplorerURLsAreNonEmpty() {
        XCTAssertFalse(explorerURLs.isEmpty)
    }
    
    func testExplorerURLsAllUseHTTPS() {
        for url in explorerURLs {
            XCTAssertTrue(url.hasPrefix("https://"), "Explorer URL should use HTTPS: \(url)")
        }
    }
    
    func testExplorerURLsAreValidBaseURLs() {
        for urlString in explorerURLs {
            // Each URL is a base path — appending a txid should still parse
            let withTxID = urlString + "abc123"
            XCTAssertNotNil(URL(string: withTxID), "Should form valid URL: \(withTxID)")
        }
    }
    
    func testAPIServerBaseURL() {
        XCTAssertTrue(APIServer.baseUrl.hasPrefix("https://"))
        XCTAssertFalse(APIServer.baseUrl.isEmpty)
    }
    
    func testMoonpayWidgetURLs() {
        XCTAssertTrue(APIServer.mp_widget_debug_prefix.contains("sandbox"))
        XCTAssertTrue(APIServer.mp_widget_prod_prefix.hasPrefix("https://"))
        XCTAssertFalse(APIServer.mp_widget_prod_prefix.contains("sandbox"),
                       "Production MoonPay URL must not point to sandbox")
    }
    
    // MARK: - FalsePositiveRates
    
    func testFalsePositiveRatesAreAscending() {
        XCTAssertLessThan(FalsePositiveRates.lowPrivacy.rawValue,
                          FalsePositiveRates.semiPrivate.rawValue)
        XCTAssertLessThan(FalsePositiveRates.semiPrivate.rawValue,
                          FalsePositiveRates.anonymous.rawValue)
    }
    
    func testFalsePositiveRatesArePositive() {
        XCTAssertGreaterThan(FalsePositiveRates.lowPrivacy.rawValue, 0)
        XCTAssertGreaterThan(FalsePositiveRates.semiPrivate.rawValue, 0)
        XCTAssertGreaterThan(FalsePositiveRates.anonymous.rawValue, 0)
    }
    
    func testFalsePositiveRatesAreLessThanOne() {
        XCTAssertLessThan(FalsePositiveRates.lowPrivacy.rawValue, 1.0)
        XCTAssertLessThan(FalsePositiveRates.semiPrivate.rawValue, 1.0)
        XCTAssertLessThan(FalsePositiveRates.anonymous.rawValue, 1.0)
    }
    
    func testFalsePositiveRawValues() {
        XCTAssertEqual(FalsePositiveRates.lowPrivacy.rawValue, 0.00005, accuracy: 1e-9)
        XCTAssertEqual(FalsePositiveRates.semiPrivate.rawValue, 0.00008, accuracy: 1e-9)
        XCTAssertEqual(FalsePositiveRates.anonymous.rawValue, 0.0005, accuracy: 1e-9)
    }
    
    // MARK: - AppVersion
    
    func testAppVersionStringIsNonEmpty() {
        XCTAssertFalse(AppVersion.string.isEmpty)
    }
    
    func testAppVersionStringStartsWithV() {
        XCTAssertTrue(AppVersion.string.hasPrefix("v"),
                      "Version string should start with 'v', got: \(AppVersion.string)")
    }
    
    func testAppVersionNumberIsPresent() {
        XCTAssertNotNil(AppVersion.versionNumber)
    }
    
    func testAppBuildNumberIsPresent() {
        XCTAssertNotNil(AppVersion.buildNumber)
    }
    
    // MARK: - Pi
    
    func testPiConstant() {
        XCTAssertEqual(π, CGFloat.pi, accuracy: 0.000001)
    }
    
    func testCustomUserAgent() {
        XCTAssertEqual(customUserAgent, "brainwallet-ios")
        XCTAssertFalse(customUserAgent.isEmpty)
    }
}
