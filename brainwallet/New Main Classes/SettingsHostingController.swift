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
    var newMainViewModel: NewMainViewModel
    var resetSettingsDrawer: (() -> Void)?

    init(newMainViewModel: NewMainViewModel,
         store: Store,
         walletManager: WalletManager) {
        self.store = store
        self.walletManager = walletManager
        self.newMainViewModel = newMainViewModel

        let settingsView = SettingsView(viewModel: self.newMainViewModel,
                                        path: .constant([.tempSettingsView]))
        super.init(rootView: settingsView)
        self.newMainViewModel.resetSettingsDrawer = {
            self.resetSettingsDrawer?()
        }
    }

    // MARK: - Private
    @available(*, unavailable)
    @MainActor dynamic required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
