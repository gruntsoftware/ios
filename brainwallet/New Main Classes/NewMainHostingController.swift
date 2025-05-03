//
//  NewMainHostingController.swift
//  brainwallet
//
//  Created by Kerry Washington on 03/05/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

import Foundation
import SwiftUI

class NewMainHostingController: UIHostingController<NewMainView> {
    
    var viewModel: NewMainViewModel
    var store: Store
    var walletManager: WalletManager?
    
    init(store: Store, walletManager: WalletManager) {
        self.store = store
        self.walletManager = walletManager
        viewModel = NewMainViewModel(store: store, walletManager: walletManager)
        super.init(rootView: NewMainView(viewModel: viewModel))
    }
     
    // MARK: - Private
    @available(*, unavailable)
    @MainActor dynamic required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
