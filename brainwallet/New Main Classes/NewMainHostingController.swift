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

    var store: Store?

    var walletManager: WalletManager?

    var mainViewModel: NewMainViewModel

    init(store: Store, walletManager: WalletManager) {
        self.store = store
        self.walletManager = walletManager
        /// Migrate CanUserBuy when ready
        ///
        let receiveViewModel = NewReceiveViewModel(store: store, walletManager: walletManager, canUserBuy: false)
        mainViewModel = NewMainViewModel(store: store, walletManager: walletManager)
        super.init(rootView: CoreModeView(mainViewModel: mainViewModel, receiveViewModel: receiveViewModel))
    }

    // MARK: - Private
    @available(*, unavailable)
    @MainActor dynamic required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
