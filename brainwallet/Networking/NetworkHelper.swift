//
//  NetworkHelper.swift
//  brainwallet
//
//  Created by Kerry Washington on 28/05/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//
import SwiftUI
import Foundation
import Network

class NetworkHelper: ObservableObject {
    
    func fetchCurrenciesCountries(completion: @escaping ([MoonpayCountryData]) -> Void) {
        let url = URL(string: "https://api.moonpay.com/v3/countries")!
        var request = URLRequest(url: url)
        #if targetEnvironment(simulator)
            request.assumesHTTP3Capable = false
        #endif
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        request.allHTTPHeaderFields = ["accept": "application/json"]

        let task = URLSession(configuration: .ephemeral).dataTask(with: request) { data, _, error in

            if error == nil {
                DispatchQueue.main.sync {
                    if let jsonData = try? JSONSerialization.jsonObject(with: data ?? Data(), options: []),
                       let jsonArray = jsonData as? [[String: Any]] {
                        var dataArray: [MoonpayCountryData] = []

                        /// Filters allowed currencies and the top ranked currencies
                        for element in jsonArray {
                            if element["isBuyAllowed"] as? Bool == true &&
                                element["isAllowed"] as? Bool == true {
                                let alpha2 = element["alpha2"] as? String
                                let alpha3 = element["alpha3"] as? String
                                let name = element["name"] as? String
                                let isBuyAllowed = element["isBuyAllowed"] as? Bool
                                let isSellAllowed = element["isSellAllowed"] as? Bool
                                let isAllowed = element["isAllowed"] as? Bool

                                let mpCountryData = MoonpayCountryData(alphaCode2Char: alpha2 ?? "",
                                                                       alphaCode3Char: alpha3 ?? "",
                                                                       isBuyAllowed: isBuyAllowed ?? false,
                                                                       isSellAllowed: isSellAllowed ?? false,
                                                                       countryName: name ?? "",
                                                                       isAllowedInCountry: isAllowed ?? false)

                                dataArray.append(mpCountryData)
                            }
                        }
                        completion(dataArray)
                    }
                }
            } else {
                let currencyError: [String: String] = ["error": error?.localizedDescription ?? ""]
                LWAnalytics.logEventWithParameters(itemName: ._20200112_ERR, properties: currencyError)
                completion([])
            }
        }
        task.resume()
    }
    
    func fetchBuyQuote(baseCurrencyAmount: Int, baseCurrency: SupportedFiatCurrencies, completion: @escaping (MoonpayBuyQuote) -> Void) {
        let cryptoCurrencyCode: String = "ltc"// Default and only crypto atm
        let baseURL = APIServer.baseUrl
        let suffix = "v1/moonpay/buy-quote"
        let baseCode = baseCurrency.code.lowercased()
        let baseAmount = Double(baseCurrencyAmount)// User purchase amount
        let codeSuffix = "?currencyCode=\(cryptoCurrencyCode)&baseCurrencyCode=\(baseCode)&baseCurrencyAmount=\(baseAmount)"

        var request: URLRequest
        
        if let url = URL(string: baseURL + suffix + codeSuffix) {
            request = URLRequest(url: url)
        } else {
            fatalError("Invalid URL")
        }
        #if targetEnvironment(simulator)
            request.assumesHTTP3Capable = false
        #endif
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        request.allHTTPHeaderFields = ["accept": "application/json"]

        let task = URLSession(configuration: .ephemeral).dataTask(with: request) { data, _, error in

            if error == nil {
                var moonpayBuyQuoteObject = MoonpayBuyQuote()

                DispatchQueue.global(qos: .utility).async {

                    if let jsonData = try? JSONSerialization.jsonObject(with: data ?? Data(), options: []),
                       let jsonDict = jsonData as? [String: AnyObject],
                       let topElement = jsonDict["data"] as? [String: AnyObject] {
                        
                        let quoteCurrencyDict = topElement["quoteCurrency"] as? [String: AnyObject]
                        let baseCurrencyDict = topElement["baseCurrency"] as? [String: AnyObject]
                        
                        let quoteTimestamp = quoteCurrencyDict?["updatedAt"] as? String ?? Date().description
                        let fiatCode = baseCurrencyDict?["code"] as? String ?? ""
                        let maxBuyAmount = baseCurrencyDict?["maxBuyAmount"] as? Int ?? 0
                        let minBuyAmount = baseCurrencyDict?["minBuyAmount"] as? Int ?? 0
                        let fiatCodeIconUrl = baseCurrencyDict?["icon"] as? String ?? ""
                        let cryptoCode = quoteCurrencyDict?["code"] as? String ?? "ltc"
                        let fiatBuyAmount = topElement["baseCurrencyAmount"] as? Int ?? 0
                        let quotedLTCAmount = topElement["quoteCurrencyAmount"] as? Double ?? 0.0

                        moonpayBuyQuoteObject = MoonpayBuyQuote(quoteTimestamp: quoteTimestamp,
                                                          fiatCode: fiatCode,
                                                          maxBuyAmount: maxBuyAmount,
                                                          minBuyAmount: minBuyAmount,
                                                          fiatCodeIconUrl: fiatCodeIconUrl,
                                                          cryptoCode: cryptoCode,
                                                          fiatBuyAmount: fiatBuyAmount,
                                                          quotedLTCAmount: quotedLTCAmount)
                        completion(moonpayBuyQuoteObject)
                    } else {
                        completion(moonpayBuyQuoteObject)
                    }
                }
            } else {
                let fetchError: [String: String] = ["error": error?.localizedDescription ?? ""]
                LWAnalytics.logEventWithParameters(itemName: ._20200112_ERR, properties: fetchError)
            }
        }
        task.resume()
    }
    
