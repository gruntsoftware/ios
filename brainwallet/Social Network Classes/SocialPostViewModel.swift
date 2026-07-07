//
//  SocialPostViewModel.swift
//  brainwallet
//
//  Created by Kerry Washington on 7/2/26.
//  Copyright © 2026 Grunt Software, LTD. All rights reserved.
//
import SwiftUI
import FirebaseAnalytics
import UniformTypeIdentifiers

enum SocialNetwork: String, CaseIterable, Identifiable {
    case instagramStories
    case twitter
    
    var id: Self { self }
}

final class SocialPostViewModel: ObservableObject {
    @Published var isPresentingShareSheet = false
    @Published var shareImage: UIImage?
    private let xMessageText = String(localized: "I just scored on @Brainwallet_App, check it out:")

    init() {
    }
    
    func image(from pngData: Data) -> UIImage? {
        guard let image = UIImage(data: pngData) else {
            assertionFailure("Failed to decode PNG data into UIImage — data may be corrupt or empty")
            return nil
        }
        return image
    }
    
    func shareToInstagramStories(image: UIImage, backgroundTopColor: String = "#000000") {
        
        let postId = Partner.partnerKeyPath(name: .postMetaID)
        guard let url =  URL(string: "instagram-stories://share?source_application=\(postId)") else {
            assertionFailure("Malformed Instagram Stories URL")
            return
        }
         
        guard UIApplication.shared.canOpenURL(url) else {
            assertionFailure("Instagram not installed, or 'instagram-stories' missing from LSApplicationQueriesSchemes")
            return
        }
        
        guard let imageData = image.pngData() else {
            assertionFailure("pngData() returned nil — image size: \(image.size), scale: \(image.scale)")
            return
        }
        
        let pasteboardItems: [String: Any] = [
            "com.instagram.sharedSticker.backgroundImage": imageData,
            "com.instagram.sharedSticker.backgroundTopColor": backgroundTopColor
        ]
        UIPasteboard.general.setItems([pasteboardItems],
                                      options: [.expirationDate: Date().addingTimeInterval(60 * 5)])
        
        UIApplication.shared.open(url)
    }
    func shareToX(image: UIImage, backgroundTopColor: String = "#000000") {
        let preText = xMessageText
        let encoded = preText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        guard let imageData = image.pngData() else {
            assertionFailure("pngData() returned nil — image size: \(image.size), scale: \(image.scale)")
            return
        }
        
        UIPasteboard.general.setItems(
            [[UTType.png.identifier: imageData]],
            options: [.expirationDate: Date().addingTimeInterval(60 * 5)]
        )

        if let nativeURL = URL(string: "twitter://post?message=\(encoded)"),
           UIApplication.shared.canOpenURL(nativeURL) {
            UIApplication.shared.open(nativeURL)
        } else if let webURL = URL(string: "https://x.com/intent/post?text=\(encoded)") {
            UIApplication.shared.open(webURL)
        } else {
            assertionFailure("Unable to construct X share URL")
        }
    }
}
