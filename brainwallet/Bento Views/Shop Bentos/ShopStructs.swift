//
//  ShopStructs.swift
//  brainwallet
//
//  Created by Kerry Washington on 5/23/26.
//  Copyright © 2026 Grunt Software, LTD. All rights reserved.
//

// MARK: - Shop Structs
import SwiftUI

struct ShopConfig: Codable {
    let shopData: ShopData
    
    enum CodingKeys: String, CodingKey {
        case shopData = "shop_data"
    }
}

struct ShopData: Codable {
    let widgetUrl: URL
    let cards: [ShopCard]
    enum CodingKeys: String, CodingKey {
        case widgetUrl = "widget_url"
        case cards
    }
    }
struct ShopCard: Codable, Identifiable {
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
