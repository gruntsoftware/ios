//
//  ExportModalViewModel.swift
//  brainwallet
//
//  Created by Kerry Washington on 20/07/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

import Foundation
import SwiftUI
import BrainwalletiOSStorekit

class ExportModalViewModel: ObservableObject {

    @Published
    var transactionsPDF = Data()

    @Published
    var transactionsCSV = Data()

    @Published
    var exportCSVPrice = 0.0

    @Published
    var exportCSVPDFPrice = 0.0

    var transactions: [Transaction]

    init(transactions: [Transaction]) {
        self.transactions = transactions
    }

    func renderedImage() -> Image {
        return Image(systemName: "newspaper")
    }

    func userDidTapExportCSV() {
    }

    func userDidTapExportCSVAndPDF() {
    }

}
