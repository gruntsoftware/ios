import UIKit

class MenuViewController: UIViewController, Trackable {
	// MARK: - Public

	var didTapSecurity: (() -> Void)?
	var didTapSupport: (() -> Void)?
	var didTapSettings: (() -> Void)?
	var didTapLock: (() -> Void)?

	// MARK: - Private

	fileprivate let buttonHeight: CGFloat = 72.0
	fileprivate let buttons: [MenuButton] = {
		let types: [MenuButtonType] = [.security, .customerSupport, .settings, .lock]
		return types.compactMap {
			MenuButton(type: $0)
		}
	}()

	fileprivate let bottomPadding: CGFloat = 32.0

	override func viewDidLoad() {
		var previousButton: UIView?
		for button in buttons {
			button.addTarget(self, action: #selector(MenuViewController.didTapButton(button:)), for: .touchUpInside)
			view.addSubview(button)
			var topConstraint: NSLayoutConstraint?
			if let viewAbove = previousButton {
				topConstraint = button.constraint(toBottom: viewAbove, constant: 0.0)
			} else {
				topConstraint = button.constraint(.top, toView: view, constant: 0.0)
			}
			button.constrain([
				topConstraint,
				button.constraint(.leading, toView: view, constant: 0.0),
				button.constraint(.trailing, toView: view, constant: 0.0),
				button.constraint(.height, constant: buttonHeight)
			])
			previousButton = button
		}

		previousButton?.constrain([
			previousButton?.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -C.padding[2])
		])

			view.backgroundColor = BrainwalletUIColor.surface

	}

	@objc private func didTapButton(button: MenuButton) {
		switch button.type {
		case .security:
			didTapSecurity?()
		case .customerSupport:
			didTapSupport?()
		case .settings:
			didTapSettings?()
		case .lock:
			didTapLock?()
		}
	}
}

extension MenuViewController: ModalDisplayable {
	var modalTitle: String {
		return String(localized: "Menu")
	}
}
