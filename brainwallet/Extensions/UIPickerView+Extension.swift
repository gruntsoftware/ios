//
//  UIPickerView+Extension.swift
//  brainwallet
//
//  Created by Kerry Washington on 18/08/2026.
//  Copyright © 2026 Grunt Software, LTD. All rights reserved.
//

import UIKit

/// `UIPickerView.appearance().backgroundColor` only clears the picker's own
/// top-level background - the wheel's visible row/selection fill is actually
/// painted by its internal subviews (an inner `UIPickerTableView` per component),
/// which the appearance proxy never touches. Clearing those subviews directly
/// is what actually removes the background SwiftUI's `.pickerStyle(.wheel)` shows.
extension UIPickerView {
    override open func didMoveToWindow() {
        super.didMoveToWindow()
        clearSubviewBackgrounds()
    }

    override open func layoutSubviews() {
        super.layoutSubviews()
        clearSubviewBackgrounds()
    }

    private func clearSubviewBackgrounds() {
        backgroundColor = .clear
        subviews.forEach { $0.backgroundColor = .clear }
    }
}
