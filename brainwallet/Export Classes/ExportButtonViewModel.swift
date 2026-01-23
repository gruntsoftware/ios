//
//  ExportViewModel.swift
//  brainwallet
//
//  Created by Kerry Washington on 03/09/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

import Foundation
import SwiftUI

struct ExportedTransaction {

    var blockHeight: String = ""
    var toAddress: String = ""
    var unixTimestamp: TimeInterval = 0
    var shortTimestamp: String = ""
    var memoString: String = "--"
    var txFee: Int = 0
    var txHash: String = ""
    var amount: Int = 0

    let direction: TransactionDirection
    /// Calculated parameters
    var directionString: String {
        switch direction {
        case .received:
            return String(localized: "Received")
        case .sent:
            return String(localized: "Sent")
        case .moved:
            return String(localized: "Moved")
        }
    }
 }

class ExportViewModel: ObservableObject {

    var transactionData: [[AnyHashable : Any]] = []

    var transactions: [Transaction] = [] {
        didSet {
            debugPrint("|||| Transactions Updated Count: \(transactions.count)")

            var dataDict: [[AnyHashable: Any]] = []
            transactions.forEach { transaction in

                let export = ExportedTransaction(blockHeight: transaction.blockHeight,
                                                 toAddress: transaction.toAddress ?? "--",
                                                 unixTimestamp: TimeInterval(transaction.timestamp),
                                                 shortTimestamp: transaction.shortTimestamp,
                                                 memoString: transaction.memoString ?? "--",
                                                 txFee: Int(transaction.fee),
                                                 txHash: transaction.hash,
                                                 amount: transaction.litoshis,
                                                 direction: transaction.direction)

                let exportDict = ["Transaction_direction": export.directionString,
                                  "Block_height": export.blockHeight,
                                  "LTC_Address": export.toAddress,
                                  "UNIX_Timestamp": export.unixTimestamp,
                                  "Short_Date": export.shortTimestamp,
                                  "Memo": export.memoString,
                                  "Transaction_Hash": export.txHash,
                                  "Transaction_Fees": export.txFee,
                                  "Amount": export.amount] as [AnyHashable : Any]
                dataDict.append(exportDict)
            }
            transactionData = [["transactions": dataDict]]
        }
    }

    init() {
    }

}
