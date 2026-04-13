// CurrencyTests.swift
// brainwalletTests
//
// Unit tests for Currency.swift (release/v3.9.2)
// Tests cover: Currency class, GlobalCurrency enum cases, properties,
// lookup, uniqueness invariants, and exhaustive data-integrity checks.

import XCTest
@testable import brainwallet

// MARK: - Currency Class Tests

final class CurrencyClassTests: XCTestCase {

    // MARK: Known valid codes

    func testGetSymbolForCurrencyCode_USD_returnsSymbol() {
        let symbol = Currency.getSymbolForCurrencyCode(code: "USD")
        XCTAssertNotNil(symbol, "USD should return a currency symbol")
    }

    func testGetSymbolForCurrencyCode_EUR_returnsSymbol() {
        let symbol = Currency.getSymbolForCurrencyCode(code: "EUR")
        XCTAssertNotNil(symbol, "EUR should return a currency symbol")
    }

    func testGetSymbolForCurrencyCode_GBP_returnsSymbol() {
        let symbol = Currency.getSymbolForCurrencyCode(code: "GBP")
        XCTAssertNotNil(symbol, "GBP should return a currency symbol")
    }

    func testGetSymbolForCurrencyCode_JPY_returnsSymbol() {
        let symbol = Currency.getSymbolForCurrencyCode(code: "JPY")
        XCTAssertNotNil(symbol, "JPY should return a currency symbol")
    }

    func testGetSymbolForCurrencyCode_CAD_returnsSymbol() {
        let symbol = Currency.getSymbolForCurrencyCode(code: "CAD")
        XCTAssertNotNil(symbol, "CAD should return a currency symbol")
    }

    // MARK: Invalid / edge-case codes

    func testGetSymbolForCurrencyCode_invalidCode_returnsNil() {
        let symbol = Currency.getSymbolForCurrencyCode(code: "XYZ")
        XCTAssertNil(symbol, "An unknown currency code should return nil")
    }

    func testGetSymbolForCurrencyCode_emptyString_returnsNil() {
        let symbol = Currency.getSymbolForCurrencyCode(code: "")
        XCTAssertNil(symbol, "An empty string should return nil")
    }

    func testGetSymbolForCurrencyCode_lowercaseCode_returnsNil() {
        // Locale currency identifiers are uppercase; lowercase should not match.
        let symbol = Currency.getSymbolForCurrencyCode(code: "usd")
        XCTAssertNil(symbol, "Lowercase currency code should return nil")
    }

    func testGetSymbolForCurrencyCode_numericString_returnsNil() {
        let symbol = Currency.getSymbolForCurrencyCode(code: "123")
        XCTAssertNil(symbol, "A numeric string should return nil")
    }

    func testGetSymbolForCurrencyCode_returnsString_whenFound() {
        // If a valid code is found the returned symbol must be non-empty.
        if let symbol = Currency.getSymbolForCurrencyCode(code: "USD") {
            XCTAssertFalse(symbol.isEmpty, "Returned symbol must not be an empty string")
        }
    }
}

// MARK: - GlobalCurrency Enum: Case Count & Raw Values

final class GlobalCurrencyEnumStructureTests: XCTestCase {

    func testAllCasesCount_is160() {
        // The enum contains 160 cases as defined in v3.9.2.
        XCTAssertEqual(GlobalCurrency.allCases.count, 160)
    }

    func testUSD_rawValue_isZero() {
        XCTAssertEqual(GlobalCurrency.USD.rawValue, 0)
    }

    func testEUR_rawValue_isOne() {
        XCTAssertEqual(GlobalCurrency.EUR.rawValue, 1)
    }

    func testRawValues_areContiguous() {
        // Raw values must run 0 ..< count with no gaps.
        let values = GlobalCurrency.allCases.map(\.rawValue).sorted()
        for (index, value) in values.enumerated() {
            XCTAssertEqual(value, index, "Raw value gap detected at index \(index)")
        }
    }
}

// MARK: - GlobalCurrency: Identifiable

final class GlobalCurrencyIdentifiableTests: XCTestCase {

