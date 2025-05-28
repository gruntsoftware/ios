//
//  BuyViewModel.swift
//  brainwallet
//
//  Created by Kerry Washington on 12/05/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

import Foundation
import SwiftUI
import UIKit

class BuyViewModel: ObservableObject {
    // MARK: - Combine Variables

    @Published
    var receivingAddress: String = ""

    @Published
    var urlString: String = ""
    
    @Published
    var signedURlString: String = ""
    

    @Published
    var selectedCode: String = "USD"

    @Published
    var uuidString: String = UIDevice.current.identifierForVendor?.uuidString ?? ""

    init() {
        receivingAddress = WalletManager.sharedInstance.wallet?.receiveAddress ?? ""
    }
}
