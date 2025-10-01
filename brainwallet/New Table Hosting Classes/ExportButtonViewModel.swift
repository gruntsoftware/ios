//
//  ExportButtonViewModel.swift
//  brainwallet
//
//  Created by Kerry Washington on 03/09/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

import Foundation
import SwiftUI

class ExportButtonViewModel: ObservableObject {
    var didTapExport: (() -> Void)?
    var transactions: [[AnyHashable : Any]] = []
    init() {
    }
}
