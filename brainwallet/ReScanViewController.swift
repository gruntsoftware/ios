import UIKit

class ReScanViewController: UIViewController, Subscriber {
	init(store: Store) {
		self.store = store
		super.init(nibName: nil, bundle: nil)
	}

	private let header = UILabel(font: .customBold(size: 26.0), color: BrainwalletUIColor.content)
	private let body = UILabel.wrapping(font: .systemFont(ofSize: 15.0))
	private let button = ShadowButton(title: "Start Sync" , type: .primary)
	private let footer = UILabel.wrapping(font: .customBody(size: 16.0), color: BrainwalletUIColor.content)
	private let store: Store

	deinit {
		store.unsubscribe(self)
	}

	override func viewDidLoad() {
		addSubviews()
		addConstraints()
		setInitialData()
	}

	private func addSubviews() {
		view.addSubview(header)
		view.addSubview(body)
		view.addSubview(button)
		view.addSubview(footer)
	}

	private func addConstraints() {
		header.constrain([
			header.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: C.padding[2]),
			header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: C.padding[2]),
			header.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: C.padding[-2])
		])
		body.constrain([
			body.leadingAnchor.constraint(equalTo: header.leadingAnchor),
			body.topAnchor.constraint(equalTo: header.bottomAnchor, constant: C.padding[2]),
			body.trailingAnchor.constraint(equalTo: header.trailingAnchor)
		])
		footer.constrain([
			footer.leadingAnchor.constraint(equalTo: header.leadingAnchor),
			footer.trailingAnchor.constraint(equalTo: header.trailingAnchor),
			footer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -C.padding[3])
		])
		button.constrain([
			button.leadingAnchor.constraint(equalTo: footer.leadingAnchor),
			button.trailingAnchor.constraint(equalTo: footer.trailingAnchor),
			button.bottomAnchor.constraint(equalTo: footer.topAnchor, constant: -C.padding[2]),
			button.heightAnchor.constraint(equalToConstant: C.Sizes.buttonHeight)
		])
	}

	private func setInitialData() {
		view.backgroundColor = BrainwalletUIColor.content
		header.text = String(localized: "Sync Blockchain", bundle: .main)
		body.attributedText = bodyText
		footer.text = String(localized: "You will not be able to send money while syncing with the blockchain.", bundle: .main)
		button.tap = { [weak self] in
			self?.presentRescanAlert()
		}
	}

	private func presentRescanAlert() {
		let alert = UIAlertController(title: String(localized:  "Sync with Blockchain?", bundle: .main), message: String(localized: "You will not be able to send money while syncing.", bundle: .main), preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: String(localized: "Cancel", bundle: .main), style: .default, handler: nil))
		alert.addAction(UIAlertAction(title:String(localized: "Sync", bundle: .main) , style: .default, handler: { [weak self] _ in
			self?.store.trigger(name: .rescan)
			LWAnalytics.logEventWithParameters(itemName: ._20200112_DSR)

			self?.dismiss(animated: true, completion: nil)
		}))
		present(alert, animated: true, completion: nil)
	}

	private var bodyText: NSAttributedString {
		let body = NSMutableAttributedString()
		let headerAttributes = [NSAttributedString.Key.font: UIFont.customBold(size: 16.0),
		                        NSAttributedString.Key.foregroundColor: BrainwalletUIColor.content]
		let bodyAttributes = [NSAttributedString.Key.font: UIFont.customBody(size: 16.0),
		                      NSAttributedString.Key.foregroundColor: BrainwalletUIColor.content]

		body.append(NSAttributedString(string: "Estimated time\n", attributes: headerAttributes))
		body.append(NSAttributedString(string: "20-45 minutes\n\n", attributes: bodyAttributes))
		body.append(NSAttributedString(string: "When to Sync?\n", attributes: headerAttributes))
		body.append(NSAttributedString(string: "If a transaction shows as completed on the Litecoin network but not in your Brainwallet.\n\nYou repeatedly get an error saying your transaction was rejected.", attributes: bodyAttributes))
		return body
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