    func testId_returnsSelf() {
        XCTAssertEqual(GlobalCurrency.USD.code, "USD")
        XCTAssertEqual(GlobalCurrency.EUR.code, "EUR")
        XCTAssertEqual(GlobalCurrency.LTC.code, "LTC")
    }

    func testAllCases_idEqualsSelf() {
        for currency in GlobalCurrency.allCases {
            XCTAssertEqual(currency.code, currency.id, "\(currency) id should equal self")
        }
    }
}

// MARK: - GlobalCurrency: Equatable

final class GlobalCurrencyEquatableTests: XCTestCase {

    func testSameCase_isEqual() {
        XCTAssertEqual(GlobalCurrency.USD, GlobalCurrency.USD)
        XCTAssertEqual(GlobalCurrency.GBP, GlobalCurrency.GBP)
    }

    func testDifferentCases_areNotEqual() {
        XCTAssertNotEqual(GlobalCurrency.USD, GlobalCurrency.EUR)
        XCTAssertNotEqual(GlobalCurrency.LTC, GlobalCurrency.BTC)
    }
}

// MARK: - GlobalCurrency.from(code:)

final class GlobalCurrencyFromCodeTests: XCTestCase {

    // MARK: Valid lookups – spot-check representative currencies

    func testFrom_USD_returnsUSD() {
        XCTAssertEqual(GlobalCurrency.from(code: "USD"), .USD)
    }

    func testFrom_EUR_returnsEUR() {
        XCTAssertEqual(GlobalCurrency.from(code: "EUR"), .EUR)
    }

    func testFrom_GBP_returnsGBP() {
        XCTAssertEqual(GlobalCurrency.from(code: "GBP"), .GBP)
    }

    func testFrom_LTC_returnsLTC() {
        XCTAssertEqual(GlobalCurrency.from(code: "LTC"), .LTC)
    }

    func testFrom_BTC_returnsBTC() {
        XCTAssertEqual(GlobalCurrency.from(code: "BTC"), .BTC)
    }

    func testFrom_ETH_returnsETH() {
        XCTAssertEqual(GlobalCurrency.from(code: "ETH"), .ETH)
    }

    func testFrom_JPY_returnsJPY() {
        XCTAssertEqual(GlobalCurrency.from(code: "JPY"), .JPY)
    }

    func testFrom_ZMW_returnsZMW() {
        XCTAssertEqual(GlobalCurrency.from(code: "ZMW"), .ZMW)
    }

    // MARK: Invalid lookups

    func testFrom_invalidCode_returnsNil() {
        XCTAssertNil(GlobalCurrency.from(code: "XXX"))
    }

    func testFrom_emptyString_returnsNil() {
        XCTAssertNil(GlobalCurrency.from(code: ""))
    }

    func testFrom_lowercaseCode_returnsNil() {
        XCTAssertNil(GlobalCurrency.from(code: "usd"),
                     "Lookup must be case-sensitive; lowercase should not match")
    }

    func testFrom_mixedCase_returnsNil() {
        XCTAssertNil(GlobalCurrency.from(code: "Usd"))
    }

    func testFrom_partialCode_returnsNil() {
        XCTAssertNil(GlobalCurrency.from(code: "US"))
    }

    // MARK: Round-trip invariant

    func testFrom_roundTrip_allCases() {
        // from(code:) must recover every case via its own .code property.
        for currency in GlobalCurrency.allCases {
            let recovered = GlobalCurrency.from(code: currency.code)
            XCTAssertEqual(recovered, currency,
                           "Round-trip failed for \(currency.code)")
        }
    }
}

// MARK: - GlobalCurrency.code

final class GlobalCurrencyCodeTests: XCTestCase {

    // MARK: Spot-checks

