import UIKit

enum ButtonType {
	case primary
	case secondary
	case tertiary
	case blackTransparent
	case search
	case warning
	case boldWarning
	case flatWhite
	case flatWhiteBorder
	case flatLitecoinBlue
}

let minTargetSize: CGFloat = 48.0

class ShadowButton: UIControl {
	init(title: String, type: ButtonType) {
		self.title = title
		self.type = type
		super.init(frame: .zero)
		accessibilityLabel = title
		setupViews()
	}

	init(title: String, type: ButtonType, image: UIImage) {
		self.title = title
		self.type = type
		self.image = image
		super.init(frame: .zero)
		accessibilityLabel = title
		setupViews()
	}

	var isToggleable = false
	var title: String {
		didSet {
			label.text = title
		}
	}

	var image: UIImage? {
		didSet {
			imageView?.image = image
		}
	}

	private let type: ButtonType
	private let container = UIView()
	private let shadowView = UIView()
	private let label = UILabel()
	private let cornerRadius: CGFloat = 4.0
	private var imageView: UIImageView?

	override var isHighlighted: Bool {
		didSet {
			if isHighlighted {
				UIView.animate(withDuration: 0.04, animations: {
					let shrink = CATransform3DMakeScale(0.97, 0.97, 1.0)
					let translate = CATransform3DTranslate(shrink, 0, 4.0, 0)
					self.container.layer.transform = translate
				})
			} else {
				UIView.animate(withDuration: 0.04, animations: {
					self.container.transform = CGAffineTransform.identity
				})
			}
		}
	}

	override var isSelected: Bool {
		didSet {
			guard isToggleable else { return }
			if type == .tertiary || type == .search {
				if isSelected {
                    container.layer.borderColor = BrainwalletUIColor.border.cgColor
					imageView?.tintColor = BrainwalletUIColor.info
                    label.textColor = BrainwalletUIColor.content
				} else {
					setColors()
				}
			}
		}
	}

