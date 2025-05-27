//
//  ClearDecimalPad.swift
//  brainwallet
//
//  Created by Kerry Washington on 27/05/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//
import UIKit

class ClearDecimalPad: GenericPinPadCell {
    override func setAppearance() {
        centerLabel.backgroundColor = .clear
        imageView.image = imageView.image?.withRenderingMode(.alwaysTemplate)

        if isHighlighted {
            centerLabel.textColor = BrainwalletUIColor.content
            imageView.tintColor = BrainwalletUIColor.content
        } else {
            centerLabel.textColor = BrainwalletUIColor.surface
            imageView.tintColor = BrainwalletUIColor.surface
        }
    }

    override func addConstraints() {
        centerLabel.constrain(toSuperviewEdges: nil)
        imageView.constrain(toSuperviewEdges: nil)
    }
}
