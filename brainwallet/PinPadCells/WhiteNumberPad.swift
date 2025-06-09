//
//  WhiteNumberPad.swift
//  brainwallet
//
//  Created by Kerry Washington on 27/05/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//
import UIKit

class WhiteNumberPad: GenericPinPadCell {
    override func setAppearance() {
        if text == "0" {
            topLabel.isHidden = true
            centerLabel.isHidden = false
        } else {
            topLabel.isHidden = false
            centerLabel.isHidden = true
        }

        if isHighlighted {
            backgroundColor = BrainwalletUIColor.surface
            topLabel.textColor = BrainwalletUIColor.content
            centerLabel.textColor = BrainwalletUIColor.content
            sublabel.textColor = BrainwalletUIColor.content
        } else {
            if text == "" || text == deleteKeyIdentifier {
                backgroundColor = BrainwalletUIColor.surface
                imageView.image = imageView.image?.withRenderingMode(.alwaysTemplate)
                imageView.tintColor = BrainwalletUIColor.content
            } else {
                backgroundColor = BrainwalletUIColor.surface
                topLabel.textColor = BrainwalletUIColor.content
                centerLabel.textColor = BrainwalletUIColor.content
                sublabel.textColor = BrainwalletUIColor.content
            }
        }
    }

    override func setSublabel() {
        guard let text = text else { return }
        if sublabels[text] != nil {
            sublabel.text = sublabels[text]
        }
    }
}
