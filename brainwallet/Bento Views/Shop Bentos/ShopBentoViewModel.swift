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
    var widgetUrlString: String = ""
    private var widgetUrl: URL?
    
    init() {
        fetchShopConfig()
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
    
    private func fetchShopConfig() {
        
        let key = RemoteConfigKeys.PATH_SHOP_CONTENT.rawValue
        let shopJson = RemoteConfigHelper().getString(key: key)
        
        guard
            let data = shopJson.data(using: .utf8)
        else {
            NSLog("%@", "fetchShopConfig: invalid UTF-8 from remote config")
            return
        }
        
        do {
            let config = try JSONDecoder().decode(ShopConfig.self, from: data)
            
            guard let firstItem = config.shopData.first else {
                NSLog("%@", "fetchShopConfig: shop_data array is empty")
                return
            }
            
            guard let resolvedUrl = URL(string: firstItem.widgetUrl) else {
                NSLog("%@", "fetchShopConfig: malformed widget_url → \(firstItem.widgetUrl)")
                return
            }
            
            widgetUrl = resolvedUrl
            
        } catch {
            NSLog("%@", "fetchShopConfig: decode error → \(error.localizedDescription)")
        }
    }
    
    // MARK: - Fetch
    
    public func getWidgetUrl() -> URL? {
        return widgetUrl
    }
      
}
