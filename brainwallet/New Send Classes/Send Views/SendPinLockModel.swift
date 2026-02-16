//
//  SendPinLockModel.swift
//  brainwallet
//
//  Created by Kerry Washington on 13/01/2026.
//  Copyright © 2026 Grunt Software, LTD. All rights reserved.
//

import SwiftUI

@MainActor
class SendPinLockModel: ObservableObject {

    @Published
    var authenticationFailed =  true

    @Published
    var pinDigits = [Int(),Int(),Int(),Int()]

    var walletManager: WalletManager?

    init(walletManager: WalletManager? = nil) {
        self.walletManager = walletManager
    }

    func didVerifyPin() -> Bool {
        if let walletManager = walletManager,
            walletManager.authenticate(pin: pinDigits.map {String($0)}.joined()) {
            return true
        }
        return false
    }
}
