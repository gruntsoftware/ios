import UIKit

class ShareDataViewController: UIViewController {
	init(store: Store) {
		self.store = store
		super.init(nibName: nil, bundle: nil)
	}

	private let store: Store
	private let titleLabel = UILabel(font: .customBold(size: 26.0), color: BrainwalletUIColor.content)
	private let body = UILabel.wrapping(font: .customBody(size: 16.0), color: BrainwalletUIColor.content)
	private let label = UILabel(font: .customBold(size: 16.0), color: BrainwalletUIColor.content)
	private let toggle = UISwitch()
	private let separator = UIView(color: BrainwalletUIColor.content)

	override func viewDidLoad() {
		addSubviews()
		addConstraints()
		setInitialData()
	}

	private func addSubviews() {
		view.addSubview(titleLabel)
		view.addSubview(body)
		view.addSubview(label)
		view.addSubview(toggle)
		view.addSubview(separator)
	}

	private func addConstraints() {
		titleLabel.constrain([
			titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: C.padding[2]),
			titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: C.padding[2])
		])
		body.constrain([
			body.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor),
			body.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: C.padding[1]),
			body.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -C.padding[2])
		])
		label.constrain([
			label.leadingAnchor.constraint(equalTo: body.leadingAnchor),
			label.topAnchor.constraint(equalTo: body.bottomAnchor, constant: C.padding[3])
		])
		toggle.constrain([
			toggle.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -C.padding[2]),
			toggle.centerYAnchor.constraint(equalTo: label.centerYAnchor)
		])
		separator.constrain([
			separator.leadingAnchor.constraint(equalTo: label.leadingAnchor),
			separator.topAnchor.constraint(equalTo: toggle.bottomAnchor, constant: C.padding[2]),
			separator.trailingAnchor.constraint(equalTo: toggle.trailingAnchor),
			separator.heightAnchor.constraint(equalToConstant: 1.0)
		])
	}

	private func setInitialData() {
        view.backgroundColor = BrainwalletUIColor.background
		titleLabel.text = String(localized: "Share data?", bundle: .main)
		body.text = String(localized: "Help improve Brainwallet by sharing your anonymous data with us to improve the app. We respect your privacy.", bundle: .main)
		label.text = String(localized: "Share anonymous data?", bundle: .main)

		if UserDefaults.hasAquiredShareDataPermission {
			toggle.isOn = true
			toggle.sendActions(for: .valueChanged)
		}

		toggle.valueChanged = strongify(self) { myself in
			UserDefaults.hasAquiredShareDataPermission = myself.toggle.isOn
			if myself.toggle.isOn {
				myself.store.trigger(name: .didEnableShareData)
			}
		}
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
