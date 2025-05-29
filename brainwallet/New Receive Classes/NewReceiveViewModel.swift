//
//  NewReceiveViewModel.swift
//  brainwallet
//
//  Created by Kerry Washington on 28/05/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

import Foundation
import SwiftUI

class NewReceiveViewModel: ObservableObject, Subscriber {
    // MARK: - Combine Variables
    
    @Published
    var newReceiveAddress = ""
    
    @Published
    var newReceiveAddressQR: UIImage?
    
    @Published
    var currentFiatCode = "USD"
    
    @Published
    var fiatAmounts: [Int] = [20,21,23]
     
    @Published
    var pickedAmount: Int = 0
    
    @Published
    var convertedLTC = 0.0
    
    @Published
    var fiatPerLTCRate: Double = 0.0
    
    @Published
    var currentFiat: CurrencySelection = .USD
    
    
    @Published
    var canUserBuyLTC: Bool = false
    
    @Published
    var fetchedTimestamp = "22 DEC 2025 1:00"
    
    var store: Store
    var walletManager: WalletManager
    
    let currencies: [CurrencySelection] = CurrencySelection.allCases


    init(store: Store, walletManager: WalletManager) {
        self.store = store
        self.walletManager = walletManager
        
        newReceiveAddress = self.walletManager.wallet?.receiveAddress ?? "----"

        setCurrencyAndRate(code: currentFiatCode)
       let canUserBuyLTC = UserDefaults.standard.object(forKey: userCurrentLocaleMPApprovedKey) as? Bool ?? false
        /// To show all more compex state (Buyt or Receive)
        #if targetEnvironment(simulator)
            generateQRCode()
            fetchRates()
            fetchLimits()
            fetchBuyQuote()
        #else
        if canUserBuyLTC {
            generateQRCode()
            fetchRates()
            fetchLimits()
            fetchBuyQuote()
        }
        #endif
    }
    
    
    func setCurrencyAndRate(code: String) {
        UserDefaults.defaultCurrencyCode = code
        UserDefaults.standard.synchronize()
        Bundle.setLanguage(code)
        
        currentFiatCode = code
        
        fetchRates()

        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .preferredCurrencyChangedNotification,
                                            object: nil,
                                            userInfo: nil)
        }
    }
    
    func fetchRates() {
        convertedLTC = store.state.currentRate?.rate ?? 0.0
        
    }
    
    func fetchLimits(baseCurrencyCode: String? = "USD") {
        
        
        
    }
    
    func fetchBuyQuote() {
        
    }
    
    func fetchMoonpaySignedUrl() {
        
    }
    
    func generateQRCode() {
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


//suspend fun fetchRates(): List<CurrencyEntity>
//
//    suspend fun fetchFeePerKb(): Fee
//
//    suspend fun fetchLimits(baseCurrencyCode: String): MoonpayCurrencyLimit
//
//    suspend fun fetchBuyQuote(params: Map<String, String>): GetMoonpayBuyQuoteResponse
//
//    suspend fun fetchMoonpaySignedUrl(params: Map<String, String>): String
//
//    class Impl(
//        private val context: Context,
//        private val remoteApiSource: RemoteApiSource,
//        private val currencyDataSource: CurrencyDataSource,
//        private val sharedPreferences: SharedPreferences,
//    ) : LtcRepository {
//        
//        //todo: make it offline first here later, currently just using CurrencyDataSource.getAllCurrencies
//        override suspend fun fetchRates(): List<CurrencyEntity> {
//            return runCatching {
//                val rates = remoteApiSource.getRates()
//                
//                //legacy logic
//                FeeManager.updateFeePerKb(context)
//                val selectedISO = BRSharedPrefs.getIsoSymbol(context)
//                rates.forEachIndexed { index, currencyEntity ->
//                    if (currencyEntity.code.equals(selectedISO, ignoreCase = true)) {
//                        BRSharedPrefs.putIso(context, currencyEntity.code)
//                        BRSharedPrefs.putCurrencyListPosition(context, index - 1)
//                    }
//                }
//                
//                //save to local
//                currencyDataSource.putCurrencies(rates)
//                return rates
//            }.getOrElse { currencyDataSource.getAllCurrencies(true) }
//            
//        }
//        
//        /**
//         * for now we just using [Fee.Default]
//         * will move to [RemoteApiSource.getFeePerKb] after fix the calculation when we do send
//         *
//         * maybe need updaete core if we need to use dynamic fee?
//         */
//        override suspend fun fetchFeePerKb(): Fee = Fee.Default //using static fee
//        
//        override suspend fun fetchLimits(baseCurrencyCode: String): MoonpayCurrencyLimit {
//            return sharedPreferences.fetchWithCache(
//                key = "${PREF_KEY_BUY_LIMITS_PREFIX}${baseCurrencyCode.lowercase()}",
//                cachedAtKey = "${PREF_KEY_BUY_LIMITS_PREFIX_CACHED_AT}${baseCurrencyCode.lowercase()}",
//                cacheTimeMs = 5 * 60 * 1000, //5 minutes
//                fetchData = {
//                    remoteApiSource.getMoonpayCurrencyLimit(baseCurrencyCode)
//                }
//            )
//        }
        
