import UIKit

extension UIButton {
	static func vertical(title: String, image: UIImage) -> UIButton {
		let button = UIButton(type: .system)
		button.setTitle(title, for: .normal)
		button.setImage(image, for: .normal)
		button.titleLabel?.font = UIFont.customMedium(size: 11.0)
		return button
	}

	static var close: UIButton {
		let accessibilityLabel = "Close"
		return UIButton.icon(image: #imageLiteral(resourceName: "Close"), accessibilityLabel: accessibilityLabel)
	}

//	static func buildFaqButton(store: Store, articleId: String) -> UIButton {
//		let button = UIButton.icon(image: #imageLiteral(resourceName: "Faq"), accessibilityLabel: "S.AccessibilityLabels.faq" )
//		button.tap = {
//			store.trigger(name: .presentFaq(articleId))
//		}
//		return button
//	}

	static func icon(image: UIImage, accessibilityLabel: String) -> UIButton {
		let button = UIButton(type: .system)
		button.frame = CGRect(x: 0, y: 0, width: 44, height: 44)
		button.setImage(image, for: .normal)
		button.tintColor = BrainwalletUIColor.content
		button.accessibilityLabel = accessibilityLabel
		return button
	}

	func tempDisable() {
		isEnabled = false
		DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
			self?.isEnabled = true
		}
	}
}
