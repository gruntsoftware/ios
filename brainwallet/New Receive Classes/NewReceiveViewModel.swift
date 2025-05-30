//
//  NewReceiveViewModel.swift
//  brainwallet
//
//  Created by Kerry Washington on 28/05/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

import Foundation
import SwiftUI


@MainActor
class NewReceiveViewModel: ObservableObject, Subscriber {
    // MARK: - Combine Variables
    
    @Published
    var newReceiveAddress = ""
    
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
    var currentFiat: SupportedFiatCurrencies = .USD
    
    @Published
    var canUserBuyLTC: Bool = false
    
    @Published
    var quotedTimestamp = ""
    
    @Published
    var didFetchData: Bool = false

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
        
        let userPreferredCodeString: String = UserDefaults.userPreferredCurrency
        let fallbackFiat = SupportedFiatCurrencies.USD
        self.currentFiat = SupportedFiatCurrencies.from(code: userPreferredCodeString) ?? fallbackFiat
          
        //Fetch Fresh Address
        newReceiveAddress = self.walletManager.wallet?.receiveAddress ?? "----"
        generateQRCode()
        
        if canUserBuyLTC {
            // fetch buy quote
            fetchBuyQuoteLimits(buyAmount: pickedAmount, baseCurrencyCode: currentFiat)
        }
    }
    
    func fetchBuyQuoteLimits(buyAmount: Int, baseCurrencyCode: SupportedFiatCurrencies = .USD) {
        self.didFetchData = true
          
        let _ = NetworkHelper.init().fetchBuyQuote(baseCurrencyAmount: buyAmount, baseCurrency: baseCurrencyCode, completion: { mpData in
           
                DispatchQueue.main.sync {
                    //quoted buy segments
                    self.fiatMinAmount = mpData.minBuyAmount
                    self.fiatTenXAmount = mpData.minBuyAmount * 10
                    self.fiatMaxAmount = mpData.maxBuyAmount
                    
                    print("::::\(baseCurrencyCode.code) self.fiatMinAmount ::::\(self.fiatMinAmount)")
                    print(":::: self.fiatTenXAmount ::::\(self.fiatTenXAmount)")
                    print(":::: self.fiatMaxAmount ::::\(self.fiatMaxAmount)\n\n")
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
    
    func fetchMoonpaySignedUrl() {
        
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

//override suspend fun fetchMoonpaySignedUrl(params: Map<String, String>): String {
//    return remoteApiSource.getMoonpaySignedUrl(params)
//        .signedUrl.toUri()
//        .buildUpon()
//        .apply {
//            if (BuildConfig.DEBUG) {
//                authority("buy-sandbox.moonpay.com")//replace base url from buy.moonpay.com
//            }
//        }
//        .build()
//        .toString()
//}

