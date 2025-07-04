import LocalAuthentication
import UIKit

enum UpdatePinType {
	case creationNoPhrase
	case creationWithPhrase
	case update
}

class UpdatePinViewController: UIViewController, Subscriber {
	// MARK: - Public

	var setPinSuccess: ((String) -> Void)?
	var resetFromDisabledSuccess: (() -> Void)?
	var resetFromDisabledWillSucceed: (() -> Void)?

	init(store: Store, walletManager: WalletManager, type: UpdatePinType, showsBackButton: Bool = true, phrase: String? = nil) {
		self.store = store
		self.walletManager = walletManager
		self.phrase = phrase
		pinView = PinView(style: .create, length: store.state.pinLength)
		self.showsBackButton = showsBackButton
		self.type = type
		super.init(nibName: nil, bundle: nil)
	}

	// MARK: - Private

	private var header = UILabel.wrapping(font: .customBold(size: 26.0), color: BrainwalletUIColor.content)
	private var instruction = UILabel.wrapping(font: .customBody(size: 14.0), color: BrainwalletUIColor.content)
	private var caption = UILabel.wrapping(font: .customBody(size: 13.0), color: BrainwalletUIColor.content)
	private var pinView: PinView
    private let pinPad = PinPadViewController(style: .clearPinPadStyle, keyboardType: .pinPad, maxDigits: 0)
	private let spacer = UIView()
	private let store: Store
	private let walletManager: WalletManager
	private var step: Step = .verify {
		didSet {
			switch step {
			case .verify:
				instruction.text = isCreatingPin ? String(localized: "Your PIN will be used to unlock your Brainwallet and send money.", bundle: .main) : String(localized: "Enter your current PIN.", bundle: .main)
				caption.isHidden = true
			case .new:
				let instructionText = isCreatingPin ? String(localized: "Your PIN will be used to unlock your Brainwallet and send money.", bundle: .main) : String(localized: "Enter your new PIN.", bundle: .main)
				if instruction.text != instructionText {
					instruction.pushNewText(instructionText)
				}
				header.text = String(localized: "Set PIN", bundle: .main)
				caption.isHidden = false
			case .confirmNew:
				caption.isHidden = true
				if isCreatingPin {
					header.text = String(localized:"Re-Enter PIN", bundle: .main)
				} else {
					instruction.pushNewText( String(localized: "Re-Enter your new PIN.", bundle: .main))
				}
			}
		}
	}

	private var currentPin: String?
	private var newPin: String?
	private var phrase: String?
	private let type: UpdatePinType
	private var isCreatingPin: Bool {
		return type != .update
	}

	private let newPinLength = kPinDigitConstant
	private let showsBackButton: Bool

	private enum Step {
		case verify
		case new
		case confirmNew
	}

	override func viewDidLoad() {
		addSubviews()
		addConstraints()
		setData()
	}

	private func addSubviews() {
		view.addSubview(header)
		view.addSubview(instruction)
		view.addSubview(caption)
		view.addSubview(pinView)
		view.addSubview(spacer)
	}

