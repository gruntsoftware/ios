//
//  SendHostingController.swift
//  brainwallet
//
//  Created by Kerry Washington on 17/05/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//


import Foundation
import SwiftUI

class SendHostingController: UIHostingController<SendView> {
      
    private let store: Store
    private let sender: Sender
    private let walletManager: WalletManager
    private let keyValueStore: BRReplicatedKVStore
    
    init?(store: Store,
         sender: Sender,
         walletManager: WalletManager) {
        
       self.store = store
       self.sender = sender
       self.walletManager = walletManager
        
        guard let kvStore = walletManager.apiClient?.kv else { return nil }
        self.keyValueStore = kvStore
         
    let viewModel = SendViewModel(store: self.store, sender: Sender(walletManager: self.walletManager, kvStore: self.keyValueStore, store: store), walletManager: walletManager)
        super.init(rootView: SendView(viewModel: viewModel))
    }
 
    @available(*, unavailable)
    @MainActor dynamic required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
