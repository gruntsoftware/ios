//
//  SeedWordViewModel.swift
//  brainwallet
//
//  Created by Kerry Washington on 02/02/2026.
//  Copyright © 2026 Grunt Software, LTD. All rights reserved.
//

import SwiftUI

/// - Tag: SeedWordViewModel
final class SeedWordViewModel: ObservableObject {

//    @State
//    private var viewIndex = 0
//    
//    @State
//    private var isActive: Bool = false

    @Published
    var isActive: Bool = false

    @Published
    var viewIndex = 0

    init() {

    }

}
