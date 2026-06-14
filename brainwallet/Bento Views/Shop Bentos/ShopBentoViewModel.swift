////
////  ShopBentoViewModel.swift
////  brainwallet
////
////  Created by Kerry Washington on 5/8/26.
////  Copyright © 2026 Grunt Software, LTD. All rights reserved.
////
import Foundation
import SwiftUI

class ShopBentoViewModel: ObservableObject {

    // MARK: - Public Variables

    @Published
    var widgetURL: URL = URL(string: BrainwalletShop.bitrefillCode)!

    @Published
    var cards: [ShopCard]?
    @Published
    var cardsAreLoaded = false

    @Published
    var cardImages: [UIImage]?

    @Published
    var cardImagesVersion: Int = 0

    @StateObject
    private var loader = ImageLoader()


    init() {
        let key = RemoteConfigKeys.PATH_SHOP_CONTENT.rawValue
        let shopJson = RemoteConfigHelper().getString(key: key)
        fetchShopConfig(from: shopJson)
    }

    func updateCardImages(_ images: [UIImage]) {
        cardImages = images
        cardImagesVersion += 1

    }

    private func loadCardImages(_ cards: [ShopCard]?) async {
        guard let realCards = cards else {
            return
        }
        var loaded: [UIImage] = []
        for card in realCards {
            if let uiImage = await ImageLoader.loadImage(from: card.cardImageWebP) {
                loaded.append(uiImage)
            } else {
                loaded.append(UIImage(named: "bw-placeholder")!)
            }
        }
        await MainActor.run {
            updateCardImages(loaded)
            cardsAreLoaded = true
        }
    }

    // MARK: - Fetch

    func fetchShopConfig(from jsonString: String) {
        guard let jsonData = jsonString.data(using: .utf8) else {
            assertionFailure("ShopConfig: invalid UTF-8 string")
            return
        }

        do {
            let shopConfig = try JSONDecoder().decode(ShopConfig.self, from: jsonData)
            let data = shopConfig.shopData
            widgetURL = data.widgetUrl

            if let regionCode = Locale.current.region?.identifier {
                cards = data.cards.filter { $0.countryCode.contains(regionCode) }
                Task {
                    await loadCardImages(cards)
                }
            }

        } catch {
            assertionFailure("ShopConfig decode failed: \(error)")
        }
    }
}

