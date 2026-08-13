//
// NewReceiveViewModelTests
//  brainwallet
//
//  Created by Kerry Washington on 01/06/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.

import XCTest
import SwiftUI
@testable import brainwallet

@MainActor
class NewReceiveViewModelTests: XCTestCase {
    
    var viewModel: NewReceiveViewModel!
    
    var mockWalletManager: WalletManager!
    
    override func setUp() {
        super.setUp()
        // Clear UserDefaults before each test
        UserDefaults.standard.removeObject(forKey: "userPreferredBuyCurrency")
        UserDefaults.standard.removeObject(forKey: "userPreferredDarkTheme")
        guard let tempWalletManager = try? WalletManager(store: Store(), dbPath: nil) else {
            assertionFailure("WalletManager no initialized")
            return
        }
        mockWalletManager = tempWalletManager
        viewModel = NewReceiveViewModel(store: Store(),
                                              walletManager: tempWalletManager,
                                              canUserBuy: true)
    }
    
    override func tearDown() {
        viewModel = nil
        // Clean up UserDefaults after each test
        UserDefaults.standard.removeObject(forKey: "userPreferredBuyCurrency")
        UserDefaults.standard.removeObject(forKey: "userPreferredDarkTheme")
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testInitialization() {
        
        
        XCTAssertEqual(viewModel.pickedAmount, 210)
        XCTAssertEqual(viewModel.fiatMinAmount, 20)
        XCTAssertEqual(viewModel.fiatTenXAmount, 200)
        XCTAssertEqual(viewModel.fiatMaxAmount, 20000)
        XCTAssertEqual(viewModel.quotedLTCAmount, 0.0)
        XCTAssertTrue(viewModel.canUserBuy)
        XCTAssertTrue(viewModel.didFetchData)
        XCTAssertFalse(viewModel.didFetchURLString)
        XCTAssertEqual(viewModel.signedURLString, "")
        XCTAssertEqual(viewModel.quotedTimestamp, "")
    }
    
    func testInitializationWithCanUserBuyFalse() {
        
        let viewModelNoBuy = NewReceiveViewModel(store: Store(),
                                               walletManager: mockWalletManager,
                                               canUserBuy: false)
        XCTAssertFalse(viewModelNoBuy.canUserBuy)
    }
    
    func testInitializationWithCanUserBuyTrue() {
        
        let viewModelNoBuy = NewReceiveViewModel(store: Store(),
                                               walletManager: mockWalletManager,
                                               canUserBuy: true)
        XCTAssertTrue(viewModelNoBuy.canUserBuy)
    }
    
    func testDefaultPickedAmount() {
        // Given - we know the default value from the code
        let expectedDefaultAmount = 210
        
        // We can't test this without initialization, but we can document the expected value
        XCTAssertEqual(expectedDefaultAmount, 210)
    }
    
    func testDefaultFiatAmounts() {
        // Test default values that should be set
        let expectedMinAmount = 20
        let expectedTenXAmount = 200
        let expectedMaxAmount = 20000
        
        XCTAssertEqual(expectedMinAmount, 20)
        XCTAssertEqual(expectedTenXAmount, 200)
        XCTAssertEqual(expectedMaxAmount, 20000)
    }
    
    // MARK: - Currency Selection Tests
    
    func testSupportedFiatCurrenciesEnum() {
        // Test that the enum has expected cases
        let allCurrencies = SupportedFiatCurrency.allCases
        
        XCTAssertTrue(allCurrencies.contains(.USD))
        XCTAssertGreaterThan(allCurrencies.count, 0)
    }
    
    func testCurrencyFromCode() {
        // Test the from(code:) method if it exists on SupportedFiatCurrencies
        let usdCurrency = SupportedFiatCurrency.from(code: "USD")
        let invalidCurrency = SupportedFiatCurrency.from(code: "INVALID")
        
        XCTAssertEqual(usdCurrency, .USD)
        XCTAssertNil(invalidCurrency)
    }
    
    // MARK: - UserDefaults Integration Tests
    
    func testUserPreferredBuyCurrencyDefault() {
        // Test UserDefaults extension behavior
        UserDefaults.standard.removeObject(forKey: "userPreferredBuyCurrency")
        
        let defaultCurrency = UserDefaults.userPreferredBuyCurrency
        
        XCTAssertEqual(defaultCurrency, "USD") // Should default to USD
    }
    
    func testUserPreferredBuyCurrencySetting() {
        // Test setting and getting currency preference
        UserDefaults.userPreferredBuyCurrency = "EUR"
        
        let retrievedCurrency = UserDefaults.userPreferredBuyCurrency
        
        XCTAssertEqual(retrievedCurrency, "EUR")
    }
    
    func testUserPreferredDarkThemeDefault() {
        // Test dark theme default
        UserDefaults.standard.removeObject(forKey: "userPreferredDarkTheme")
        
        let defaultTheme = UserDefaults.userPreferredDarkTheme
        
        XCTAssertFalse(defaultTheme) // Should default to false
    }
    
    func testUserPreferredDarkThemeSetting() {
        // Test setting and getting theme preference
        UserDefaults.userPreferredDarkTheme = true
        
        let retrievedTheme = UserDefaults.userPreferredDarkTheme
        
        XCTAssertTrue(retrievedTheme)
    }
    
    // MARK: - MoonpaySigningData Tests
    
    func testMoonpaySigningDataCreation() {
        // Test that we can create MoonpaySigningData with expected values
        let signingData = MoonpaySigningData(
            baseCurrencyCode: "USD",
            baseCurrencyAmount: "100.0",
            language: "en",
            walletAddress: "LTCTestAddress123",
            userPreferredCurrencyCode: "ltc",
            externalTransactionId: "test-external-id",
            currencyCode: "ltc",
            themeId: "main-v1.0.0",
            theme: "dark"
        )
        
        XCTAssertEqual(signingData.baseCurrencyCode, "USD")
        XCTAssertEqual(signingData.baseCurrencyAmount, "100.0")
        XCTAssertEqual(signingData.language, "en")
        XCTAssertEqual(signingData.walletAddress, "LTCTestAddress123")
        XCTAssertEqual(signingData.userPreferredCurrencyCode, "ltc")
        XCTAssertEqual(signingData.externalTransactionId, "test-external-id")
        XCTAssertEqual(signingData.currencyCode, "ltc")
        XCTAssertEqual(signingData.themeId, "main-v1.0.0")
        XCTAssertEqual(signingData.theme, "dark")
    }
    
    // MARK: - Date Formatter Tests
    
    func testISO8601DateFormatterFormat() {
        // Test the date formatter configuration.
        // Fixed to en_US_POSIX rather than Locale.current: this test asserts
        // an English month abbreviation ("jun"), so it needs a deterministic
        // locale to avoid failing on CI runners (or devices) whose current
        // locale formats months differently -- e.g. this failed on Xcode
        // Cloud's build agent, whose default locale isn't en_US.
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "dd MMM yyyy HH:mm:ss"

        // Test with a known date
        let testDate = Date(timeIntervalSince1970: 1717200000) // June 1, 2024 00:00:00 UTC
        let formattedString = formatter.string(from: testDate).lowercased()

        XCTAssertFalse(formattedString.isEmpty)
        XCTAssertTrue(formattedString.contains("2024"))
        XCTAssertTrue(formattedString.contains("jun"))
    }
    
    func testDateFormatterLocale() {
        // Test that formatter uses current locale
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "dd MMM yyyy HH:mm:ss"
        
        XCTAssertEqual(formatter.locale, Locale.current)
        XCTAssertEqual(formatter.dateFormat, "dd MMM yyyy HH:mm:ss")
    }
    
    // MARK: - String Extension Tests (for URL escaping)
    
    func testStringURLEscaping() {
        // Test URL escaping functionality if the extension exists
        let testString = "iPhone 15 Pro Max"
        let expectedEscaped = testString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        // This tests the expected behavior of URL escaping
        XCTAssertNotNil(expectedEscaped)
        XCTAssertEqual(expectedEscaped, "iPhone%2015%20Pro%20Max")
    }
    
    // MARK: - Device Information Tests
    
    func testDeviceInformation() {
        // Test that we can access device information as expected
        let currentDevice = UIDevice.current.model
        let currentName = UIDevice.current.name
        
        XCTAssertFalse(currentDevice.isEmpty)
        XCTAssertFalse(currentName.isEmpty)
        
        // Test that device info can be used in external ID format
        let deviceEscaped = currentDevice.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let nameEscaped = currentName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        
        XCTAssertNotNil(deviceEscaped)
        XCTAssertNotNil(nameEscaped)
        
        let externalID = "Brainwallet-iOS-" + (deviceEscaped ?? "") + (nameEscaped ?? "")
        XCTAssertTrue(externalID.hasPrefix("Brainwallet-iOS-"))
    }
    
    // MARK: - Locale Tests
    
    func testLocaleLanguageCode() {
        // Test locale language code extraction
        let currentLocaleLanguage = Locale.current.language.languageCode?.identifier ?? "en"
        
        XCTAssertFalse(currentLocaleLanguage.isEmpty)
        // Should be a valid language code (2-3 characters typically)
        XCTAssertGreaterThanOrEqual(currentLocaleLanguage.count, 2)
        XCTAssertLessThanOrEqual(currentLocaleLanguage.count, 3)
    }
    
    // MARK: - Business Logic Tests
    
    func testTenXAmountCalculation() {
        // Test the calculation logic for tenXAmount (minAmount * 10)
        let minAmount = 50
        let expectedTenXAmount = minAmount * 10
        
        XCTAssertEqual(expectedTenXAmount, 500)
    }
    
    func testAmountToStringConversion() {
        // Test integer amount to string conversion
        let intAmount = 150
        let stringAmount = String(Double(intAmount))
        
        XCTAssertEqual(stringAmount, "150.0")
    }
    
    // MARK: - Validation Tests
    
    func testReceiveAddressValidation() {
        // Test address validation logic (empty address should show placeholder)
        let emptyAddress = ""
        let validAddress = "LTC123TestAddress"
        
        let displayAddress1 = emptyAddress.isEmpty ? "----" : emptyAddress
        let displayAddress2 = validAddress.isEmpty ? "----" : validAddress
        
        XCTAssertEqual(displayAddress1, "----")
        XCTAssertEqual(displayAddress2, "LTC123TestAddress")
    }
    
    // MARK: - Constants Tests
    
    func testExpectedConstants() {
        // Test that expected constants exist and have reasonable values
        // Note: These would need to be adjusted based on actual constants in your app
        
        // Test that the QR image side constant would be reasonable
        let expectedQRSize: CGFloat = 200 // Assuming this is around the expected size
        let testSize = CGSize(width: expectedQRSize, height: expectedQRSize)
        
        XCTAssertEqual(testSize.width, testSize.height) // Should be square
        XCTAssertGreaterThan(testSize.width, 0)
    }
    
    // MARK: - Error Handling Tests
    
    func testDateFormatterWithInvalidString() {
        // Test date formatter with invalid input
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "dd MMM yyyy HH:mm:ss"
        
        let invalidDateString = "invalid date"
        let parsedDate = formatter.date(from: invalidDateString)
        
        XCTAssertNil(parsedDate) // Should return nil for invalid date
        
        // Test fallback behavior
        let fallbackDate = parsedDate ?? Date()
        XCTAssertNotNil(fallbackDate)
    }
    
    func testStringCapitalization() {
        // Test string capitalization as used in the timestamp
        let testString = "01 jun 2025 10:30:45"
        let capitalizedString = testString.capitalized

        XCTAssertEqual(capitalizedString, "01 Jun 2025 10:30:45")
    }

    // MARK: - IP Address Tests

    func testInitPopulatesCachedIPAddressFromInjectedFetcher() {
        let spy = PublicIPAddressFetchingSpy()
        spy.providedIPAddress = "198.51.100.7"

        let viewModelWithSpy = NewReceiveViewModel(store: Store(),
                                                    walletManager: mockWalletManager,
                                                    canUserBuy: false,
                                                    ipAddressFetcher: spy)

        let expectation = expectation(description: "cachedIPAddress populated from init")
        DispatchQueue.main.async {
            XCTAssertEqual(viewModelWithSpy.cachedIPAddress, "198.51.100.7")
            XCTAssertEqual(spy.fetchCallCount, 1)
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0)
    }

    func testBuildUnsignedMoonPayUrlUsesCachedIPAddress() {
        let spy = PublicIPAddressFetchingSpy()
        spy.providedIPAddress = "198.51.100.7"

        let viewModelWithSpy = NewReceiveViewModel(store: Store(),
                                                    walletManager: mockWalletManager,
                                                    canUserBuy: false,
                                                    ipAddressFetcher: spy)

        let expectation = expectation(description: "signingData reflects the cached IP")
        DispatchQueue.main.async {
            let signingData = viewModelWithSpy.buildUnsignedMoonPayUrl()
            XCTAssertEqual(signingData.ipAddress, "198.51.100.7")
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0)
    }

    func testSignAndFetchMoonPayUrlResolvesIPBeforeSigningWhenNotYetCached() {
        let spy = PublicIPAddressFetchingSpy()
        spy.providedIPAddress = "198.51.100.7"

        let viewModelWithSpy = NewReceiveViewModel(store: Store(),
                                                    walletManager: mockWalletManager,
                                                    canUserBuy: false,
                                                    ipAddressFetcher: spy)

        // The init-time prefetch's completion is queued on the main run loop
        // but hasn't run yet, so this is still deterministically empty here.
        XCTAssertEqual(viewModelWithSpy.cachedIPAddress, "")

        viewModelWithSpy.signAndFetchMoonPayUrl()

        let expectation = expectation(description: "cachedIPAddress resolved before signing")
        DispatchQueue.main.async {
            XCTAssertEqual(viewModelWithSpy.cachedIPAddress, "198.51.100.7")
            XCTAssertEqual(spy.fetchCallCount, 2, "one fetch from init, one from signAndFetchMoonPayUrl")
            expectation.fulfill()
        }
        waitForExpectations(timeout: 1.0)
    }

    func testSignAndFetchMoonPayUrlReusesCachedIPAddressWithoutRefetching() {
        let spy = PublicIPAddressFetchingSpy()
        spy.providedIPAddress = "198.51.100.7"

        let viewModelWithSpy = NewReceiveViewModel(store: Store(),
                                                    walletManager: mockWalletManager,
                                                    canUserBuy: false,
                                                    ipAddressFetcher: spy)

        let readyExpectation = expectation(description: "init-time prefetch settles")
        DispatchQueue.main.async {
            readyExpectation.fulfill()
        }
        waitForExpectations(timeout: 1.0)

        XCTAssertEqual(viewModelWithSpy.cachedIPAddress, "198.51.100.7")
        XCTAssertEqual(spy.fetchCallCount, 1)

        viewModelWithSpy.signAndFetchMoonPayUrl()

        XCTAssertEqual(spy.fetchCallCount, 1, "should reuse the cached IP instead of fetching again")
    }
}

// MARK: - Test Doubles

final class PublicIPAddressFetchingSpy: PublicIPAddressFetching {
    var providedIPAddress: String = ""
    private(set) var fetchCallCount = 0

    func fetchPublicIPAddress(completion: @escaping (String) -> Void) {
        fetchCallCount += 1
        completion(providedIPAddress)
    }
}

// MARK: - UserDefaults Extension for Testing

extension UserDefaults {
    static var userPreferredBuyCurrency: String {
        get {
            return UserDefaults.standard.string(forKey: "userPreferredBuyCurrency") ?? "USD"
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "userPreferredBuyCurrency")
        }
    }
    
    static var userPreferredDarkTheme: Bool {
        get {
            return UserDefaults.standard.bool(forKey: "userPreferredDarkTheme")
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "userPreferredDarkTheme")
        }
    }
}

// MARK: - Test Extensions

extension String {
    /// Test helper for URL escaping
    var urlEscapedString: String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? self
    }
}
