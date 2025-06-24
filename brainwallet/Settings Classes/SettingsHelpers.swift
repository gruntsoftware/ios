//
//  SettingsHelpers.swift
//  brainwallet
//
//  Created by Kerry Washington on 24/06/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//
import SwiftUI

let closedRowHeight: CGFloat = 65.0
let expandedRowHeight: CGFloat = 240.0
let rowLeadingPad: CGFloat = 32.0
let leadRowPad: CGFloat = 40.0
let trailRowPad: CGFloat = 16.0
let expandArrowSize: CGFloat = 20.0
let pickerViewHeight: CGFloat = 160.0

enum SettingsAction: CaseIterable {
    case preferDarkMode
    case wipeData
    case lock

    var isOnSystemImage: String {
        switch self {
        case .preferDarkMode:
            return "moon.circle"
        case .wipeData:
            return "trash"
        case .lock:
            return "lock"
        }
    }

    var isOffSystemImage: String {
        switch self {
        case .preferDarkMode:
            return "sun.max.circle"
        case .wipeData:
            return "trash"
        case .lock:
            return "lock.open"
        }
    }
}
