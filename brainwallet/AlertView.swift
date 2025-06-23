import UIKit

enum AlertType {
	case pinSet(callback: () -> Void)
	case paperKeySet(callback: () -> Void)
	case sendSuccess
	case addressesCopied
	case sweepSuccess(callback: () -> Void)

	// Failure(s)
	case failedResolution

	var header: String {
		switch self {
		case .pinSet:
			return  String(localized: "PIN Set")
		case .paperKeySet:
			return String(localized: "Paper Key Set")
		case .sendSuccess:
			return String(localized: "Send Confirmation")
		case .addressesCopied:
			return String(localized: "Addresses Copied")
		case .sweepSuccess:
			return String(localized: "Success")
		// Failure(s)
		case .failedResolution:
			return String(localized: "Send failed")
		}
	}

	var subheader: String {
		switch self {
		case .pinSet:
			return ""
		case .paperKeySet:
			return String(localized: "Awesome!")
		case .sendSuccess:
			return String(localized: "Money Sent!")
		case .addressesCopied:
			return String(localized: "Addresses Copied")
		case .sweepSuccess:
			return String(localized: "Successfully imported wallet.")
		// Failure(s)
		case .failedResolution:
			return String(localized: "Resolved")
		}
	}

	var icon: UIView {
		return CheckView()
	}
}

extension AlertType: Equatable {}

func == (lhs: AlertType, rhs: AlertType) -> Bool {
	switch (lhs, rhs) {
	case (.pinSet(_), .pinSet(_)):
		return true
	case (.paperKeySet(_), .paperKeySet(_)):
		return true
	case (.sendSuccess, .sendSuccess):
		return true
	case (.addressesCopied, .addressesCopied):
		return true
	case (.sweepSuccess(_), .sweepSuccess(_)):
		return true
	// Failure(s)
	case (.failedResolution, .failedResolution):
		return true
	default:
		return false
	}
}

class AlertView: UIView, SolidColorDrawable {
	private let type: AlertType
	private let header = UILabel()
	private let subheader = UILabel()
	private let separator = UIView()
	private let icon: UIView
	private let iconSize: CGFloat = 96.0
	private let separatorYOffset: CGFloat = 48.0

	init(type: AlertType) {
		self.type = type
		icon = type.icon
		super.init(frame: .zero)
		layer.cornerRadius = 6.0
		layer.masksToBounds = true
        self.layer.backgroundColor = BrainwalletUIColor.background.cgColor
        self.layer.opacity = 0.95
		setupSubviews()
	}

	func animate() {
		guard let animatableIcon = icon as? AnimatableIcon else { return }
		animatableIcon.animate()
	}

	private func setupSubviews() {
		addSubview(header)
		addSubview(subheader)
		addSubview(icon)
		addSubview(separator)

		setData()
		addConstraints()
	}

	private func setData() {
		header.text = type.header
		header.textAlignment = .center
		header.font = UIFont.barlowBold(size: 18.0)
        header.textColor = BrainwalletUIColor.content

		icon.backgroundColor = .clear
		separator.backgroundColor = BrainwalletUIColor.surface

		subheader.text = type.subheader
		subheader.textAlignment = .center
		subheader.font = UIFont.barlowSemiBold(size: 16.0)
		subheader.textColor = BrainwalletUIColor.content
	}

	private func addConstraints() {
		// NB - In this alert view, constraints shouldn't be pinned to the bottom
		// of the view because the bottom actually extends off the bottom of the screen a bit.
		// It extends so that it still covers up the underlying view when it bounces on screen.

		header.constrainTopCorners(sidePadding: C.padding[2], topPadding: C.padding[2])
		separator.constrain([
			separator.constraint(.height, constant: 1.0),
			separator.constraint(.width, toView: self, constant: 0.0),
			separator.constraint(.top, toView: self, constant: separatorYOffset),
			separator.constraint(.leading, toView: self, constant: nil)
		])
		icon.constrain([
			icon.constraint(.centerX, toView: self, constant: nil),
			icon.constraint(.centerY, toView: self, constant: nil),
			icon.constraint(.width, constant: iconSize),
			icon.constraint(.height, constant: iconSize)
		])
		subheader.constrain([
			subheader.constraint(.leading, toView: self, constant: C.padding[2]),
			subheader.constraint(.trailing, toView: self, constant: -C.padding[2]),
			subheader.constraint(toBottom: icon, constant: C.padding[3])
		])
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