    func testCode_USD() { XCTAssertEqual(GlobalCurrency.USD.code, "USD") }
    func testCode_EUR() { XCTAssertEqual(GlobalCurrency.EUR.code, "EUR") }
    func testCode_GBP() { XCTAssertEqual(GlobalCurrency.GBP.code, "GBP") }
    func testCode_AED() { XCTAssertEqual(GlobalCurrency.AED.code, "AED") }
    func testCode_LTC() { XCTAssertEqual(GlobalCurrency.LTC.code, "LTC") }
    func testCode_BTC() { XCTAssertEqual(GlobalCurrency.BTC.code, "BTC") }
    func testCode_ETH() { XCTAssertEqual(GlobalCurrency.ETH.code, "ETH") }
    func testCode_ZMW() { XCTAssertEqual(GlobalCurrency.ZMW.code, "ZMW") }
    func testCode_ZMK() { XCTAssertEqual(GlobalCurrency.ZMK.code, "ZMK") }
    func testCode_XOF() { XCTAssertEqual(GlobalCurrency.XOF.code, "XOF") }
    func testCode_XPF() { XCTAssertEqual(GlobalCurrency.XPF.code, "XPF") }

    // MARK: Invariants across all cases

    func testCode_allCases_isNonEmpty() {
        for currency in GlobalCurrency.allCases {
            XCTAssertFalse(currency.code.isEmpty,
                           "\(currency) should have a non-empty code")
        }
    }

    func testCode_allCases_isThreeOrFourCharacters() {
        // All ISO 4217 codes are 3 chars; crypto codes in this enum are also 3 chars.
        for currency in GlobalCurrency.allCases {
            let length = currency.code.count
            XCTAssertTrue(length == 3 || length == 4,
                          "\(currency.code) has unexpected length \(length)")
        }
    }

    func testCode_allCases_isUppercase() {
        for currency in GlobalCurrency.allCases {
            XCTAssertEqual(currency.code, currency.code.uppercased(),
                           "\(currency.code) should be uppercase")
        }
    }

    func testCode_allCases_areUnique() {
        let codes = GlobalCurrency.allCases.map(\.code)
        let unique = Set(codes)
        XCTAssertEqual(codes.count, unique.count,
                       "Every case must have a unique code")
    }
}

// MARK: - GlobalCurrency.symbol

final class GlobalCurrencySymbolTests: XCTestCase {

    // MARK: Spot-checks for well-known symbols

    func testSymbol_USD_isDollar() { XCTAssertEqual(GlobalCurrency.USD.symbol, "$") }
    func testSymbol_EUR_isEuro()   { XCTAssertEqual(GlobalCurrency.EUR.symbol, "€") }
    func testSymbol_GBP_isPound()  { XCTAssertEqual(GlobalCurrency.GBP.symbol, "£") }
    func testSymbol_JPY_isYen()    { XCTAssertEqual(GlobalCurrency.JPY.symbol, "¥") }
    func testSymbol_CNY_isYen()    { XCTAssertEqual(GlobalCurrency.CNY.symbol, "¥") }
    func testSymbol_INR_isRupee()  { XCTAssertEqual(GlobalCurrency.INR.symbol, "₹") }
    func testSymbol_BTC_isBitcoin(){ XCTAssertEqual(GlobalCurrency.BTC.symbol, "₿") }
    func testSymbol_LTC_isLitecoin(){ XCTAssertEqual(GlobalCurrency.LTC.symbol, "Ł") }
    func testSymbol_ETH_isEthereum(){ XCTAssertEqual(GlobalCurrency.ETH.symbol, "Ξ") }
    func testSymbol_ETC_isEthereum(){ XCTAssertEqual(GlobalCurrency.ETC.symbol, "Ξ") }
    func testSymbol_KRW_isWon()    { XCTAssertEqual(GlobalCurrency.KRW.symbol, "₩") }
    func testSymbol_RUB_isRuble()  { XCTAssertEqual(GlobalCurrency.RUB.symbol, "₽") }
    func testSymbol_TRY_isLira()   { XCTAssertEqual(GlobalCurrency.TRY.symbol, "₺") }
    func testSymbol_NGN_isNaira()  { XCTAssertEqual(GlobalCurrency.NGN.symbol, "₦") }
    func testSymbol_CHF_isCHF()    { XCTAssertEqual(GlobalCurrency.CHF.symbol, "CHF") }
    func testSymbol_AUD_isAUD()    { XCTAssertEqual(GlobalCurrency.AUD.symbol, "A$") }
    func testSymbol_CAD_isCAD()    { XCTAssertEqual(GlobalCurrency.CAD.symbol, "C$") }
    func testSymbol_HKD_isHKD()    { XCTAssertEqual(GlobalCurrency.HKD.symbol, "HK$") }
    func testSymbol_NZD_isNZD()    { XCTAssertEqual(GlobalCurrency.NZD.symbol, "NZ$") }
    func testSymbol_SGD_isSGD()    { XCTAssertEqual(GlobalCurrency.SGD.symbol, "S$") }
    func testSymbol_ZAR_isRand()   { XCTAssertEqual(GlobalCurrency.ZAR.symbol, "R") }
    func testSymbol_ZMK_isZK()     { XCTAssertEqual(GlobalCurrency.ZMK.symbol, "ZK") }
    func testSymbol_ZMW_isZK()     { XCTAssertEqual(GlobalCurrency.ZMW.symbol, "ZK") }