	private func setupViews() {
		addShadowView()
		addContent()
		setColors()
		addTarget(self, action: #selector(ShadowButton.touchUpInside), for: .touchUpInside)
		setContentCompressionResistancePriority(UILayoutPriority.required, for: .horizontal)
		label.setContentCompressionResistancePriority(UILayoutPriority.required, for: .horizontal)
		setContentHuggingPriority(UILayoutPriority.required, for: .horizontal)
		label.setContentHuggingPriority(UILayoutPriority.required, for: .horizontal)
	}

	private func addShadowView() {
		addSubview(shadowView)
		shadowView.constrain([
			NSLayoutConstraint(item: shadowView, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 0.5, constant: 0.0),
			shadowView.constraint(.bottom, toView: self),
			shadowView.constraint(.centerX, toView: self),
			NSLayoutConstraint(item: shadowView, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 0.8, constant: 0.0),
		])
		shadowView.layer.cornerRadius = 4.0
		shadowView.layer.shadowOffset = CGSize(width: 0, height: 4)
		shadowView.backgroundColor = BrainwalletUIColor.surface
		shadowView.isUserInteractionEnabled = false
	}

	private func addContent() {
		addSubview(container)
		container.backgroundColor = BrainwalletUIColor.surface
		container.layer.cornerRadius = cornerRadius
		container.isUserInteractionEnabled = false
		container.constrain(toSuperviewEdges: nil)
		label.text = title
        label.textColor = BrainwalletUIColor.content
		label.textAlignment = .center
		label.isUserInteractionEnabled = false
		label.font = UIFont.customMedium(size: 16.0)
		configureContentType()
	}

	private func configureContentType() {
		if let icon = image {
			setupImageOption(icon: icon)
		} else {
			setupLabelOnly()
		}
	}

	private func setupImageOption(icon: UIImage) {
		let content = UIView()
		let iconImageView = UIImageView(image: icon.withRenderingMode(.alwaysTemplate))
		iconImageView.contentMode = .scaleAspectFit
		container.addSubview(content)
		content.addSubview(label)
		content.addSubview(iconImageView)
		content.constrainToCenter()
		iconImageView.constrainLeadingCorners()
		label.constrainTrailingCorners()
		iconImageView.constrain([
			iconImageView.constraint(toLeading: label, constant: -C.padding[1]),
		])
		imageView = iconImageView
	}

	private func setupLabelOnly() {
		container.addSubview(label)
		label.constrain(toSuperviewEdges: UIEdgeInsets(top: C.padding[1], left: C.padding[1], bottom: -C.padding[1], right: -C.padding[1]))
	}

	private func setColors() {
		switch type {
		case .flatLitecoinBlue:
                container.backgroundColor = BrainwalletUIColor.surface
            label.textColor = BrainwalletUIColor.content
            container.layer.borderColor = BrainwalletUIColor.border.cgColor
			container.layer.borderWidth = 1.0
			imageView?.tintColor = .white
            shadowView.layer.shadowColor = BrainwalletUIColor.background.cgColor
			shadowView.layer.shadowOpacity = 0.15
		case .flatWhite:
			container.backgroundColor = BrainwalletUIColor.surface
			label.textColor = BrainwalletUIColor.surface
			container.layer.borderColor = nil
			container.layer.borderWidth = 0.0
			imageView?.tintColor = BrainwalletUIColor.surface
		case .flatWhiteBorder:
			container.backgroundColor = BrainwalletUIColor.surface
			label.textColor = BrainwalletUIColor.surface
            container.layer.borderColor = BrainwalletUIColor.content.cgColor
			container.layer.borderWidth = 1.0
			imageView?.tintColor = BrainwalletUIColor.surface
		case .primary:
			container.backgroundColor = BrainwalletUIColor.info
			label.textColor = BrainwalletUIColor.content
			container.layer.borderColor = nil
			container.layer.borderWidth = 0.0
            shadowView.layer.shadowColor = BrainwalletUIColor.border.cgColor
			shadowView.layer.shadowOpacity = 0.3
			imageView?.tintColor = .white
		case .secondary:
			container.backgroundColor = BrainwalletUIColor.background
			label.textColor = BrainwalletUIColor.content
            container.layer.borderColor = BrainwalletUIColor.border.cgColor
			container.layer.borderWidth = 1.0
            shadowView.layer.shadowColor = BrainwalletUIColor.nearBlack.cgColor
			shadowView.layer.shadowOpacity = 0.15
			imageView?.tintColor = BrainwalletUIColor.content
		case .tertiary:
			container.backgroundColor = BrainwalletUIColor.background
			label.textColor = BrainwalletUIColor.content
			container.layer.borderColor = BrainwalletUIColor.border.cgColor
			container.layer.borderWidth = 1.0
			shadowView.layer.shadowColor = BrainwalletUIColor.nearBlack.cgColor
			shadowView.layer.shadowOpacity = 0.15
			imageView?.tintColor = BrainwalletUIColor.content
		case .blackTransparent:
			container.backgroundColor = .clear
			label.textColor = BrainwalletUIColor.content
			container.layer.borderColor = BrainwalletUIColor.border.cgColor
			container.layer.borderWidth = 1.0
			imageView?.tintColor = BrainwalletUIColor.content
			shadowView.isHidden = true
		case .search:
			label.font = UIFont.customBody(size: 13.0)
			container.backgroundColor = BrainwalletUIColor.background
			label.textColor = BrainwalletUIColor.content
			container.layer.borderColor = BrainwalletUIColor.content.cgColor
			container.layer.borderWidth = 1.0
            shadowView.layer.shadowColor = BrainwalletUIColor.nearBlack.cgColor
			shadowView.layer.shadowOpacity = 0.15
			imageView?.tintColor = BrainwalletUIColor.content
		case .warning:
			label.font = UIFont.customBody(size: 13.0)
            container.backgroundColor = BrainwalletUIColor.surface
            label.textColor = BrainwalletUIColor.content
			container.layer.borderColor =  BrainwalletUIColor.content.cgColor
			container.layer.borderWidth = 1.0
            shadowView.layer.shadowColor = BrainwalletUIColor.nearBlack.cgColor
			shadowView.layer.shadowOpacity = 0.15
		case .boldWarning:
			label.font = UIFont.customBold(size: 15.0)
            container.backgroundColor = BrainwalletUIColor.surface
            label.textColor = BrainwalletUIColor.error
			container.layer.borderColor = BrainwalletUIColor.border.cgColor
			container.layer.borderWidth = 1.0
            shadowView.layer.shadowColor = BrainwalletUIColor.gray.cgColor
			shadowView.layer.shadowOpacity = 0.15
		}
	}

	override open func hitTest(_ point: CGPoint, with _: UIEvent?) -> UIView? {
		guard !isHidden || isUserInteractionEnabled else { return nil }
		let deltaX = max(minTargetSize - bounds.width, 0)
		let deltaY = max(minTargetSize - bounds.height, 0)
		let hitFrame = bounds.insetBy(dx: -deltaX / 2.0, dy: -deltaY / 2.0)
		return hitFrame.contains(point) ? self : nil
	}

	@objc private func touchUpInside() {
		isSelected = !isSelected
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
