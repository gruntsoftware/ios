import UIKit

class MenuButton: UIControl {
	// MARK: - Public

	let type: MenuButtonType

	init(type: MenuButtonType) {
		self.type = type
		super.init(frame: .zero)

        label.textColor = BrainwalletUIColor.content
        self.backgroundColor = BrainwalletUIColor.surface
        image.tintColor = BrainwalletUIColor.background

		setupViews()
	}

	// MARK: - Private

	private let label = UILabel(font: .customBody(size: 16.0))
	private let image = UIImageView()
	private let border = UIView()

	override var isHighlighted: Bool {
		didSet {
			if isHighlighted {
				backgroundColor = BrainwalletUIColor.content
			} else {
				backgroundColor = BrainwalletUIColor.surface
			}
		}
	}

	private func setupViews() {
		addSubview(label)
		addSubview(image)
		addSubview(border)

		label.constrain([
			label.constraint(.centerY, toView: self, constant: 0.0),
			label.constraint(.leading, toView: self, constant: C.padding[2]),
		])
		image.constrain([
			image.constraint(.centerY, toView: self, constant: 0.0),
			image.constraint(.trailing, toView: self, constant: -C.padding[4]),
			image.constraint(.width, constant: 16.0),
			image.constraint(.height, constant: 16.0),
		])
		border.constrainBottomCorners(sidePadding: 0, bottomPadding: 0)
		border.constrain([
			border.constraint(.height, constant: 1.0),
		])

		label.text = type.title
		image.image = type.image
		image.contentMode = .scaleAspectFit
		border.backgroundColor = BrainwalletUIColor.border
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
