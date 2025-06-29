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
    var pickedCurrency: SupportedFiatCurrencies = .USD
    
    @Published
    var canUserBuyLTC: Bool = false
    
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
    
    let currencies: [SupportedFiatCurrencies] = SupportedFiatCurrencies.allCases
    
    init(store: Store, walletManager: WalletManager, canUserBuy: Bool) {
        self.store = store
        self.walletManager = walletManager
        self.canUserBuyLTC = canUserBuy
        
        updatePublishables()
        
        if canUserBuyLTC {
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
    
    @objc func updatePublishables() {
        
        //Fetch Preferred Fiat
        let globalCurrencyCode = UserDefaults.defaultCurrencyCode
        let defaultFiat = SupportedFiatCurrencies.USD
        self.pickedCurrency = SupportedFiatCurrencies.from(code: globalCurrencyCode) ?? defaultFiat
        
        //Fetch Fresh Address
        newReceiveAddress = self.walletManager.wallet?.receiveAddress ?? "----"
        generateQRCode()
    }
    
    func fetchBuyQuoteLimits(buyAmount: Int, baseCurrencyCode: SupportedFiatCurrencies = .USD) {
        self.didFetchData = true
          
        let _ = NetworkHelper.init().fetchBuyQuote(baseCurrencyAmount: buyAmount, baseCurrency: baseCurrencyCode, completion: { mpData in
           
                DispatchQueue.main.sync {
                    //quoted buy segments
                    self.fiatMinAmount = mpData.minBuyAmount
                    self.fiatTenXAmount = mpData.minBuyAmount * 10
                    self.fiatMaxAmount = mpData.maxBuyAmount
                    
                    //quoted qty
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
        
        let currentDevice: String = UIDevice.current.model
        let currentName: String = UIDevice.current.name
        let externalID: String = "Brainwallet-iOS-" + currentDevice.urlEscapedString + currentName.urlEscapedString

        let currentLocaleLanguage = Locale.current.language.languageCode?.identifier ?? "en"
        let userTheme = UserDefaults.userPreferredDarkTheme ? "dark" : "light"

        let moonpaySigningData = MoonpaySigningData(baseCurrencyCode: pickedCurrency.code,
                                                    baseCurrencyAmount: String(Double(pickedAmount)),
                                                    language: currentLocaleLanguage,
                                                    walletAddress: newReceiveAddress,
                                                    defaultCurrencyCode: "ltc",
                                                    externalTransactionId: externalID,
                                                    currencyCode: "ltc",
                                                    themeId: "main-v1.0.0",
                                                    theme: userTheme)
        return moonpaySigningData
    }
    
    func fetchMoonpaySignedUrl(signingData: MoonpaySigningData) {
        
        let _ = NetworkHelper.init().fetchSignedURL(moonPaySigningData: signingData, completion: {  signedString in
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
                           height: kQRImageSide))
        {
            newReceiveAddressQR = image
        }
    }
}
