//
//  MoonPayHelper.swift
//  brainwallet
//
//  Created by Kerry Washington on 29/05/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//
/// Moonpay: List supported countries endpoint
/// https://api.moonpay.com/v3/countries
/// - Parameter alphaCode2Char: String
/// - Parameter alphaCode3Char: String
/// - Parameter isBuyAllowed: Bool
/// - Parameter isSellAllowed: Bool
/// - Parameter countryName: String (name)
/// - Parameter isAllowedInCountry: Bool (isAllowed)
/// ===================================
/// Unused JSON parameters
/// "isNftAllowed": false
/// "isBalanceLedgerWithdrawAllowed": true,
/// "isSelfServeHighRisk": true,
/// "continent": "Asia",
/// "supportedDocuments": [
///    "passport",
///    "driving_licence",
///    "national_identity_card",
///    "residence_permit",
/// ],
/// "suggestedDocument": "national_identity_card"
/// - Returns: MoonpayCountryData
public struct MoonpayCountryData: Codable, Hashable {
    var alphaCode2Char: String
    var alphaCode3Char: String
    var isBuyAllowed: Bool
    var isSellAllowed: Bool
    var countryName: String
    var isAllowedInCountry: Bool
}

/// - Returns: MoonpayBuyLimits
public struct MoonpayBuyLimits: Codable, Hashable {
    var areFeesIncluded: Bool = true
    var fiatCode: String = "USD"
    var maxBuyAmount: Int = 0
    var minBuyAmount: Int = 0
    var paymentMethod: String = ""
    var quoteCurrency: String = ""
    var cryptoCode: String = "ltc"
    var cryptoMaxBuyAmount: Double = 0.0
    var cryptoMinBuyAmount: Double = 0.0
}

/// - Returns: MoonpayBuyQuote
public struct MoonpayBuyQuote: Codable, Hashable {
    var quoteTimestamp: String = ""
    var fiatCode: String = "USD"
    var maxBuyAmount: Int = 20000
    var minBuyAmount: Int = 20
    var fiatCodeIconUrl: String = ""
    var cryptoCode: String = "ltc"
    var fiatBuyAmount: Int = 200
    var quotedLTCAmount: Double = 0.0
}

/// - Returns: MoonpaySigningData
public struct MoonpaySigningData: Codable, Hashable {
    var baseCurrencyCode: String = ""
    var baseCurrencyAmount: String = ""
    var language: String = "en"
    var walletAddress: String = ""
    var defaultCurrencyCode: String = ""
    var externalTransactionId: String = "en"
    var currencyCode: String = ""
    var themeId: String = ""
    var theme: String = "en"
}


