//
//  ShopImages.swift
//  brainwallet
//
//  Created by Kerry Washington on 5/23/26.
//  Copyright © 2026 Grunt Software, LTD. All rights reserved.
//

import SwiftUI
import UIKit

final class ImageLoader: ObservableObject {
    
    private static let cache = NSCache<NSURL, UIImage>()
    
     
    static func loadImage(from url: URL) async -> UIImage? {
        
        // Memory cache
        if let cached = cache.object(forKey: url as NSURL) {
            return cached
        }
        
        var request = URLRequest(url: url)
        
        request.timeoutInterval = 20
        
        // Important for CDNs
        request.setValue(
            "image/webp,image/*,*/*;q=0.8",
            forHTTPHeaderField: "Accept"
        )
        request.setValue(
            "https://www.bitrefill.com/",
            forHTTPHeaderField: "Referer"
        )
        request.setValue(
            "https://www.bitrefill.com",
             forHTTPHeaderField: "Origin"
        )
        
        // Retry transient CDN failures
        for attempt in 1...3 {
            
            do {
                
                let (data, response) = try await URLSession.shared.data(for: request)
                
                guard
                    let http = response as? HTTPURLResponse
                else {
                    continue
                }
                
                // Validate status code
                guard (200...299).contains(http.statusCode) else {
                    let isRetryable = http.statusCode >= 500 || http.statusCode == 429
                    if isRetryable && attempt < 3 {
                        try await Task.sleep(for: .seconds(Double(attempt)))
                        continue
                    }
                    return nil
                }
                
                // Validate MIME type
                guard (http.mimeType ?? "").starts(with: "image/") else {
                    return nil
                }
                
                // Validate image decode
                guard let uiImage = UIImage(data: data) else {
                    return nil
                }
                
                cache.setObject(uiImage, forKey: url as NSURL)
                return uiImage
                
            } catch {
                if attempt == 3 { return nil }
                try? await Task.sleep(for: .seconds(Double(attempt) * 1.5))
            }
        }
        return nil
    }
}
