//
//  PromptCellViewModel.swift
//  brainwallet
//
//  Created by Kerry Washington on 05/06/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//
import Foundation
import SwiftUI
import LocalAuthentication

class PromptCellViewModel: ObservableObject {

    @Published var promptType: PromptType = .recommendRescan
    
    init(promptType: PromptType) {
        self.promptType = promptType
    }
    
}
