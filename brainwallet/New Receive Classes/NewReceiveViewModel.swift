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

    // Fetched once at init so buildUnsignedMoonPayUrl() (called synchronously
    // from several Views) can read it without becoming an async call itself.
    // Not private: unit tests assert on it directly and inject ipAddressFetcher.
    var cachedIPAddress: String = ""

    // Injectable so tests can substitute a spy instead of hitting the real network.
    var ipAddressFetcher: PublicIPAddressFetching = NetworkHelper()

    var dismissReceiveModal: (() -> Void)?

    let currencies: [SupportedFiatCurrency] = SupportedFiatCurrency.allCases

    init(store: Store, walletManager: WalletManager, canUserBuy: Bool, ipAddressFetcher: PublicIPAddressFetching = NetworkHelper()) {
        self.store = store
        self.walletManager = walletManager
        self.canUserBuy = canUserBuy
        self.ipAddressFetcher = ipAddressFetcher

        updatePublishables()

        if canUserBuy {
            // fetch buy quote
            fetchBuyQuoteLimits(buyAmount: pickedAmount, baseCurrencyCode: pickedCurrency)
        }

        ipAddressFetcher.fetchPublicIPAddress(completion: { [weak self] ipAddress in
            DispatchQueue.main.async {
                self?.cachedIPAddress = ipAddress
            }
        })

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
        let udid = UUID().uuidString
        let formattedExternalID = String(format: "brainwallet-ios,%@,%@-iOS%@,%@",
                                         AppVersion.string,
                                         deviceName,
                                         iOSVersion, udid)

        let obfuscatedExternalID: String = Utility().encryptMessageRSA2048(formattedExternalID)
        let currentLocaleLanguage = Bundle.main.preferredLocalizations.first ?? "en"
        let userTheme = UserDefaults.userPreferredDarkTheme ? "dark" : "light"

        let moonpaySigningData = MoonpaySigningData(baseCurrencyCode: pickedCurrency.code,
                                                    baseCurrencyAmount: String(Double(pickedAmount)),
                                                    language: currentLocaleLanguage,
                                                    walletAddress: newReceiveAddress,
                                                    ipAddress: cachedIPAddress,
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

    /// Guarantees cachedIPAddress is resolved before MoonpaySigningData is
    /// built and the sign-url request fires, instead of racing the init-time
    /// prefetch. Use this (rather than buildUnsignedMoonPayUrl() followed by
    /// fetchMoonpaySignedUrl()) wherever the app actually calls the MoonPay
    /// signing endpoint.
    func signAndFetchMoonPayUrl() {
        guard cachedIPAddress.isEmpty else {
            fetchMoonpaySignedUrl(signingData: buildUnsignedMoonPayUrl())
            return
        }

        ipAddressFetcher.fetchPublicIPAddress(completion: { [weak self] ipAddress in
            DispatchQueue.main.async {
                guard let self else { return }
                self.cachedIPAddress = ipAddress
                self.fetchMoonpaySignedUrl(signingData: self.buildUnsignedMoonPayUrl())
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
