import UIKit

private let currencyToggleButtonConstant: CGFloat = 20.0
private let amountFont: UIFont = .barlowMedium(size: 24.0)
class AmountViewController: UIViewController, Trackable {
	private let store: Store
	private let isPinPadExpandedAtLaunch: Bool
	private let isRequesting: Bool
	var minimumFractionDigits = 2
	private var hasTrailingDecimal = false
	private var pinPadHeight: NSLayoutConstraint?
	private var feeSelectorHeight: NSLayoutConstraint?
	private var feeSelectorTop: NSLayoutConstraint?
    private var placeholder = PaddingLabel(font: amountFont, color: BrainwalletUIColor.gray)
	private var amountLabel = UILabel(font: amountFont, color: BrainwalletUIColor.content)
	private let pinPad: PinPadViewController
	private let currencyToggleButton: ShadowButton
	private let border = UIView(color: BrainwalletUIColor.border)
    private let bottomBorder = UIView(color: BrainwalletUIColor.surface)
    private let cursor = BlinkingView(blinkColor: BrainwalletUIColor.affirm)
	private let balanceLabel = UILabel()
	private let feesLabel = UILabel()
	private let feeContainer = InViewAlert(type: .secondary)
	private let tapView = UIView()
	private let editFee = UIButton(type: .system)
	private let feeSelector: FeeSelector

	private var amount: Satoshis? {
		didSet {
			updateAmountLabel()
			updateBalanceLabel()
			didUpdateAmount?(amount)
		}
	}

	var balanceTextForAmount: ((Satoshis?, Rate?) -> (NSAttributedString?, NSAttributedString?)?)?
	var didUpdateAmount: ((Satoshis?) -> Void)?
	var didChangeFirstResponder: ((Bool) -> Void)?
	var didShowFiat: ((_ isShowingFiat: Bool) -> Void)?

	var currentOutput: String {
		return amountLabel.text ?? ""
	}

	var selectedRate: Rate? {
		didSet {
			fullRefresh()
		}
	}

	var didUpdateFee: ((FeeType) -> Void)? {
		didSet {
			feeSelector.didUpdateFee = didUpdateFee
		}
	}

	init(store: Store,
	     isPinPadExpandedAtLaunch: Bool,
	     hasAcceptedFees _: Bool,
	     isRequesting: Bool = false) {
		self.store = store
		self.isPinPadExpandedAtLaunch = isPinPadExpandedAtLaunch
		self.isRequesting = isRequesting
        
        var currencyButtonTitle = ""
          
        switch  store.state.maxDigits {
            case 2: currencyButtonTitle = "photons (mł)"
            case 5: currencyButtonTitle = "lites (ł)"
            case 8: currencyButtonTitle = "LTC (Ł)"
            default: currencyButtonTitle = "lites (ł)"
        }
         
		if let rate = store.state.currentRate, store.state.isLtcSwapped {
			currencyToggleButton = ShadowButton(title: "\(rate.code)(\(rate.currencySymbol))", type: .tertiary)
		} else {

            currencyToggleButton = ShadowButton(title: currencyButtonTitle, type: .tertiary)
		}
		feeSelector = FeeSelector(store: store)
        pinPad = PinPadViewController(style: .whitePinPadStyle, keyboardType: .decimalPad, maxDigits: store.state.maxDigits)
		super.init(nibName: nil, bundle: nil)
	}
    
    func setCurrencyButton() {
        
    }

	func forceUpdateAmount(amount: Satoshis) {
		self.amount = amount
		fullRefresh()
	}

	func expandPinPad() {
		if pinPadHeight?.constant == 0.0 {
			togglePinPad()
		}
	}

	override func viewDidLoad() {
	
		placeholder.textColor = BrainwalletUIColor.gray
        amountLabel.textColor = BrainwalletUIColor.content

		addSubviews()
		addConstraints()
		setInitialData()
	}
    
