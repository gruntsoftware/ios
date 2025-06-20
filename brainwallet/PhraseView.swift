import UIKit

class PhraseView: UIView {
	private let phrase: String
	private let label = UILabel()

	static let defaultSize = CGSize(width: 200, height: 88.0)

	var xConstraint: NSLayoutConstraint?

	init(phrase: String) {
		self.phrase = phrase
		super.init(frame: CGRect())
		setupSubviews()
	}

	private func setupSubviews() {
		addSubview(label)
		label.constrainToCenter()
        label.textColor = BrainwalletUIColor.content
		label.adjustsFontSizeToFitWidth = true
		label.text = phrase
        label.font = UIFont.barlowSemiBold(size: 30.0)
        backgroundColor =  BrainwalletUIColor.surface
		layer.cornerRadius = 10.0
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
