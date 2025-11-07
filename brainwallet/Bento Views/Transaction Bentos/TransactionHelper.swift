//
//  TransactionHelper.swift
//  brainwallet
//
//  Created by Kerry Washington on 01/11/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

import Foundation
import SwiftUI

enum Selection {
    case receive
    case send
    case gameHistory
}

enum TransactionFilterState: Int, CaseIterable {
    case allTransactions = 0
    case sendTransactions
    case receiveTransactions

    var label: String {
        switch self {
        case .allTransactions:
            return "All"
        case .sendTransactions:
            return "Sent"
        case .receiveTransactions:
            return "Received"
        }
    }

    var icon: String {
        switch self {
        case .allTransactions:
            return "smallcircle.filled.circle"
        case .sendTransactions:
            return "arrow.up.circle"
        case .receiveTransactions:
            return "arrow.down.circle"
        }
    }

    var iconColor: Color {
        switch self {
        case .allTransactions:
            return Color.white
        case .sendTransactions:
            return BrainwalletColor.transferRed
        case .receiveTransactions:
            return BrainwalletColor.affirm
        }
    }

    mutating func toggle() {
            let nextRawValue = (self.rawValue + 1) % Self.allCases.count
            self = TransactionFilterState(rawValue: nextRawValue)!
    }
}
