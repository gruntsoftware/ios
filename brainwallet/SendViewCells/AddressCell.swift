import UIKit

class AddressCell: UIView {
	init() {
		super.init(frame: .zero)
        self.backgroundColor = BrainwalletUIColor.surface
		setupViews()
	}

	var address: String? {
		return textField.text
	}

	var didBeginEditing: (() -> Void)?
	var didEndEditing: (() -> Void)?
	var didReceivePaymentRequest: ((PaymentRequest) -> Void)?

	let textField = UITextField()
	let paste = ShadowButton(title: String(localized: "Paste") , type: .tertiary)
	let scan = ShadowButton(title: String(localized: "Scan") , type: .tertiary)
	private let dividerView = UIView(color: BrainwalletUIColor.border)

	private func setupViews() {
        textField.textColor = BrainwalletUIColor.content
		addSubviews()
		addConstraints()
		setInitialData()
	}

	private func addSubviews() {
		addSubview(textField)
		addSubview(dividerView)
		addSubview(paste)
		addSubview(scan)
	}

	private func addConstraints() {
		textField.constrain([
			textField.constraint(.leading, toView: self, constant: 11.0),
			textField.constraint(.centerY, toView: self),
			textField.trailingAnchor.constraint(equalTo: paste.leadingAnchor, constant: -C.padding[1])
		])
		scan.constrain([
			scan.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -C.padding[2]),
			scan.centerYAnchor.constraint(equalTo: centerYAnchor)
		])
		paste.constrain([
			paste.centerYAnchor.constraint(equalTo: centerYAnchor),
			paste.trailingAnchor.constraint(equalTo: scan.leadingAnchor, constant: -C.padding[0.625])
		])
		dividerView.constrain([
			dividerView.leadingAnchor.constraint(equalTo: leadingAnchor),
			dividerView.bottomAnchor.constraint(equalTo: bottomAnchor),
			dividerView.trailingAnchor.constraint(equalTo: trailingAnchor),
			dividerView.heightAnchor.constraint(equalToConstant: 1.0)
		])
	}

	private func setInitialData() {
		textField.font = .customBody(size: 15.0)
		textField.adjustsFontSizeToFitWidth = true
		textField.minimumFontSize = 10.0
		textField.placeholder = "Enter LTC Address"
		textField.returnKeyType = .done
		textField.delegate = self
		textField.clearButtonMode = .whileEditing
	}

	@objc private func didTap() {
		textField.becomeFirstResponder()
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

extension AddressCell: UITextFieldDelegate {
	func textFieldDidBeginEditing(_: UITextField) {
		didBeginEditing?()
	}

	func textFieldDidEndEditing(_: UITextField) {
		didEndEditing?()
	}

	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}

	func textField(_: UITextField, shouldChangeCharactersIn _: NSRange, replacementString string: String) -> Bool {
		if let request = PaymentRequest(string: string) {
			didReceivePaymentRequest?(request)
			return false
		} else {
			return true
		}
	}
}
