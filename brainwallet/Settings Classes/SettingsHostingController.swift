//
//  SettingsHostingController.swift
//  brainwallet
//
//  Created by Kerry Washington on 15/05/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//
import Foundation
import SwiftUI
import UIKit

class SettingsHostingController: UIHostingController<SettingsView> {
    
    // MARK: - Private
    var didCompleteConfirmation: (() -> Void)?
    
    var store: Store?

    init(store: Store) {
        
        self.store = store
        
        let viewModel = SettingsViewModel(store: store)
        super.init(rootView: SettingsView(viewModel: viewModel))
    }
 
    @available(*, unavailable)
    @MainActor dynamic required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}


//func userWantsToCreate(completion: @escaping () -> Void) {
//    didTapCreate = completion
//}