    // MARK: Invariants

    func testSymbol_allCases_isNonEmpty() {
        for currency in GlobalCurrency.allCases {
            XCTAssertFalse(currency.symbol.isEmpty,
                           "\(currency.code) must have a non-empty symbol")
        }
    }
}

// MARK: - GlobalCurrency.fullCurrencyName

final class GlobalCurrencyFullNameTests: XCTestCase {

    // MARK: Spot-checks

    func testFullName_USD() { XCTAssertEqual(GlobalCurrency.USD.fullCurrencyName, "US Dollar") }
    func testFullName_EUR() { XCTAssertEqual(GlobalCurrency.EUR.fullCurrencyName, "Euro") }
    func testFullName_GBP() { XCTAssertEqual(GlobalCurrency.GBP.fullCurrencyName, "British Pound Sterling") }
    func testFullName_LTC() { XCTAssertEqual(GlobalCurrency.LTC.fullCurrencyName, "Litecoin") }
    func testFullName_BTC() { XCTAssertEqual(GlobalCurrency.BTC.fullCurrencyName, "Bitcoin") }
    func testFullName_ETH() { XCTAssertEqual(GlobalCurrency.ETH.fullCurrencyName, "Ethereum") }
    func testFullName_ETC() { XCTAssertEqual(GlobalCurrency.ETC.fullCurrencyName, "Ethereum Classic") }
    func testFullName_BCH() { XCTAssertEqual(GlobalCurrency.BCH.fullCurrencyName, "Bitcoin Cash") }
    func testFullName_JPY() { XCTAssertEqual(GlobalCurrency.JPY.fullCurrencyName, "Japanese Yen") }
    func testFullName_ZMK() { XCTAssertEqual(GlobalCurrency.ZMK.fullCurrencyName, "Zambian Kwacha (old)") }
    func testFullName_ZMW() { XCTAssertEqual(GlobalCurrency.ZMW.fullCurrencyName, "Zambian Kwacha") }
    func testFullName_XAF() { XCTAssertEqual(GlobalCurrency.XAF.fullCurrencyName, "CFA Franc BEAC") }
    func testFullName_XOF() { XCTAssertEqual(GlobalCurrency.XOF.fullCurrencyName, "CFA Franc BCEAO") }
    func testFullName_XPF() { XCTAssertEqual(GlobalCurrency.XPF.fullCurrencyName, "CFP Franc") }

    // MARK: Invariants

    func testFullName_allCases_isNonEmpty() {
        for currency in GlobalCurrency.allCases {
            XCTAssertFalse(currency.fullCurrencyName.isEmpty,
                           "\(currency.code) must have a non-empty fullCurrencyName")
        }
    }

    func testFullName_allCases_areUnique() {
        let names = GlobalCurrency.allCases.map(\.fullCurrencyName)
        let unique = Set(names)
        XCTAssertEqual(names.count, unique.count,
                       "Every case must have a unique fullCurrencyName")
    }
}

// MARK: - GlobalCurrency.countryFlag

final class GlobalCurrencyFlagTests: XCTestCase {

    // MARK: Spot-checks for country flag emoji

