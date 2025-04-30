import UIKit

private let progressHeight: CGFloat = 4.0
private let progressWidth: CGFloat = 150.0

class LoadingProgressView: UIView, GradientDrawable {
	var progress: Double = 0.0 {
		didSet {
			progressWidthConstraint?.constant = CGFloat(progress) * progressWidth
		}
	}

	init() {
		super.init(frame: .zero)
	}

	private var hasSetup = false

    private lazy var progressBackground: UIView = self.makeProgressView(backgroundColor: BrainwalletUIColor.surface)
    private lazy var progressForeground: UIView = self.makeProgressView(backgroundColor: BrainwalletUIColor.content)

	private func makeProgressView(backgroundColor: UIColor) -> UIView {
		let view = UIView()
		view.layer.cornerRadius = progressHeight / 2.0
		view.layer.masksToBounds = true
		view.backgroundColor = backgroundColor
		return view
	}

	private let label = UILabel(font: .customBold(size: 14.0))
	private let shadowView = UIView()
	private var progressWidthConstraint: NSLayoutConstraint?

	private func setupView() {
		label.textColor = BrainwalletUIColor.content
        label.text = S.Account.loadingMessage.localize()
		label.textAlignment = .center

		addSubview(label)
		addSubview(progressBackground)
		addSubview(shadowView)

		label.constrain([
			label.centerXAnchor.constraint(equalTo: centerXAnchor),
			label.bottomAnchor.constraint(equalTo: progressBackground.topAnchor, constant: -4.0),
		])
		progressBackground.constrain([
			progressBackground.centerXAnchor.constraint(equalTo: centerXAnchor),
			progressBackground.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -C.padding[1]),
			progressBackground.heightAnchor.constraint(equalToConstant: progressHeight),
			progressBackground.widthAnchor.constraint(equalToConstant: progressWidth),
		])
		progressBackground.addSubview(progressForeground)
		progressWidthConstraint = progressForeground.widthAnchor.constraint(equalToConstant: 0.0)
		progressForeground.constrain([
			progressWidthConstraint,
			progressForeground.leadingAnchor.constraint(equalTo: progressBackground.leadingAnchor),
			progressForeground.heightAnchor.constraint(equalTo: progressBackground.heightAnchor),
			progressForeground.centerYAnchor.constraint(equalTo: progressBackground.centerYAnchor),
		])
		shadowView.backgroundColor = BrainwalletUIColor.background
		shadowView.constrainTopCorners(height: 0.5)
	}

	override func layoutSubviews() {
		if !hasSetup {
			setupView()
			hasSetup = true
		}
		addBottomCorners()
	}

	private func addBottomCorners() {
		let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: [.bottomLeft, .bottomRight], cornerRadii: CGSize(width: 6.0, height: 6.0)).cgPath
		let maskLayer = CAShapeLayer()
		maskLayer.path = path
		layer.mask = maskLayer
	}

	override func draw(_ rect: CGRect) {
		drawGradient(rect)
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
