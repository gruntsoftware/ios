//
//  NewMainHostingController.swift
//  brainwallet
//
//  Created by Kerry Washington on 03/05/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.

import Foundation
import SwiftUI
import BrainwalletiOSPrivateGeneralPurpose

class NewMainHostingController: UIHostingController<CoreModeView> {

    var store: Store
    var walletManager: WalletManager
    var newMainViewModel: NewMainViewModel

    init(newMainViewModel: NewMainViewModel,
         store: Store,
         walletManager: WalletManager) {
        self.store = store
        self.walletManager = walletManager
        self.newMainViewModel = newMainViewModel
        let receiveViewModel = NewReceiveViewModel(store: self.store, walletManager: self.walletManager, canUserBuy: false)
        super.init(rootView: CoreModeView(mainViewModel: self.newMainViewModel, receiveViewModel: receiveViewModel))
    }

    // MARK: - Private
    @available(*, unavailable)
    @MainActor dynamic required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
