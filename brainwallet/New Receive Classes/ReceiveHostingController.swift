//
//  ReceiveHostingController.swift
//  brainwallet
//
//  Created by Kerry Washington on 28/05/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

import Foundation
import SwiftUI

class BuyReceiveHostingController: UIHostingController<BuyReceiveView> {
    
    // MARK: - Private
    var dismissBuyReceiveModal: (() -> Void)?
    
    var store: Store?
    
    var walletManager: WalletManager?
      
    let isModalMode: Bool
      
    init(store: Store, walletManager: WalletManager, isModalMode: Bool) {
        self.isModalMode = isModalMode
        let viewModel = NewReceiveViewModel(store: store, walletManager: walletManager, canUserBuy: true)
        super.init(rootView: BuyReceiveView(viewModel: viewModel, isModalMode: isModalMode))
        
        viewModel.dismissReceiveModal = { [weak self] in
            self?.dismissBuyReceiveModal?()
        }
    }
 
    @available(*, unavailable)
    @MainActor dynamic required init?(coder _: NSCoder) {
        return nil
    }
}
extension BuyReceiveHostingController: ModalDisplayable {

    var modalTitle: String {
        return ""
    }
}

class ReceiveHostingController: UIHostingController<NewReceiveView> {
    
    // MARK: - Private
    var dismissReceiveModal: (() -> Void)?
    
    var store: Store?
    
    var walletManager: WalletManager?
      
    let isModalMode: Bool
      
    init(store: Store, walletManager: WalletManager, isModalMode: Bool) {
        self.isModalMode = isModalMode
        let viewModel = NewReceiveViewModel(store: store, walletManager: walletManager, canUserBuy: false)
        
        super.init(rootView: NewReceiveView(viewModel: viewModel, isModalMode: isModalMode))
        
        viewModel.dismissReceiveModal = { [weak self] in
            self?.dismissReceiveModal?()
        }
    }
 
    @available(*, unavailable)
    @MainActor dynamic required init?(coder _: NSCoder) {
        return nil
    }
}
extension ReceiveHostingController: ModalDisplayable {

    var modalTitle: String {
        return ""
    }
}
