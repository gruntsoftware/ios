import UIKit

private let buttonSize: CGFloat = 16.0

class SecurityCenterCell: UIControl {
	// MARK: - Public

	var isCheckHighlighted: Bool = false {
		didSet {
            check.tintColor = isCheckHighlighted ? BrainwalletUIColor.affirm : BrainwalletUIColor.gray
		}
	}

	init(title: String, descriptionText: String) {
		super.init(frame: .zero)
		titleLabel.text = title
        check.tintColor = BrainwalletUIColor.affirm
        titleLabel.textColor = BrainwalletUIColor.content
        descriptionLabel.textColor = BrainwalletUIColor.content
        self.backgroundColor = BrainwalletUIColor.surface
		descriptionLabel.text = descriptionText
		setup()
	}

	// MARK: - Private

	private func setup() {
		addSubview(titleLabel)
		addSubview(descriptionLabel)
		addSubview(separator)
		addSubview(check)
		check.constrain([
			check.leadingAnchor.constraint(equalTo: leadingAnchor, constant: C.padding[2]),
			check.topAnchor.constraint(equalTo: topAnchor, constant: C.padding[2]),
			check.widthAnchor.constraint(equalToConstant: buttonSize),
			check.heightAnchor.constraint(equalToConstant: buttonSize)
		])
		titleLabel.constrain([
			titleLabel.leadingAnchor.constraint(equalTo: check.trailingAnchor, constant: C.padding[1]),
			titleLabel.topAnchor.constraint(equalTo: check.topAnchor),
			titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -C.padding[2])
		])
		descriptionLabel.constrain([
			descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
			descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
			descriptionLabel.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor)
		])
		separator.constrain([
			separator.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: C.padding[3]),
			separator.leadingAnchor.constraint(equalTo: check.leadingAnchor),
			separator.trailingAnchor.constraint(equalTo: titleLabel.trailingAnchor),
			separator.heightAnchor.constraint(equalToConstant: 1.0),
			separator.bottomAnchor.constraint(equalTo: bottomAnchor)
		])

		descriptionLabel.numberOfLines = 0
		descriptionLabel.lineBreakMode = .byWordWrapping
		check.setImage(#imageLiteral(resourceName: "CircleCheck"), for: .normal)
		isCheckHighlighted = false
	}

	override var isHighlighted: Bool {
		didSet {
			if isHighlighted {
                backgroundColor = BrainwalletUIColor.affirm
			} else {
                backgroundColor = BrainwalletUIColor.gray
			}
		}
	}

	private var titleLabel = UILabel(font: .customBold(size: 13.0))
	private var descriptionLabel = UILabel(font: .customBody(size: 13.0))
	private var separator = UIView(color: BrainwalletUIColor.gray)
	private var check = UIButton(type: .system)

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
