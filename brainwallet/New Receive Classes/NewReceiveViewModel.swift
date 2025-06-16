//
//  NewReceiveViewModel.swift
//  brainwallet
//
//  Created by Kerry Washington on 28/05/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit

@MainActor
class NewReceiveViewModel: ObservableObject, Subscriber {
    // MARK: - Combine Variables

    @Published
    var newReceiveAddress = ""

    @Published
    var signedURLString = ""

    @Published
    var newReceiveAddressQR: UIImage?

    @Published
    var pickedAmount: Int = 210

    @Published
    var fiatMinAmount: Int = 20

    @Published
    var fiatTenXAmount: Int = 200

    @Published
    var fiatMaxAmount: Int = 20000

    @Published
    var quotedLTCAmount: Double = 0.0

    @Published
    var pickedCurrency: SupportedFiatCurrency = .USD

    @Published
    var canUserBuy: Bool = false

    @Published
    var quotedTimestamp = ""

    @Published
    var didFetchData: Bool = false

    @Published
    var didFetchURLString: Bool = false

    let ISO8601DateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "dd MMM yyyy HH:mm:ss"
        return formatter
    }()

    var store: Store
    var walletManager: WalletManager
    var ltcToFiatRate: Double = 0.0

    var dismissReceiveModal: (() -> Void)?

    let currencies: [SupportedFiatCurrency] = SupportedFiatCurrency.allCases

    init(store: Store, walletManager: WalletManager, canUserBuy: Bool) {
        self.store = store
        self.walletManager = walletManager
        self.canUserBuy = canUserBuy

        updatePublishables()

        if canUserBuy {
            // fetch buy quote
            fetchBuyQuoteLimits(buyAmount: pickedAmount, baseCurrencyCode: pickedCurrency)
        }

        NotificationCenter.default.addObserver(self,
                         selector: #selector(updatePublishables),
                         name: .preferredCurrencyChangedNotification,
                         object: nil)

    }

    deinit {
        NotificationCenter
            .default
            .removeObserver(self,
                            name: .preferredCurrencyChangedNotification,
                            object: nil)
    }

    func shouldDismissTheView() {
        dismissReceiveModal?()
    }

    @objc func updatePublishables() {

        // Fetch Preferred Fiat
        let globalCurrencyCode = UserDefaults.userPreferredCurrencyCode
        let defaultFiat = SupportedFiatCurrency.USD
        self.pickedCurrency = SupportedFiatCurrency.from(code: globalCurrencyCode) ?? defaultFiat

        // Fetch Fresh Address
        newReceiveAddress = self.walletManager.wallet?.receiveAddress ?? "----"
        generateQRCode()
    }

    func fetchBuyQuoteLimits(buyAmount: Int, baseCurrencyCode: SupportedFiatCurrency = .USD) {
        self.didFetchData = true

        NetworkHelper.init()
            .fetchBuyQuote(baseCurrencyAmount: buyAmount,
                           baseCurrency: baseCurrencyCode,
                           completion: { mpData in

                DispatchQueue.main.sync {
                    // quoted buy segments
                    self.fiatMinAmount = mpData.minBuyAmount
                    self.fiatTenXAmount = mpData.minBuyAmount * 10
                    self.fiatMaxAmount = mpData.maxBuyAmount

                    // quoted qty
                    self.quotedLTCAmount = mpData.quotedLTCAmount

                    // timestamp
                    let quoteTimestampString: String = mpData.quoteTimestamp
                    let quoteDate = self.ISO8601DateFormatter.date(from: quoteTimestampString) ?? Date()
                    self.quotedTimestamp = self.ISO8601DateFormatter.string(from: quoteDate).capitalized

                    // update state
                    self.didFetchData = false
                }
        })
    }

    func buildUnsignedMoonPayUrl() -> MoonpaySigningData {

        let deviceName: String = UIDevice.current.name
        let iOSMajor: String = ProcessInfo.processInfo.operatingSystemVersion.majorVersion.description
        let iOSMinor: String = ProcessInfo.processInfo.operatingSystemVersion.minorVersion.description
        let iOSVersion = iOSMajor + "." + iOSMinor
        let formattedExternalID = String(format: "brainwallet-ios,%@,%@-iOS%@",AppVersion.string,
                                         deviceName, iOSVersion)

        let obfuscatedExternalID: String = Utility().encryptMessageRSA2048(formattedExternalID)

        let currentLocaleLanguage = Locale.current.language.languageCode?.identifier ?? "en"
        let userTheme = UserDefaults.userPreferredDarkTheme ? "dark" : "light"

        let moonpaySigningData = MoonpaySigningData(baseCurrencyCode: pickedCurrency.code,
                                                    baseCurrencyAmount: String(Double(pickedAmount)),
                                                    language: currentLocaleLanguage,
                                                    walletAddress: newReceiveAddress,
                                                    userPreferredCurrencyCode: "ltc",
                                                    externalTransactionId: obfuscatedExternalID,
                                                    currencyCode: "ltc",
                                                    themeId: "main-v1.0.0",
                                                    theme: userTheme)
        return moonpaySigningData
    }

    func fetchMoonpaySignedUrl(signingData: MoonpaySigningData) {

        NetworkHelper
            .init()
            .fetchSignedURL(mpData: signingData, completion: {  signedString in
            DispatchQueue.main.async {
                self.signedURLString = signedString
                self.didFetchURLString = true
            }
         })
    }

    private func generateQRCode() {
        if let data = newReceiveAddress.data(using: .utf8),
           let image = UIImage
            .qrCode(data: data,
                    color: .black)?
            .resize(CGSize(width: kQRImageSide,
                           height: kQRImageSide)) {
            newReceiveAddressQR = image
        }
    }
}
