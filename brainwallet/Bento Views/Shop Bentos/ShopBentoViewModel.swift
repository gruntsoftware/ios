////
////  ShopBentoViewModel.swift
////  brainwallet
////
////  Created by Kerry Washington on 5/8/26.
////  Copyright © 2026 Grunt Software, LTD. All rights reserved.
////
//import Foundation
//import SwiftUI
//
//class ShopBentoViewModel: ObservableObject {
//    
//    // MARK: - Public Variables
//    
//    @Published
//    var widgetURL: URL = URL(string: BrainwalletShop.bitrefillCode)!
//    
//    init() {
//        fetchShopConfig()
//    }
//    
//    // MARK: - Models
//    
//    private struct ShopConfig: Decodable {
//        let shopData: [ShopItem]
//        
//        enum CodingKeys: String, CodingKey {
//            case shopData = "shop_data"
//        }
//    }
//    
//    private struct ShopItem: Decodable {
//        let widgetUrl: String
//        
//        enum CodingKeys: String, CodingKey {
//            case widgetUrl = "widget_url"
//        }
//    }
//    
//    func fetchShopConfig() {
//        let key = RemoteConfigKeys.PATH_SHOP_CONTENT.rawValue
//        let shopJson = RemoteConfigHelper().getString(key: key)
//        
//        guard
//            let data = shopJson.data(using: .utf8),
//            let config = try? JSONDecoder().decode(ShopConfig.self, from: data),
//            let firstItem = config.shopData.first,
//            let resolved = URL(string: firstItem.widgetUrl)
//        else { return }
//        
//        widgetURL = resolved
//    }
//}

//
//  ShopBentoViewModel.swift
//  brainwallet
//
//  Created by Kerry Washington on 5/8/26.
//  Copyright © 2026 Grunt Software, LTD. All rights reserved.
//
import Foundation
import SwiftUI


struct ShopCard: Decodable, Identifiable {
    let countryCode: String
    let countryName: String
    let productSlug: String
    let productName: String
    let productURL: URL
    let cardImageWebP: URL
    
    var id: String { productSlug }
    
    enum CodingKeys: String, CodingKey {
        case countryCode  = "country_code"
        case countryName  = "country_name"
        case productSlug  = "product_slug"
        case productName  = "product_name"
        case productURL   = "product_url"
        case cardImageWebP = "card_image_webp"
    }
}

class ShopBentoViewModel: ObservableObject {
    
    // MARK: - Public Variables
    
    @Published
    var widgetURL: URL = URL(string: BrainwalletShop.bitrefillCode)!
    
    @Published
    var cards: [ShopCard]?
    
    init() {
        let key = RemoteConfigKeys.PATH_SHOP_CONTENT.rawValue
        let shopJson = RemoteConfigHelper().getString(key: key)
        fetchShopConfig(from: shopJson)
    }

    // MARK: - Models
    
    private struct ShopConfig: Decodable {
        let shopData: ShopData
        
        enum CodingKeys: String, CodingKey {
            case shopData = "shop_data"
        }
    }
    
    private struct ShopData: Decodable {
        let widgetUrl: URL
        let cards: [ShopCard]
        enum CodingKeys: String, CodingKey {
            case widgetUrl = "widget_url"
            case cards
        }
    }
    
    // MARK: - Fetch
    
    func fetchShopConfig(from jsonString: String) {
        guard let outerData = jsonString.data(using: .utf8) else {
            assertionFailure("ShopConfig: invalid UTF-8 string")
            return
        }
        
        do {
            let config = try JSONDecoder().decode(ShopConfig.self, from: outerData)
            let data = config.shopData
            widgetURL = data.widgetUrl
            cards = data.cards
        } catch {
            assertionFailure("ShopConfig decode failed: \(error)")
        }
    }
}

//
//class ShopBentoViewModel: ObservableObject {
//    
//    // MARK: - Public Variables
//    
//    @Published
//    var widgetURL: URL = URL(string: BrainwalletShop.bitrefillCode)!
//    
//    init() {
//        let key = RemoteConfigKeys.PATH_SHOP_CONTENT.rawValue
//        let shopJson = RemoteConfigHelper().getString(key: key)
//        fetchShopConfig(from: shopJson)
//    }
//    
//    // MARK: - Models
//    
//    private struct ShopConfig: Decodable {
//        let shopData: ShopData
//        enum CodingKeys: String, CodingKey {
//            case shopData = "shop_data"
//        }
//    }
//    
//    private struct ShopData: Decodable {
//        let widgetUrl: URL
//        let cards: [ShopCard]
//        enum CodingKeys: String, CodingKey {
//            case widgetUrl = "widget_url"
//            case cards
//        }
//    }
//    
//    private struct ShopCard: Decodable, Identifiable {
//        let countryCode: String
//        let countryName: String
//        let productSlug: String
//        let productName: String
//        let productURL: URL
//        let cardImageWebP: URL
//        
//        var id: String { productSlug }
//        
//        enum CodingKeys: String, CodingKey {
//            case countryCode  = "country_code"
//            case countryName  = "country_name"
//            case productSlug  = "product_slug"
//            case productName  = "product_name"
//            case productURL   = "product_url"
//            case cardImageWebP = "card_image_webp"
//        }
//    }
//    // MARK: - Fetch
//    
//    /// Internal entry point — accepts a raw JSON string so tests can inject directly.
//    func fetchShopConfig(from jsonString: String) {
//        guard let data = jsonString.data(using: .utf8) else {
//            assertionFailure("ShopConfig: invalid UTF-8 string")
//            return
//        }
//        do {
//            let config = try JSONDecoder().decode(ShopConfig.self, from: data)
//            loadCardImages()
//        } catch {
//            // DecodingError will tell you exactly which key/type failed
//            assertionFailure("ShopConfig decode failed: \(error)")
//        }
//    }
//}
