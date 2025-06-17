//
//  LockScreenHostingController.swift
//  brainwallet
//
//  Created by Kerry Washington on 28/05/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

import Foundation
import SwiftUI

class LockScreenHostingController: UIHostingController<LockScreenView> {

    var viewModel: LockScreenViewModel

    var didEnterPIN: ((String) -> Void)?

    var didTapQR: (() -> Void)?

    var didTapWipeWallet: ((Bool) -> Void)?

    init(store: Store) {
        viewModel = LockScreenViewModel(store: store)

        let userPrefersDarkMode = UserDefaults.userPrefersDarkTheme

       super.init(rootView: LockScreenView(viewModel: viewModel))

        viewModel.userSubmittedPIN = { [weak self] pin in
            self?.didEnterPIN?(pin)
        }

        viewModel.userDidTapQR = { [weak self] in
            self?.didTapQR?()
        }

        viewModel.didTapWipeWallet = { [weak self] userWantsToDelete in

            if userWantsToDelete {
                self?.didTapWipeWallet?(userWantsToDelete)
            }
        }
    }

    func walletWiped() {
        viewModel.didCompleteWipingWallet = true
    }

    @available(*, unavailable)
    @MainActor dynamic required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
