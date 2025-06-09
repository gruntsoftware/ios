//
//  ReceiveHostingController.swift
//  brainwallet
//
//  Created by Kerry Washington on 28/05/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

import Foundation
import SwiftUI

class ReceiveHostingController: UIHostingController<NewReceiveView> {
    
    // MARK: - Private
    var didCompleteConfirmation: (() -> Void)?
    
    var store: Store?
    
    var walletManager: WalletManager?
      
    init(store: Store, walletManager: WalletManager ,canUserBuy: Bool) {
        let viewModel = NewReceiveViewModel(store: store, walletManager: walletManager, canUserBuy: canUserBuy)
        super.init(rootView: NewReceiveView(viewModel: viewModel))
    }
 
    @available(*, unavailable)
    @MainActor dynamic required init?(coder _: NSCoder) {
        return nil
    }
}