    func testFlag_USD_isUSFlag()  { XCTAssertEqual(GlobalCurrency.USD.countryFlag, "🇺🇸") }
    func testFlag_EUR_isEUFlag()  { XCTAssertEqual(GlobalCurrency.EUR.countryFlag, "🇪🇺") }
    func testFlag_GBP_isGBFlag()  { XCTAssertEqual(GlobalCurrency.GBP.countryFlag, "🇬🇧") }
    func testFlag_JPY_isJPFlag()  { XCTAssertEqual(GlobalCurrency.JPY.countryFlag, "🇯🇵") }
    func testFlag_AUD_isAUFlag()  { XCTAssertEqual(GlobalCurrency.AUD.countryFlag, "🇦🇺") }
    func testFlag_CAD_isCAFlag()  { XCTAssertEqual(GlobalCurrency.CAD.countryFlag, "🇨🇦") }
    func testFlag_ZAR_isZAFlag()  { XCTAssertEqual(GlobalCurrency.ZAR.countryFlag, "🇿🇦") }
    func testFlag_ZMK_isZMFlag()  { XCTAssertEqual(GlobalCurrency.ZMK.countryFlag, "🇿🇲") }
    func testFlag_ZMW_isZMFlag()  { XCTAssertEqual(GlobalCurrency.ZMW.countryFlag, "🇿🇲") }
    func testFlag_XCD_isAGFlag()  { XCTAssertEqual(GlobalCurrency.XCD.countryFlag, "🇦🇬") }
    func testFlag_XAF_isCMFlag()  { XCTAssertEqual(GlobalCurrency.XAF.countryFlag, "🇨🇲") }
    func testFlag_XOF_isSNFlag()  { XCTAssertEqual(GlobalCurrency.XOF.countryFlag, "🇸🇳") }
    func testFlag_XPF_isPFFlag()  { XCTAssertEqual(GlobalCurrency.XPF.countryFlag, "🇵🇫") }

    // Crypto cases use a symbol character, not a flag emoji.
    func testFlag_BTC_isBitcoinSymbol() { XCTAssertEqual(GlobalCurrency.BTC.countryFlag, "₿") }
    func testFlag_BCH_isBitcoinSymbol() { XCTAssertEqual(GlobalCurrency.BCH.countryFlag, "₿") }
    func testFlag_LTC_isLitecoinSymbol(){ XCTAssertEqual(GlobalCurrency.LTC.countryFlag, "Ł") }
    func testFlag_ETH_isEthereumSymbol(){ XCTAssertEqual(GlobalCurrency.ETH.countryFlag, "Ξ") }
    func testFlag_ETC_isEthereumSymbol(){ XCTAssertEqual(GlobalCurrency.ETC.countryFlag, "Ξ") }

    // MARK: Invariants

    func testFlag_allCases_isNonEmpty() {
        for currency in GlobalCurrency.allCases {
            XCTAssertFalse(currency.countryFlag.isEmpty,
                           "\(currency.code) must have a non-empty countryFlag")
        }
    }
}

// MARK: - GlobalCurrency: Cross-property Integrity

final class GlobalCurrencyIntegrityTests: XCTestCase {

    /// Every property on every case must be populated — no accidental empty strings.
    func testAllCases_allProperties_nonEmpty() {
        for currency in GlobalCurrency.allCases {
            XCTAssertFalse(currency.code.isEmpty,             "\(currency): code is empty")
            XCTAssertFalse(currency.symbol.isEmpty,           "\(currency): symbol is empty")
            XCTAssertFalse(currency.fullCurrencyName.isEmpty, "\(currency): fullCurrencyName is empty")
            XCTAssertFalse(currency.countryFlag.isEmpty,      "\(currency): countryFlag is empty")
        }
    }

    /// Codes must be unique — duplicate codes would break `from(code:)` determinism.
    func testAllCases_codes_areUnique() {
        let codes = GlobalCurrency.allCases.map(\.code)
        XCTAssertEqual(codes.count, Set(codes).count,
                       "Duplicate codes found: \(findDuplicates(in: codes))")
    }