    func fetchSignedURL(moonPaySigningData: MoonpaySigningData, completion: @escaping (String) -> Void) {
        let baseURL = APIServer.baseUrl
        let suffix = "v1/moonpay/sign-url"
        let baseCurrencyCode = moonPaySigningData.baseCurrencyCode
        let baseCurrencyAmount = moonPaySigningData.baseCurrencyAmount
        let language = moonPaySigningData.language
        let walletAddress = moonPaySigningData.walletAddress
        let defaultCurrencyCode = moonPaySigningData.defaultCurrencyCode
        let externalTransactionId = moonPaySigningData.externalTransactionId
        let currencyCode = moonPaySigningData.currencyCode
        let themeId = moonPaySigningData.themeId
        let theme = moonPaySigningData.theme
        
        var request: URLRequest
        
        let urlString = "\(baseURL)\(suffix)?baseCurrencyCode=\(baseCurrencyCode)&baseCurrencyAmount=\(baseCurrencyAmount)&language=\(language)&walletAddress=\(walletAddress)&defaultCurrencyCode=\(defaultCurrencyCode)&externalTransactionId=\(externalTransactionId)&currencyCode=\(currencyCode)&themeId=\(themeId)&theme=\(theme)"

        if let url = URL(string: urlString) {
            request = URLRequest(url: url)
        } else {
            fatalError("Invalid URL")
        }
        #if targetEnvironment(simulator)
            request.assumesHTTP3Capable = false
        #endif
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        request.allHTTPHeaderFields = ["accept": "application/json"]

        let task = URLSession(configuration: .ephemeral).dataTask(with: request) { data, _, error in

            if error == nil {
                var signedURLString = ""
                let fallbackURLString = "https://brainwallet.co/mobile-top-up.html"

                DispatchQueue.global(qos: .utility).async {

                    if let jsonData = try? JSONSerialization.jsonObject(with: data ?? Data(), options: []),
                       let signedUrlDict = jsonData as? [String: AnyObject],
                        let signedUrl = signedUrlDict["signedUrl"] {
                        signedURLString = signedUrl as? String ?? fallbackURLString
                        completion(signedURLString)
                    } else {
                        completion(fallbackURLString)
                        let fetchError: [String: String] = ["error": "signed_url_invalid"]
                        LWAnalytics.logEventWithParameters(itemName: ._20191105_AL, properties: fetchError)
                    }
                }
            } else {
                let fetchError: [String: String] = ["error": error?.localizedDescription ?? ""]
                LWAnalytics.logEventWithParameters(itemName: ._20200112_ERR, properties: fetchError)
            }
        }
        task.resume()
    }
    
    func fetchFiatLimits(code: String, completion: @escaping (MoonpayBuyLimits) -> Void) {
        let baseURL = APIServer.baseUrl
        let suffix = "v1/moonpay/ltc-to-fiat-limits"
        let codeSuffix = "?baseCurrencyCode=\(code)"

        var request: URLRequest
        
        if let url = URL(string: baseURL + suffix + codeSuffix) {
            request = URLRequest(url: url)
        } else {
            fatalError("Invalid URL")
        }
        #if targetEnvironment(simulator)
            request.assumesHTTP3Capable = false
        #endif
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        request.allHTTPHeaderFields = ["accept": "application/json"]

        let task = URLSession(configuration: .ephemeral).dataTask(with: request) { data, _, error in

            if error == nil {
                var moonpayBuyLimits = MoonpayBuyLimits()

                DispatchQueue.global(qos: .utility).async {

                    if let jsonData = try? JSONSerialization.jsonObject(with: data ?? Data(), options: []),
                       let jsonDict = jsonData as? [String: AnyObject],
                       let topElement = jsonDict["data"] as? [String: AnyObject] {
                        
                        let intToBool: Bool = (topElement["areFeesIncluded"] as? Int == 0) ? false : true
                        let areFeesIncluded = intToBool
                        let baseCurrency = topElement["baseCurrency"] as? [String: AnyObject]
                        let fiatCode = baseCurrency?["code"] as? String ?? ""
                        let maxBuyAmount = baseCurrency?["maxBuyAmount"] as? Int ?? 0
                        let minBuyAmount = baseCurrency?["minBuyAmount"] as? Int ?? 0
                        let paymentMethod = topElement["paymentMethod"] as? String ?? "--"
                        let quoteCurrency = topElement["quoteCurrency"]  as? [String: AnyObject]
                        let cryptoCode = quoteCurrency?["code"] as? String ?? "ltc"
                        let cryptoMaxBuyAmount = quoteCurrency?["maxBuyAmount"] as? Double ?? 0.0
                        let cryptoMinBuyAmount = quoteCurrency?["minBuyAmount"] as? Double ?? 0.0
                        
                        moonpayBuyLimits = MoonpayBuyLimits(areFeesIncluded: areFeesIncluded,
                                                     fiatCode: fiatCode,
                                                     maxBuyAmount: maxBuyAmount,
                                                     minBuyAmount: minBuyAmount,
                                                     paymentMethod: paymentMethod,
                                                     cryptoCode: cryptoCode,
                                                     cryptoMaxBuyAmount: cryptoMaxBuyAmount,
                                                     cryptoMinBuyAmount: cryptoMinBuyAmount)
                        completion(moonpayBuyLimits)
                    } else {
                        completion(moonpayBuyLimits)
                    }
                }
            } else {
                let fetchError: [String: String] = ["error": error?.localizedDescription ?? ""]
                LWAnalytics.logEventWithParameters(itemName: ._20200112_ERR, properties: fetchError)
            }
        }
        task.resume()
    }
}
