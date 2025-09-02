//
//  ExportHostingController.swift
//  brainwallet
//
//  Created by Kerry Washington on 03/09/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

import Foundation
import SwiftUI

class ExportHostingController: UIHostingController<ExportButtonView> {

    var viewModel = ExportButtonViewModel()
    var exportButtonView: ExportButtonView
    init() {
        exportButtonView = ExportButtonView(viewModel: viewModel)
        super.init(rootView: exportButtonView)
    }

    @available(*, unavailable)
    @MainActor dynamic required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