	private func addConstraints() {
		header.constrain([
			header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: C.padding[2]),
			header.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: C.padding[2]),
			header.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -C.padding[2])
		])
		instruction.constrain([
			instruction.leadingAnchor.constraint(equalTo: header.leadingAnchor),
			instruction.topAnchor.constraint(equalTo: header.bottomAnchor, constant: C.padding[2]),
			instruction.trailingAnchor.constraint(equalTo: header.trailingAnchor)
		])
		pinView.constrain([
			pinView.centerYAnchor.constraint(equalTo: spacer.centerYAnchor),
			pinView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			pinView.widthAnchor.constraint(equalToConstant: pinView.width),
			pinView.heightAnchor.constraint(equalToConstant: pinView.itemSize)
		])

		addChildViewController(pinPad, layout: {
			pinPad.view.constrainBottomCorners(sidePadding: 0.0, bottomPadding: 0.0)
			pinPad.view.constrain([
				pinPad.view.heightAnchor.constraint(equalToConstant: pinPad.height),
				pinPad.view.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -C.padding[3])
			])
		})
		spacer.constrain([
			spacer.topAnchor.constraint(equalTo: instruction.bottomAnchor),
			spacer.bottomAnchor.constraint(equalTo: caption.topAnchor)
		])
		caption.constrain([
			caption.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: C.padding[2]),
			caption.bottomAnchor.constraint(equalTo: pinPad.view.topAnchor, constant: -C.padding[2]),
			caption.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -C.padding[2])
		])
	}

	private func setData() {
		caption.text = String(localized: "Remember this PIN. If you forget it, you won't be able to access your Litecoin.", bundle: .main)
		view.addSubview(spacer)

		header.textColor = BrainwalletUIColor.content
		instruction.textColor = BrainwalletUIColor.content
		caption.textColor = BrainwalletUIColor.content
        view.backgroundColor = BrainwalletUIColor.surface
		header.text = isCreatingPin ? String(localized: "Set PIN", bundle: .main) : String(localized: "Update PIN", bundle: .main)
		instruction.text = isCreatingPin ? String(localized: "Your PIN will be used to unlock your Brainwallet and send money.", bundle: .main) : String(localized: "Enter your current PIN.", bundle: .main)

		pinPad.ouputDidUpdate = { [weak self] text in
			guard let step = self?.step else { return }
			switch step {
			case .verify:
				self?.didUpdateForCurrent(pin: text)
			case .new:
				self?.didUpdateForNew(pin: text)
			case .confirmNew:
				self?.didUpdateForConfirmNew(pin: text)
			}
		}

		if isCreatingPin {
			step = .new
			caption.isHidden = false
		} else {
			caption.isHidden = true
		}

		if !showsBackButton {
			navigationItem.leftBarButtonItem = nil
			navigationItem.hidesBackButton = true
		}
	}

	private func didUpdateForCurrent(pin: String) {
		pinView.fill(pin.utf8.count)
		if pin.utf8.count == store.state.pinLength {
			if walletManager.authenticate(pin: pin) {
				pushNewStep(.new)
				currentPin = pin
				replacePinView()
			} else {
				if walletManager.walletDisabledUntil > 0 {
					dismiss(animated: true, completion: {
						self.store.perform(action: RequireLogin())
					})
				} else {
					clearAfterFailure()
				}
			}
		}
	}

	private func didUpdateForNew(pin: String) {
		pinView.fill(pin.utf8.count)
		if pin.utf8.count == newPinLength {
			newPin = pin
			pushNewStep(.confirmNew)
		}
	}

	private func didUpdateForConfirmNew(pin: String) {
		guard let newPin = newPin else { return }
		pinView.fill(pin.utf8.count)
		if pin.utf8.count == newPinLength {
			if pin == newPin {
				didSetNewPin()
			} else {
				clearAfterFailure()
				pushNewStep(.new)
			}
		}
	}

	private func clearAfterFailure() {
		pinPad.view.isUserInteractionEnabled = false
		pinView.shake { [weak self] in
			self?.pinPad.view.isUserInteractionEnabled = true
			self?.pinView.fill(0)
		}
		pinPad.clear()
	}

	private func replacePinView() {
		pinView.removeFromSuperview()
		pinView = PinView(style: .create, length: newPinLength)
		view.addSubview(pinView)
		pinView.constrain([
			pinView.centerYAnchor.constraint(equalTo: spacer.centerYAnchor),
			pinView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			pinView.widthAnchor.constraint(equalToConstant: pinView.width),
			pinView.heightAnchor.constraint(equalToConstant: pinView.itemSize)
		])
	}

	private func pushNewStep(_ newStep: Step) {
		step = newStep
		pinPad.clear()
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
			self?.pinView.fill(0)
		}
	}

	private func didSetNewPin() {
		DispatchQueue.walletQueue.async { [weak self] in
			guard let newPin = self?.newPin else { return }
			var success: Bool? = false
			if let seedPhrase = self?.phrase {
				success = self?.walletManager.forceSetPin(newPin: newPin, seedPhrase: seedPhrase)
			} else if let currentPin = self?.currentPin {
				success = self?.walletManager.changePin(newPin: newPin, pin: currentPin)
				DispatchQueue.main.async { self?.store.trigger(name: .didUpgradePin) }
			} else if self?.type == .creationNoPhrase {
				success = self?.walletManager.forceSetPin(newPin: newPin)
			}

			DispatchQueue.main.async {
				if let success = success, success == true {
					if self?.resetFromDisabledSuccess != nil {
						self?.resetFromDisabledWillSucceed?()
						self?.store.perform(action: SimpleReduxAlert.Show(.pinSet(callback: { [weak self] in
							self?.dismiss(animated: true, completion: {
								self?.resetFromDisabledSuccess?()
							})
						})))
					} else {
						self?.store.perform(action: SimpleReduxAlert.Show(.pinSet(callback: { [weak self] in
							self?.setPinSuccess?(newPin)
							if self?.type != .creationNoPhrase {
								self?.parent?.dismiss(animated: true, completion: nil)
							}
						})))
					}
				} else {
					let alert = UIAlertController(title: "Update PIN" , message: "Update PIN Error" , preferredStyle: .alert)
					alert.addAction(UIAlertAction(title: "Ok" , style: .default, handler: { [weak self] _ in
						self?.clearAfterFailure()
						self?.pushNewStep(.new)
					}))
					self?.present(alert, animated: true, completion: nil)
				}
			}
		}
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
