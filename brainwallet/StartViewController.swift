import UIKit

// TBD Deprecated
class StartViewController: UIViewController {
	// MARK: - Public

	init(store: Store, didTapCreate: @escaping () -> Void, didTapRecover: @escaping () -> Void) {
		self.store = store
		self.didTapRecover = didTapRecover
		self.didTapCreate = didTapCreate
		super.init(nibName: nil, bundle: nil)
	}

	// MARK: - Private

    private let message = UILabel(font: .barlowLight(size: 22), color: BrainwalletUIColor.content)

    private let create = ShadowButton(title: String(localized: "Ready") , type: .flatWhite)
    private let recover = ShadowButton(title: String(localized:  "Restore"), type: .flatLitecoinBlue)
	private let store: Store
	private let didTapRecover: () -> Void
	private let didTapCreate: () -> Void
	private let backgroundView: UIView = {
		let view = UIView()
		view.backgroundColor = BrainwalletUIColor.surface
		return view
	}()

	private var logo: UIImageView = {
		let image = UIImageView(image: UIImage(named: "bw-logotype"))
		image.contentMode = .scaleAspectFit
		image.alpha = 0.8
		return image
	}()

	private let versionLabel = UILabel(font: .barlowMedium(size: 14), color: BrainwalletUIColor.content)

	override func viewDidLoad() {
		view.backgroundColor = BrainwalletUIColor.surface
		setData()
		addSubviews()
		addConstraints()
		addButtonActions()
	}

	private func setData() {
		message.lineBreakMode = .byWordWrapping
		message.numberOfLines = 0
		message.textAlignment = .center
		versionLabel.text = AppVersion.string
		versionLabel.textAlignment = .right
		message.textColor = .white
		versionLabel.textColor = .white

		if #available(iOS 11.0, *) {
			guard let mainColor = UIColor(named: "mainColor")
			else {
				NSLog("ERROR: Custom color not found")
				return
			}
			view.backgroundColor = mainColor
		} else {
			view.backgroundColor = BrainwalletUIColor.surface
		}
	}

	private func addSubviews() {
		view.addSubview(backgroundView)
		view.addSubview(logo)
		view.addSubview(message)
		view.addSubview(create)
		view.addSubview(recover)
		view.addSubview(versionLabel)
	}

	private func addConstraints() {
		backgroundView.constrain(toSuperviewEdges: nil)

		logo.constrain([
			logo.topAnchor.constraint(equalTo: view.centerYAnchor, constant: -120),
			logo.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			logo.constraint(.height, constant: 45),
			logo.constraint(.width, constant: 201)
		])
		message.constrain([
			message.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
			message.topAnchor.constraint(equalTo: logo.bottomAnchor, constant: C.padding[3]),
			message.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50)
		])
		recover.constrain([
			recover.constraint(.leading, toView: view, constant: C.padding[2]),
			recover.constraint(.bottom, toView: view, constant: -60),
			recover.constraint(.trailing, toView: view, constant: -C.padding[2]),
			recover.constraint(.height, constant: C.Sizes.buttonHeight)
		])
		create.constrain([
			create.constraint(toTop: recover, constant: -C.padding[2]),
			create.constraint(.centerX, toView: recover, constant: nil),
			create.constraint(.width, toView: recover, constant: nil),
			create.constraint(.height, constant: C.Sizes.buttonHeight)
		])
		versionLabel.constrain([
			versionLabel.constraint(.top, toView: view, constant: 30),
			versionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
			versionLabel.widthAnchor.constraint(equalToConstant: 120.0),
			versionLabel.heightAnchor.constraint(equalToConstant: 44.0)
		])
	}

	private func addButtonActions() {
		recover.tap = didTapRecover
		create.tap = didTapCreate
	}

	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
