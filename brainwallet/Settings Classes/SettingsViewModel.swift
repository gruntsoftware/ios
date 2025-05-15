//
//  SettingsViewModel.swift
//  brainwallet
//
//  Created by Kerry Washington on 15/05/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//
import AVFoundation
import Foundation
import SwiftUI
import UIKit

class SettingsViewModel: ObservableObject, Subscriber {
    // MARK: - Combine Variables
    
    @Published
    var currentValueInFiat: String = ""
    
    @Published
    var currencyCode: String = ""
    //UserDefaults.writePaperPhraseDate = Date()
    //store.trigger(name: .didWritePaperKey)
    //didCompleteConfirmation?()
    
    var store: Store?

    init(store: Store) {
        self.store = store
    }
    
}
