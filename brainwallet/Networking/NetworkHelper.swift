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
    
    
    init () {}
   
    func fetchDeviceLocaleCountry(completion: @escaping (String) -> Void) {
        let url = URL(string: "https://ipapi.co/country/")!
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
                       let jsonString = jsonData as? String,
                       jsonString.count == 2
                    {
                        completion(jsonString)
                    }
                }
            } else {
                let countryLocationError: [String: String] = ["error": error?.localizedDescription ?? ""]
                LWAnalytics.logEventWithParameters(itemName: ._20200112_ERR, properties: countryLocationError)
                completion("RU")
            }
        }
        task.resume()
        
    }
    
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
                       let jsonArray = jsonData as? [[String: Any]]
                    {
                        var dataArray: [MoonpayCountryData] = []

                        /// Filters allowed currencies and the top ranked currencies
                        for element in jsonArray {
                            if element["isBuyAllowed"] as? Bool == true &&
                                element["isAllowed"] as? Bool == true
                            {
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
}
