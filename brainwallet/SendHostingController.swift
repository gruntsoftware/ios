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
      
    var store: Store?

    init(store: Store) {
        
        self.store = store
        
        let viewModel = SendViewModel(store: store)
        super.init(rootView: SendView(viewModel: viewModel))
    }
 
    @available(*, unavailable)
    @MainActor dynamic required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
