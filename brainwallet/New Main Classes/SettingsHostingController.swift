//
//  SettingsHostingController.swift
//  brainwallet
//
//  Created by Kerry Washington on 18/06/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

import Foundation
import SwiftUI

class SettingsHostingController: UIHostingController<SettingsView> {

    var store: Store?
    var walletManager: WalletManager?

    var resetSettingsDrawer: (() -> Void)?

    init(store: Store, walletManager: WalletManager) {
        self.store = store
        self.walletManager = walletManager
        /// Migrate CanUserBuy when ready
        let mainViewModel = NewMainViewModel(store: store, walletManager: walletManager)

        let settingsView = SettingsView(viewModel: mainViewModel, path: .constant([.tempSettingsView]))
        super.init(rootView: settingsView)
        mainViewModel.resetSettingsDrawer = {
            self.resetSettingsDrawer?()
        }
    }

    // MARK: - Private
    @available(*, unavailable)
    @MainActor dynamic required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