    private func currencyButtonTitle(maxDigits: Int) -> String {
        switch maxDigits {
            case 2:
                return "photons (mł)"
            case 5:
                return "lites (ł)"
            case 8:
                return "LTC (Ł)"
            default:
                return "lites (ł)"
        }
    }

	private func addSubviews() {
		view.addSubview(placeholder)
		view.addSubview(currencyToggleButton)
		view.addSubview(feeContainer)
		view.addSubview(border)
		view.addSubview(cursor)
		view.addSubview(balanceLabel)
		view.addSubview(feesLabel)
		view.addSubview(tapView)
		view.addSubview(amountLabel)
		view.addSubview(bottomBorder)
		view.addSubview(editFee)
	}

	private func addConstraints() {
		amountLabel.constrain([
			amountLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: swiftUICellPadding),
			amountLabel.centerYAnchor.constraint(equalTo: currencyToggleButton.centerYAnchor),
			amountLabel.heightAnchor.constraint(equalToConstant: 44.0)
		])

		placeholder.constrain([
			placeholder.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: swiftUICellPadding),
			placeholder.centerYAnchor.constraint(equalTo: amountLabel.centerYAnchor),
			placeholder.heightAnchor.constraint(equalToConstant: 44.0)
		])
		cursor.constrain([
			cursor.leadingAnchor.constraint(equalTo: amountLabel.trailingAnchor, constant: 2.0),
			cursor.heightAnchor.constraint(equalToConstant: 24.0),
			cursor.centerYAnchor.constraint(equalTo: amountLabel.centerYAnchor),
			cursor.widthAnchor.constraint(equalToConstant: 2.0)
		])
		currencyToggleButton.constrain([
			currencyToggleButton.topAnchor.constraint(equalTo: view.topAnchor, constant: currencyToggleButtonConstant),
			currencyToggleButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -C.padding[2])
		])
		feeSelectorHeight = feeContainer.heightAnchor.constraint(equalToConstant: 0.0)
		feeSelectorTop = feeContainer.topAnchor.constraint(equalTo: feesLabel.bottomAnchor, constant: 0.0)

		feeContainer.constrain([
			feeSelectorTop,
			feeSelectorHeight,
			feeContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			feeContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor)
		])
		feeContainer.arrowXLocation = C.padding[4]

		let borderTop = isRequesting ? border.topAnchor.constraint(equalTo: currencyToggleButton.bottomAnchor, constant: C.padding[2]) : border.topAnchor.constraint(equalTo: feeContainer.bottomAnchor)
		border.constrain([
			border.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			borderTop,
			border.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			border.heightAnchor.constraint(equalToConstant: 1.0)
		])
		balanceLabel.constrain([
			balanceLabel.leadingAnchor.constraint(equalTo: amountLabel.leadingAnchor),
			balanceLabel.topAnchor.constraint(equalTo: cursor.bottomAnchor, constant: 10.0)
		])
		feesLabel.constrain([
			feesLabel.leadingAnchor.constraint(equalTo: balanceLabel.leadingAnchor),
			feesLabel.topAnchor.constraint(equalTo: balanceLabel.bottomAnchor)
		])
		pinPadHeight = pinPad.view.heightAnchor.constraint(equalToConstant: 0.0)
		addChildViewController(pinPad, layout: {
			pinPad.view.constrain([
				pinPad.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
				pinPad.view.topAnchor.constraint(equalTo: border.bottomAnchor),
				pinPad.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
				pinPad.view.bottomAnchor.constraint(equalTo: bottomBorder.topAnchor),
				pinPadHeight
			])
		})
		editFee.constrain([
			editFee.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0.0),
			editFee.centerYAnchor.constraint(equalTo: feesLabel.centerYAnchor, constant: -1.0),
			editFee.widthAnchor.constraint(equalToConstant: 44.0),
			editFee.heightAnchor.constraint(equalToConstant: 44.0)
		])
		bottomBorder.constrain([
			bottomBorder.topAnchor.constraint(greaterThanOrEqualTo: currencyToggleButton.bottomAnchor, constant: C.padding[3]),
			bottomBorder.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			bottomBorder.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			bottomBorder.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			bottomBorder.heightAnchor.constraint(equalToConstant: 1.0)
		])

		tapView.constrain([
			tapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			tapView.topAnchor.constraint(equalTo: view.topAnchor),
			tapView.trailingAnchor.constraint(equalTo: currencyToggleButton.leadingAnchor, constant: 4.0),
			tapView.bottomAnchor.constraint(equalTo: feeContainer.topAnchor)
		])
		preventAmountOverflow()
	}

	private func setInitialData() {
		cursor.isHidden = true
		cursor.startBlinking()

		amountLabel.text = ""

		placeholder.backgroundColor = BrainwalletUIColor.surface
		placeholder.layer.cornerRadius = 8.0
		placeholder.layer.masksToBounds = true

		amountLabel.backgroundColor = BrainwalletUIColor.surface
		amountLabel.layer.cornerRadius = 8.0
		amountLabel.layer.masksToBounds = true

		placeholder.text = String(localized: "Amount", bundle: .main)
		bottomBorder.isHidden = true
		if store.state.isLtcSwapped {
			if let rate = store.state.currentRate {
				selectedRate = rate
			}
		}
		pinPad.ouputDidUpdate = { [weak self] output in
			self?.handlePinPadUpdate(output: output)
		}
		currencyToggleButton.tap = strongify(self) { myself in
			myself.toggleCurrency()
		}
		let gr = UITapGestureRecognizer(target: self, action: #selector(didTap))
		tapView.addGestureRecognizer(gr)
		tapView.isUserInteractionEnabled = true

		if isPinPadExpandedAtLaunch {
			didTap()
		}

		feeContainer.contentView = feeSelector
		editFee.tap = { [weak self] in
			self?.toggleFeeSelector()
		}
		editFee.setImage(#imageLiteral(resourceName: "Edit"), for: .normal)
		editFee.imageEdgeInsets = UIEdgeInsets(top: 15.0, left: 15.0, bottom: 15.0, right: 15.0)
		editFee.tintColor = BrainwalletUIColor.content
		editFee.isHidden = true
	}

	private func toggleCurrency() {
		selectedRate = (selectedRate == nil) ? store.state.currentRate : nil
		updatecurrencyToggleButtonTitle()
	}

	private func preventAmountOverflow() {
		amountLabel.constrain([
			amountLabel.trailingAnchor.constraint(lessThanOrEqualTo: currencyToggleButton.leadingAnchor, constant: -C.padding[2])
		])
		amountLabel.minimumScaleFactor = 0.95
		amountLabel.adjustsFontSizeToFitWidth = true
		amountLabel.setContentCompressionResistancePriority(UILayoutPriority.defaultLow, for: .horizontal)
	}

	private func handlePinPadUpdate(output: String) {
		let currencyDecimalSeparator = NumberFormatter().currencyDecimalSeparator ?? "."
		placeholder.isHidden = output.utf8.count > 0 ? true : false
		minimumFractionDigits = 0 // set default
		if let decimalLocation = output.range(of: currencyDecimalSeparator)?.upperBound {
			let locationValue = output.distance(from: output.endIndex, to: decimalLocation)
			minimumFractionDigits = abs(locationValue)
		}

		// If trailing decimal, append the decimal to the output
		hasTrailingDecimal = false // set default
		if let decimalLocation = output.range(of: currencyDecimalSeparator)?.upperBound {
			if output.endIndex == decimalLocation {
				hasTrailingDecimal = true
			}
		}

		var newAmount: Satoshis?
		if let outputAmount = NumberFormatter().number(from: output)?.doubleValue {
			if let rate = selectedRate {
				newAmount = Satoshis(value: outputAmount, rate: rate)
			} else {
				if store.state.maxDigits == 5 {
					let bits = Bits(rawValue: outputAmount * 1000)
					newAmount = Satoshis(bits: bits)
				} else {
					let bitcoin = Bitcoin(rawValue: outputAmount)
					newAmount = Satoshis(bitcoin: bitcoin)
				}
			}
		}

		if let newAmount = newAmount {
			if newAmount > C.maxMoney {
				pinPad.removeLast()
			} else {
				amount = newAmount
			}
		} else {
			amount = nil
		}
	}

	private func updateAmountLabel() {
		guard let amount = amount else { amountLabel.text = ""; return }
		let displayAmount = DisplayAmount(amount: amount, state: store.state, selectedRate: selectedRate, minimumFractionDigits: minimumFractionDigits)
		var output = displayAmount.description
		if hasTrailingDecimal {
			output = output.appending(NumberFormatter().currencyDecimalSeparator)
		}
		amountLabel.text = output
		placeholder.isHidden = output.utf8.count > 0 ? true : false
	}

	func updateBalanceLabel() {
		if let (balance, fees) = balanceTextForAmount?(amount, selectedRate) {
			balanceLabel.attributedText = balance
			feesLabel.attributedText = fees
			if let amount = amount, amount > 0, !isRequesting {
				editFee.isHidden = false
			} else {
				editFee.isHidden = true
			}
			balanceLabel.isHidden = cursor.isHidden
		}
	}

	private func toggleFeeSelector() {
		guard let height = feeSelectorHeight else { return }
		let isCollapsed: Bool = height.isActive
		UIView.spring(C.animationDuration, animations: {
			if isCollapsed {
				NSLayoutConstraint.deactivate([height])
				self.feeSelector.addIntrinsicSize()
			} else {
				self.feeSelector.removeIntrinsicSize()
				NSLayoutConstraint.activate([height])
			}
			self.parent?.parent?.view?.layoutIfNeeded()
		}, completion: { _ in })
	}

	@objc private func didTap() {
		UIView.spring(C.animationDuration, animations: {
			self.togglePinPad()
			self.parent?.parent?.view.layoutIfNeeded()
		}, completion: { _ in })
	}

	func closePinPad() {
		pinPadHeight?.constant = 0.0
		cursor.isHidden = true
		bottomBorder.isHidden = true
		updateBalanceAndFeeLabels()
		updateBalanceLabel()
	}

	private func togglePinPad() {
		let isCollapsed: Bool = pinPadHeight?.constant == 0.0
		pinPadHeight?.constant = isCollapsed ? pinPad.height : 0.0
		cursor.isHidden = isCollapsed ? false : true
		bottomBorder.isHidden = isCollapsed ? false : true
		updateBalanceAndFeeLabels()
		updateBalanceLabel()
		didChangeFirstResponder?(isCollapsed)
	}

	private func updateBalanceAndFeeLabels() {
		if let amount = amount, amount.rawValue > 0 {
			balanceLabel.isHidden = false
			if !isRequesting {
				editFee.isHidden = false
			}
		} else {
			balanceLabel.isHidden = cursor.isHidden
			if !isRequesting {
				editFee.isHidden = true
			}
		}
	}

	private func fullRefresh() {
		updatecurrencyToggleButtonTitle()
		updateBalanceLabel()
		updateAmountLabel()

		// Update pinpad content to match currency change
		// This must be done AFTER the amount label has updated
		let currentOutput = amountLabel.text ?? ""
		var set = CharacterSet.decimalDigits
		set.formUnion(CharacterSet(charactersIn: NumberFormatter().currencyDecimalSeparator))
		pinPad.currentOutput = String(String.UnicodeScalarView(currentOutput.unicodeScalars.filter { set.contains($0) }))
	}

	private func updatecurrencyToggleButtonTitle() {
		if let rate = selectedRate {
			currencyToggleButton.title = "\(rate.code)(\(rate.currencySymbol))"
			didShowFiat?(false)
		} else {
			currencyToggleButton.title = currencyButtonTitle(maxDigits: store.state.maxDigits)
			didShowFiat?(true)
		}
	}
    
	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