    /// Full names must be unique to avoid display ambiguity.
    func testAllCases_fullCurrencyNames_areUnique() {
        let names = GlobalCurrency.allCases.map(\.fullCurrencyName)
        XCTAssertEqual(names.count, Set(names).count,
                       "Duplicate fullCurrencyNames found: \(findDuplicates(in: names))")
    }

    /// Raw values must be unique (guaranteed by the enum, but worth asserting explicitly).
    func testAllCases_rawValues_areUnique() {
        let rawValues = GlobalCurrency.allCases.map(\.rawValue)
        XCTAssertEqual(rawValues.count, Set(rawValues).count,
                       "Duplicate raw values detected")
    }

    // MARK: - Helpers

    private func findDuplicates(in array: [String]) -> [String] {
        var seen = Set<String>()
        return array.filter { !seen.insert($0).inserted }
    }
}

// MARK: - GlobalCurrency: Known Fiat Currency Membership

final class GlobalCurrencyMembershipTests: XCTestCase {

    private let expectedFiatCodes: Set<String> = [
        "USD", "EUR", "GBP", "JPY", "AUD", "CAD", "CHF", "CNY",
        "HKD", "SGD", "NZD", "SEK", "NOK", "DKK", "MXN", "ZAR",
        "INR", "BRL", "RUB", "KRW", "TRY", "IDR", "SAR", "AED",
        "MYR", "THB", "TWD", "PLN", "HUF", "CZK", "ILS", "CLP",
        "ARS", "PHP", "EGP", "NGN", "PKR", "VND", "BDT", "UAH",
        "KZT", "QAR", "KWD", "IRR", "IQD", "LBP", "ZMW", "ZMK"
    ]

    func testAllExpectedFiatCodes_arePresentInEnum() {
        let allCodes = Set(GlobalCurrency.allCases.map(\.code))
        for fiat in expectedFiatCodes {
            XCTAssertTrue(allCodes.contains(fiat), "\(fiat) is missing from GlobalCurrency")
        }
    }

    func testCryptoAssets_arePresentInEnum() {
        let expectedCrypto = ["BTC", "ETH", "LTC", "BCH", "ETC"]
        let allCodes = Set(GlobalCurrency.allCases.map(\.code))
        for crypto in expectedCrypto {
            XCTAssertTrue(allCodes.contains(crypto), "\(crypto) is missing from GlobalCurrency")
        }
    }
}

// MARK: - GlobalCurrency: Litecoin as Base Currency

final class GlobalCurrencyLitecoinTests: XCTestCase {

    /// LTC is the base currency of Brainwallet; it must always be present.
    func testLTC_isPresent() {
        XCTAssertNotNil(GlobalCurrency.from(code: "LTC"))
    }

    func testLTC_symbol_isLitecoinSymbol() {
        XCTAssertEqual(GlobalCurrency.LTC.symbol, "Ł")
    }

    func testLTC_fullName_isLitecoin() {
        XCTAssertEqual(GlobalCurrency.LTC.fullCurrencyName, "Litecoin")
    }

    func testLTC_code_isLTC() {
        XCTAssertEqual(GlobalCurrency.LTC.code, "LTC")
    }

    func testLTC_flag_isLitecoinGlyph() {
        XCTAssertEqual(GlobalCurrency.LTC.countryFlag, "Ł")
    }
}

// MARK: - GlobalCurrency: CaseIterable ordering

final class GlobalCurrencyCaseIterableTests: XCTestCase {

    func testFirstCase_isUSD() {
        XCTAssertEqual(GlobalCurrency.allCases.first, .USD,
                       "USD (rawValue 0) must be the first case")
    }

    func testLastCase_isZMW() {
        XCTAssertEqual(GlobalCurrency.allCases.last, .ZMW,
                       "ZMW must be the last case")
    }

    func testAllCases_sortedByRawValue_matchesAllCasesOrder() {
        let byAllCases   = GlobalCurrency.allCases
        let byRawValue   = GlobalCurrency.allCases.sorted { $0.rawValue < $1.rawValue }
        XCTAssertEqual(byAllCases, byRawValue,
                       "allCases must be ordered by ascending raw value")
    }
}
