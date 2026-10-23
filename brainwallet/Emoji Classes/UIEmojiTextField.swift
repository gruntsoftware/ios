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
            // Reloading input views while the keyboard animates in tears it down and leaves a blank keyboard
            guard isEmoji != oldValue else { return }
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

    /// Set by SwiftUI; honoured as soon as the field is in a window,
    /// because becomeFirstResponder() silently fails before that.
    var wantsFocus = false

    private var focusWorkItem: DispatchWorkItem?

    /// Shows the keyboard after a delay; the box border is not affected.
    func requestFocus(after delay: TimeInterval = 1.0) {
        focusWorkItem?.cancel()
        let item = DispatchWorkItem { [weak self] in
            guard let self, self.wantsFocus, self.window != nil, !self.isFirstResponder else { return }
            self.becomeFirstResponder()
        }
        focusWorkItem = item
        DispatchQueue.main.asyncAfter(deadline: .now() + delay, execute: item)
    }

    func dropFocus() {
        focusWorkItem?.cancel()
        if isFirstResponder { resignFirstResponder() }
    }

    override func didMoveToWindow() {
        super.didMoveToWindow()
        if window != nil && wantsFocus && !isFirstResponder {
            requestFocus()
        }
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
    /// nil = unmanaged (user taps decide). true/false = drive the keyboard.
    var isFirstResponder: Bool?
    var onBeginEditing: (() -> Void)?

    func makeUIView(context: Context) -> UIEmojiTextField {

        let textField = UIEmojiTextField()
        textField.placeholder = placeholder
        textField.text = text
        textField.textAlignment = .center
        textField.font = UIFont.systemFont(ofSize: 50)
        textField.backgroundColor = .clear
        textField.tintColor = UIColor(.white)
        textField.delegate = context.coordinator
        textField.wantsFocus = isFirstResponder ?? false
        return textField
    }

    func updateUIView(_ uiView: UIEmojiTextField, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }
        uiView.isEmoji = true
        context.coordinator.parent = self

        guard let wantsFocus = isFirstResponder else { return }
        let changed = uiView.wantsFocus != wantsFocus
        uiView.wantsFocus = wantsFocus
        if wantsFocus && changed && uiView.window != nil {
            uiView.requestFocus()
        } else if !wantsFocus {
            uiView.dropFocus()
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: EmojiTextField

        init(parent: EmojiTextField) {
            self.parent = parent
        }

        func textFieldDidBeginEditing(_ textField: UITextField) {
            parent.onBeginEditing?()
        }

        func textFieldDidChangeSelection(_ textField: UITextField) {
            Task {
                parent.text = textField.text ?? ""
            }
        }
    }
}
