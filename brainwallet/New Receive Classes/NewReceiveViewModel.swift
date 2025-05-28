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
    var newReceiveAddress = WalletManager.sharedInstance.wallet?.receiveAddress ?? ""
    
    @Published
    var newReceiveAddressQR: UIImage?
    
    @Published
    var currentFiat = "USD"
    
    @Published
    var fiatAmounts: [Int] = [20]
    
    @Published
    var pickedAmount: Int = 0
    
    @Published
    var convertedLTC = 0.0
    
    @Published
    var fetchedTimestamp = "22 DEC 2025 1:00"
    
    var store: Store?
    
    let currencies: [CurrencySelection] = CurrencySelection.allCases

    init(store: Store) {
        self.store = store
        
        fetchRangeOfPurchaseAmounts()
        generateQRCode()
    }
    
    
    func setCurrency(code: String) {
        UserDefaults.defaultCurrencyCode = code
        UserDefaults.standard.synchronize()
        Bundle.setLanguage(code)

        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .preferredCurrencyChangedNotification,
                                            object: nil,
                                            userInfo: nil)
        }
    }
    
    
    func fetchRangeOfPurchaseAmounts() {
        
        
        
        self.fiatAmounts = [21,22,23,24,25]
        
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
