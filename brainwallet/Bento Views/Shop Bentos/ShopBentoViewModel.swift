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

class ShopBentoViewModel: ObservableObject {
    
    // MARK: - Public Variables
    
    @Published
    var widgetURL: URL = URL(string: BrainwalletShop.bitrefillCode)!
    
    init() {
        let key = RemoteConfigKeys.PATH_SHOP_CONTENT.rawValue
        let shopJson = RemoteConfigHelper().getString(key: key)
        fetchShopConfig(from: shopJson)
    }

    // MARK: - Models
    
    private struct ShopConfig: Decodable {
        let shopData: [ShopItem]
        
        enum CodingKeys: String, CodingKey {
            case shopData = "shop_data"
        }
    }
    
    private struct ShopItem: Decodable {
        let widgetUrl: String
        
        enum CodingKeys: String, CodingKey {
            case widgetUrl = "widget_url"
        }
    }
    
    // MARK: - Fetch
    
    /// Internal entry point — accepts a raw JSON string so tests can inject directly.
    func fetchShopConfig(from jsonString: String) {
        guard
            let data = jsonString.data(using: .utf8),
            let config = try? JSONDecoder().decode(ShopConfig.self, from: data),
            let firstItem = config.shopData.first,
            let resolved = URL(string: firstItem.widgetUrl)
        else { return }
        
        widgetURL = resolved
    }
}
