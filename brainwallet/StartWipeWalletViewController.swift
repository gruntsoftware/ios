import UIKit

class StartWipeWalletViewController: UIViewController {
	init(didTapNext: @escaping () -> Void) {
		self.didTapNext = didTapNext
		super.init(nibName: nil, bundle: nil)
	}

	private let didTapNext: () -> Void
    private let header = RadialGradientView(backgroundColor: BrainwalletUIColor.info, offset: 64.0)
	private let illustration = UIImageView(image: #imageLiteral(resourceName: "RestoreIllustration"))
	private let message = UILabel.wrapping(font: .customBody(size: 16.0), color: BrainwalletUIColor.content)
	private let warning = UILabel.wrapping(font: .customBody(size: 16.0), color: BrainwalletUIColor.content)
	private let button = ShadowButton(title: "Next" , type: .primary)
	private let bullet = UIImageView(image: #imageLiteral(resourceName: "deletecircle"))

	override func viewDidLoad() {
		addSubviews()
		addConstraints()
		setInitialData()
	}

	private func addSubviews() {
		view.addSubview(header)
		header.addSubview(illustration)
		view.addSubview(message)
		view.addSubview(warning)
		view.addSubview(bullet)
		view.addSubview(button)
	}

	private func addConstraints() {
		header.constrainTopCorners(sidePadding: 0, topPadding: 0)
		header.constrain([
			header.constraint(.height, constant: 220.0),
		])
		illustration.constrain([
			illustration.constraint(.width, constant: 64.0),
			illustration.constraint(.height, constant: 84.0),
			illustration.constraint(.centerX, toView: header, constant: 0.0),
			illustration.constraint(.centerY, toView: header, constant: C.padding[3]),
		])
		message.constrain([
			message.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: C.padding[2]),
			message.topAnchor.constraint(equalTo: header.bottomAnchor, constant: C.padding[2]),
			message.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -C.padding[2]),
		])
		bullet.constrain([
			bullet.leadingAnchor.constraint(equalTo: message.leadingAnchor),
			bullet.topAnchor.constraint(equalTo: message.bottomAnchor, constant: C.padding[4]),
			bullet.widthAnchor.constraint(equalToConstant: 16.0),
			bullet.heightAnchor.constraint(equalToConstant: 16.0),
		])
		warning.constrain([
			warning.leadingAnchor.constraint(equalTo: bullet.trailingAnchor, constant: C.padding[2]),
			warning.topAnchor.constraint(equalTo: bullet.topAnchor, constant: 0.0),
			warning.trailingAnchor.constraint(equalTo: message.trailingAnchor),
		])
		button.constrain([
			button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: C.padding[3]),
			button.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -C.padding[4]),
			button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -C.padding[3]),
			button.constraint(.height, constant: C.Sizes.buttonHeight),
		])
	}

	private func setInitialData() {
		view.backgroundColor = BrainwalletUIColor.surface
		illustration.contentMode = .scaleAspectFill
		message.text = "Starting or recovering another wallet allows you to access and manage a different Brainwallet wallet on this device." 
		warning.text = "Your current wallet will be removed from this device. If you wish to restore it in the future, you will need to enter your Paper Key." 
		button.tap = { [weak self] in
			self?.didTapNext()
		}
	}

	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
