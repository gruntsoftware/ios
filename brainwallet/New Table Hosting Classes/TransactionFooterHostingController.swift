//
//  TransactionFooterHostingController.swift
//  brainwallet
//
//  Created by Kerry Washington on 20/07/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

import Foundation
import SwiftUI

class TransactionFooterHostingController: UIHostingController<TransactionFooterView> {

    var useDoesWantToExport: ((Bool) -> Void)?

    var transactions: ((Int) -> Void)?

    var transactionFooterView: TransactionFooterView

    init() {
        transactionFooterView = TransactionFooterView()
        super.init(rootView: transactionFooterView)
    }

    // MARK: - Private
    @available(*, unavailable)
    @MainActor dynamic required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
