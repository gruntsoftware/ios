//
//  UIEmojiTextField.swift
//  brainwallet
//
//  Created by Kerry Washington on 21/02/2026.
//  Copyright © 2026 Grunt Software, LTD. All rights reserved.
//

import UIKit
import SwiftUI
// Source - https://stackoverflow.com/a/66397959
// Posted by Raja Kishan, modified by community. See post 'Timeline' for change history
// Retrieved 2026-02-21, License - CC BY-SA 4.0

class UIEmojiTextField: UITextField {

    var isEmoji = false {
        didSet {
            setEmoji()
        }
    }

    private func setEmoji() {
        self.reloadInputViews()
    }

    override var textInputContextIdentifier: String? {
        return ""
    }

    override var textInputMode: UITextInputMode? {
        for mode in UITextInputMode.activeInputModes {
            if mode.primaryLanguage == "emoji" && self.isEmoji {
                self.keyboardType = .default
                return mode

            } else if !self.isEmoji {
                return mode
            }
        }
        return nil
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        // Update frame when layout changes
        if let gradientLayer = layer.sublayers?.first as? CAGradientLayer {
            gradientLayer.frame = bounds
        }
    }

}

struct EmojiTextField: UIViewRepresentable {
    @Binding var text: String
    @Binding var userPrefersDarkTheme: Bool
    var placeholder: String = ""

    func makeUIView(context: Context) -> UIEmojiTextField {

        let textField = UIEmojiTextField()
        textField.placeholder = placeholder
        textField.text = text
        textField.textAlignment = .center
        textField.font = UIFont.systemFont(ofSize: 65)
        textField.backgroundColor = .clear
        textField.tintColor = UIColor(BentoColor.tutorialGreen2)
        textField.delegate = context.coordinator
        return textField
    }

    func updateUIView(_ uiView: UIEmojiTextField, context: Context) {
        uiView.text = text
        uiView.isEmoji = true
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: EmojiTextField

        init(parent: EmojiTextField) {
            self.parent = parent
        }

        func textFieldDidChangeSelection(_ textField: UITextField) {
            Task {
                parent.text = textField.text ?? ""
            }
        }
    }
}
