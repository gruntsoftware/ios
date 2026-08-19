//
//  VariableBlurView.swift
//  brainwallet
//
//  Created by Kerry Washington on 18/08/2026.
//  Copyright © 2026 Grunt Software, LTD. All rights reserved.
//

import SwiftUI
import UIKit

/// SwiftUI's `.ultraThinMaterial` is the lightest of Apple's five fixed Material
/// presets - there's no way to dial its blur radius down further, and fading it
/// with `.opacity()` just erases the whole layer (blur + vibrancy) rather than
/// making the blur itself lighter.
///
/// This wraps a `UIVisualEffectView` and drives its blur through a
/// `UIViewPropertyAnimator` stopped partway (`fractionComplete`), which yields a
/// continuously adjustable blur strength anywhere from 0 (no blur) to 1 (full
/// system blur) using only public API.
private final class VariableBlurUIView: UIVisualEffectView {

    private var animator: UIViewPropertyAnimator?

    init(intensity: CGFloat, style: UIBlurEffect.Style) {
        super.init(effect: nil)

        let animator = UIViewPropertyAnimator(duration: 1.0, curve: .linear) { [weak self] in
            self?.effect = UIBlurEffect(style: style)
        }
        animator.fractionComplete = intensity
        self.animator = animator
    }

    func update(intensity: CGFloat) {
        animator?.fractionComplete = intensity
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

/// A SwiftUI blur view whose strength can be set to any value between 0 and 1,
/// instead of being limited to Apple's fixed `.ultraThinMaterial` ... `.ultraThickMaterial` steps.
struct VariableBlurView: UIViewRepresentable {

    /// 0 = no blur (fully see-through), 1 = the system's full-strength blur for `style`.
    var intensity: CGFloat
    var style: UIBlurEffect.Style = .systemUltraThinMaterial

    func makeUIView(context _: Context) -> UIVisualEffectView {
        VariableBlurUIView(intensity: intensity, style: style)
    }

    func updateUIView(_ uiView: UIVisualEffectView, context _: Context) {
        (uiView as? VariableBlurUIView)?.update(intensity: intensity)
    }
}
