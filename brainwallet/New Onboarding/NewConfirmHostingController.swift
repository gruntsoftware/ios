//
//  NewConfirmHostingController.swift
//  brainwallet
//
//  Created by Kerry Washington on 10/05/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

import Foundation
import SwiftUI

class NewConfirmHostingController: UIHostingController<NewConfirmView> {
    
    // MARK: - Private
    var didCompleteConfirmation: (() -> Void)?
    
    var store: Store?

    init(store: Store) {
        
        self.store = store
        
        let viewModel = NewConfirmViewModel(store: store)
        super.init(rootView: NewConfirmView(viewModel: viewModel))
    }
 
    @available(*, unavailable)
    @MainActor dynamic required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
