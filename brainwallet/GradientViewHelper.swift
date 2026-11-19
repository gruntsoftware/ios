import UIKit
import SwiftUI

protocol SolidColorDrawable {
	func drawColor(color: UIColor, _ rect: CGRect)
}

extension UIView {
    func drawColor(color _: UIColor = BrainwalletUIColor.surface, _: CGRect) {
        let colorView = UIView()
        colorView.backgroundColor = BrainwalletUIColor.background
        addSubview(colorView)
        colorView.constrain(toSuperviewEdges: nil)
        sendSubviewToBack(colorView)
	}
}

// MARK: - Emoji Setup Gradients

/// Full screen purple background for EmojiSetPagerView, its pages and SetSixthEmojiView
public let emojisBackgroundGradient = LinearGradient(colors: [BentoColor.sendTopPurple,
                                                              BentoColor.sendBottomPurple.opacity(0.7),
                                                              BentoColor.sendBottomPurple.opacity(0.05)],
                                                     startPoint: .top, endPoint: .bottom)

/// Background of the row holding the 3 emoji fields
public let emojisSectionGradient = LinearGradient(colors: [BentoColor.color14134C.opacity(0.5),
                                                           BentoColor.color5827E2.opacity(0.1),
                                                           Color.white.opacity(0.1)],
                                                  startPoint: .leading, endPoint: .trailing)

/// Background of each emoji field
public let emojisFieldGradient = LinearGradient(colors: [Color.white.opacity(0.1),
                                                         Color.white.opacity(0.03)],
                                                startPoint: .topLeading, endPoint: .bottomTrailing)
