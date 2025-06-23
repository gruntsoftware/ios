import BRCore
import FirebaseAnalytics
import KeychainAccess
import LocalAuthentication
import SwiftUI
import UIKit

typealias PresentScan = (@escaping (PaymentRequest) -> Void) -> Void

class SendViewController: UIViewController, Subscriber, ModalPresentable, Trackable {
	// MARK: - Public

	var presentScan: PresentScan?
	var presentVerifyPin: ((String, @escaping VerifyPinCallback) -> Void)?
	var onPublishSuccess: (() -> Void)?
	var onResolvedSuccess: (() -> Void)?
	var onResolutionFailure: ((String) -> Void)?
	var parentView: UIView? // ModalPresentable
	var initialAddress: String?
	var isPresentedFromLock = false
	var hasActivatedInlineFees: Bool = true

	// MARK: - Private

    var store: Store?
	private let sender: Sender
	private let walletManager: WalletManager
	private let amountView: AmountViewController
	private let sendAddressCell = AddressCell()
	private let memoCell = DescriptionSendCell(placeholder: "Memo" )
	private var sendButtonCell = SendButtonHostingController()
	private let currency: ShadowButton
	private var balance: UInt64 = 0
	private var amount: Satoshis?
	private var didIgnoreUsedAddressWarning = false
	private var didIgnoreIdentityNotCertified = false
	private let initialRequest: PaymentRequest?
	private let confirmTransitioningDelegate = TransitioningDelegate()
	private var feeType: FeeType?
	private let keychainPreferences = Keychain(service: "brainwallet.user-prefs")
	private var buttonToBorder: CGFloat = 0.0

	init(store: Store, sender: Sender, walletManager: WalletManager, initialAddress: String? = nil, initialRequest: PaymentRequest? = nil) {
		self.store = store
		self.sender = sender
		self.walletManager = walletManager
		self.initialAddress = initialAddress
		self.initialRequest = initialRequest

        var currencyButtonTitle = ""
        switch store.state.maxDigits {
                    case 2: currencyButtonTitle = "photons (mł)"
                    case 5: currencyButtonTitle = "lites (ł)"
                    case 8: currencyButtonTitle = "LTC (Ł)"
                    default: currencyButtonTitle = "lites (ł)"
                }

        currency = ShadowButton(title: currencyButtonTitle, type: .tertiary)

		/// User Preference
		if let opsPreference = keychainPreferences["hasAcceptedFees"],
		   opsPreference == "false" {
			hasActivatedInlineFees = false
		} else {
			keychainPreferences["has-accepted-fees"] = "true"
		}

        amountView = AmountViewController(store: store, isPinPadExpandedAtLaunch: false, hasAcceptedFees: hasActivatedInlineFees)
		BWAnalytics.logEventWithParameters(itemName: ._20191105_VSC)
		super.init(nibName: nil, bundle: nil)
	}

	// MARK: - Private

	deinit {
        guard let store = store else {
            debugPrint("::: ERROR: Store not initialized")
            return
        }
		store.unsubscribe(self)
		NotificationCenter.default.removeObserver(self)
	}

	override func viewDidLoad() {
        guard let store = store else {
            debugPrint("::: ERROR: Store not initialized")
            return
        }

		view.backgroundColor = BrainwalletUIColor.surface

		// set as regular at didLoad
		walletManager.wallet?.feePerKb = store.state.fees.regular

		// polish parameters
		memoCell.backgroundColor = BrainwalletUIColor.surface
        amountView.view.backgroundColor = BrainwalletUIColor.surface
        self.view.backgroundColor = BrainwalletUIColor.surface

		view.addSubview(sendAddressCell)
		view.addSubview(memoCell)
		view.addSubview(sendButtonCell.view)

		sendAddressCell.invalidateIntrinsicContentSize()
		sendAddressCell.constrainTopCorners(height: SendCell.defaultHeight)

		memoCell.constrain([
			memoCell.widthAnchor.constraint(equalTo: sendAddressCell.widthAnchor),
			memoCell.topAnchor.constraint(equalTo: sendAddressCell.bottomAnchor),
			memoCell.leadingAnchor.constraint(equalTo: sendAddressCell.leadingAnchor),
            memoCell.constraint(.height, constant: 44.0)
		])
		memoCell.accessoryView.constrain([
			memoCell.accessoryView.constraint(.width, constant: 0.0)
		])
		addChildViewController(amountView, layout: {
            amountView.view.constrain([
                amountView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
                amountView.view.topAnchor.constraint(equalTo: memoCell.bottomAnchor),
                amountView.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
			])
		})

		sendButtonCell.view.constrain([
			sendButtonCell.view.constraint(.leading, toView: view),
			sendButtonCell.view.constraint(.trailing, toView: view),
			sendButtonCell.view.constraint(toBottom: amountView.view, constant: buttonToBorder),
			sendButtonCell.view.constraint(.height, constant: C.Sizes.sendButtonHeight),
			sendButtonCell.view
				.bottomAnchor
				.constraint(equalTo: view.bottomAnchor, constant: -C.padding[8])
		])

		addButtonActions()
		store.subscribe(self, selector: { $0.walletState.balance != $1.walletState.balance },
		                callback: {
		                	if let balance = $0.walletState.balance {
		                		self.balance = balance
		                	}
		                })
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		if initialAddress != nil {
            amountView.expandPinPad()
		} else if let initialRequest = initialRequest {
			handleRequest(initialRequest)
		}
	}

	private func addButtonActions() {

		memoCell.didReturn = { textView in
			textView.resignFirstResponder()
		}
		memoCell.didBeginEditing = { [weak self] in
			self?.amountView.closePinPad()
		}

        amountView.balanceTextForAmount = { [weak self] enteredAmount, rate in
			self?.balanceTextForAmountWithFormattedFees(enteredAmount: enteredAmount, rate: rate)
		}

        amountView.didUpdateAmount = { [weak self] amount in
			self?.amount = amount
		}
        amountView.didUpdateFee = strongify(self) { myself, feeType in

			myself.feeType = feeType
            let fees = myself.store?.state.fees
            guard let reg = fees?.regular,
                  let econ = fees?.economy,
                  let lux = fees?.luxury else { return }

			switch feeType {
            case .regular: myself.walletManager.wallet?.feePerKb = reg
			case .economy: myself.walletManager.wallet?.feePerKb = econ
			case .luxury: myself.walletManager.wallet?.feePerKb = lux
			}

			myself.amountView.updateBalanceLabel()
		}

        amountView.didChangeFirstResponder = { [weak self] isFirstResponder in
			if isFirstResponder {
				self?.memoCell.textView.resignFirstResponder()
				self?.sendAddressCell.textField.resignFirstResponder()
				/// copyKeyboardChangeAnimation(willShow: true, notification: notification)
			}
		}

		sendAddressCell.paste.addTarget(self, action: #selector(SendViewController.pasteTapped), for: .touchUpInside)
		sendAddressCell.scan.addTarget(self, action: #selector(SendViewController.scanTapped), for: .touchUpInside)

		sendAddressCell.didBeginEditing = strongify(self) { _ in
			// myself.amountView.closePinPad()
		}

		sendAddressCell.didEndEditing = strongify(self) { myself in
			myself.resignFirstResponder()
		}

		sendAddressCell.didReceivePaymentRequest = { [weak self] request in
			self?.handleRequest(request)
		}

		sendButtonCell.rootView.doSendTransaction = {
			if let sendAddress = self.sendAddressCell.address,
			   sendAddress.isValidAddress {
				self.sendTapped()
			} else {
				self.showAlert(title: "Error" ,
				               message: "Enter LTC address" ,
				               buttonLabel: "Ok" )
			}
		}
	}

	private func balanceTextForAmountWithFormattedFees(enteredAmount: Satoshis?, rate: Rate?) -> (NSAttributedString?, NSAttributedString?) {
		/// DEV: KCW 12-FEB-24

        guard let store = store else {
            debugPrint("::: ERROR: Store not initialized")
            return (nil, nil)
        }

		var currentRate: Rate?
		if rate == nil {
			currentRate = store.state.currentRate
		} else {
			currentRate = rate
		}

		let balanceAmount = DisplayAmount(amount: Satoshis(rawValue: balance),
		                                  state: store.state,
		                                  selectedRate: currentRate,
		                                  minimumFractionDigits: 2)

		let balanceText = balanceAmount.description
        let balanceLocalized = String(localized: "Balance")
		let balanceOutput = String(format: "%@: %1$@" , balanceLocalized, balanceText)
        let combinedFeesOutput = ""
        var balanceColor: UIColor = BrainwalletUIColor.content

		/// Check the amount is greater than zero and amount satoshis are not nil
		if let currentRate = currentRate,
		   let enteredAmount = enteredAmount,
		   enteredAmount > 0 {
			let tieredOpsFee = tieredOpsFee(amount: enteredAmount.rawValue)

			let totalAmountToCalculateFees = (enteredAmount.rawValue + tieredOpsFee)

			let networkFee = sender.feeForTx(amount: totalAmountToCalculateFees)
			let totalFees = (networkFee + tieredOpsFee)
			let sendTotal = balance + totalFees
			let networkFeeAmount = DisplayAmount(amount: Satoshis(rawValue: networkFee),
			                                     state: store.state,
			                                     selectedRate: currentRate,
			                                     minimumFractionDigits: 2).description

			let serviceFeeAmount = DisplayAmount(amount: Satoshis(rawValue: tieredOpsFee),
			                                     state: store.state,
			                                     selectedRate: currentRate,
			                                     minimumFractionDigits: 2).description

			let totalFeeAmount = DisplayAmount(amount: Satoshis(rawValue: networkFee + tieredOpsFee),
			                                   state: store.state,
			                                   selectedRate: currentRate,
			                                   minimumFractionDigits: 2).description

            _ = String(
                format: String(localized: "(Network fee + Service fee):", bundle: .main),
                networkFeeAmount,
                serviceFeeAmount,
                totalFeeAmount
            )

			if sendTotal > balance {
                balanceColor = BrainwalletUIColor.error
			} else {
                balanceColor = BrainwalletUIColor.content
            }
		}

		let balanceStyle = [
			NSAttributedString.Key.font: UIFont.customBody(size: 14.0),
            NSAttributedString.Key.foregroundColor: balanceColor
		]

		return (NSAttributedString(string: balanceOutput, attributes: balanceStyle), NSAttributedString(string: combinedFeesOutput, attributes: balanceStyle))
	}

	@objc private func pasteTapped() {
		guard let pasteboard = UIPasteboard.general.string, !pasteboard.utf8.isEmpty
		else {
			return showAlert(title:String(localized: "Invalid Address", bundle: .main), message: String(localized: "Please enter the recipient's address.", bundle: .main), buttonLabel:  String(localized: "Ok", bundle: .main))
		}
		guard let request = PaymentRequest(string: pasteboard)
		else {
			return showAlert(title: "Invalid Address" , message: "Please enter the recipient's address." , buttonLabel: "Ok" )
		}

		handleRequest(request)
		sendAddressCell.textField.text = pasteboard
		sendAddressCell.textField.layoutIfNeeded()
	}

	@objc private func scanTapped() {
		memoCell.textView.resignFirstResponder()

		presentScan? { [weak self] paymentRequest in
			// guard let request = paymentRequest else { return }
            guard let destinationAddress = paymentRequest.toAddress else { return }

			self?.handleRequest(paymentRequest)
			self?.sendAddressCell.textField.text = destinationAddress
		}
	}

	@objc private func sendTapped() {

        guard let store = store else {
            debugPrint("::: ERROR: Store not initialized")
            return
        }

		if sendAddressCell.textField.isFirstResponder {
			sendAddressCell.textField.resignFirstResponder()
		}
		let bareAmount: Satoshis?
		if sender.transaction == nil {
			guard let address = sendAddressCell.address else {
				return showAlert(title: "Error" ,
				                 message: "Please enter the recipient's address.", buttonLabel: "Ok" )
			}

			if !address.isValidAddress {
				return showAlert(title: "Error" ,
				                 message: "Please enter the recipient's address." ,
				                 buttonLabel: "Ok" )
			}

			guard var amountToSend = amount
			else {
				return showAlert(title: "Error" ,
				                 message: "Please enter an amount to send.",
				                 buttonLabel: "Ok" )
			}

			let opsFeeAmount = Satoshis(rawValue: tieredOpsFee(amount: amountToSend.rawValue))
			let fee = walletManager.wallet?.feeForTx(amount: amountToSend.rawValue + opsFeeAmount.rawValue)
			let feeInSatoshis = Satoshis(rawValue: fee ?? 0)
			bareAmount = amountToSend

			/// Set ops fees
			if hasActivatedInlineFees {
				amountToSend = amountToSend + opsFeeAmount
			}

			if let minOutput = walletManager.wallet?.minOutputAmount {
				guard amountToSend.rawValue >= minOutput
				else {
					let minOutputAmount = Amount(amount: minOutput, rate: Rate.empty, maxDigits: store.state.maxDigits)
					let message = String(format: "Litecoin payments can't be less than %1$@" ,
					                     minOutputAmount.string(isLtcSwapped: store.state.isLtcSwapped))
					return showAlert(title: "Error" ,
					                 message: message,
					                 buttonLabel: "Ok" )
				}
			}
			guard !(walletManager.wallet?.containsAddress(address) ?? false)
			else {
				return showAlert(title: "Error" ,
				                 message: "The destination is your own address. You cannot send to yourself." ,
				                 buttonLabel: "Ok" )
			}
			guard amountToSend.rawValue <= (walletManager.wallet?.maxOutputAmount ?? 0)
			else {
				return showAlert(title: "Error" ,
				                 message:  "Insufficient Funds" ,
				                 buttonLabel: "Ok" )
			}

			/// Set Ops or Single Output
			if hasActivatedInlineFees {
				guard let bareAmt = bareAmount?.rawValue,
				      sender.createTransactionWithOpsOutputs(amount: bareAmt, to: address)
				else {
					return showAlert(title: "Error" ,
					                 message: "Could not create transaction." ,
					                 buttonLabel: "Ok")
				}
			} else {
				guard let bareAmt = bareAmount?.rawValue,
				      sender.createTransaction(amount: bareAmt, to: address)
				else {
					return showAlert(title: "Error",
					                 message: "Could not create transaction." ,
					                 buttonLabel: "Ok")
				}
			}

			let confirm = ConfirmationViewController(amount: bareAmount ?? Satoshis(0),
			                                         txFee: feeInSatoshis,
			                                         opsFee: opsFeeAmount,
			                                         feeType: feeType ?? .regular, state: store.state,
			                                         selectedRate: amountView.selectedRate,
			                                         minimumFractionDigits: amountView.minimumFractionDigits,
			                                         address: address, isUsingBiometrics: sender.canUseBiometrics)

			confirm.successCallback = {
				confirm.dismiss(animated: true, completion: {
					self.send()
				})
			}
			confirm.cancelCallback = {
				confirm.dismiss(animated: true, completion: {
					self.sender.transaction = nil
				})
			}
			confirmTransitioningDelegate.shouldShowMaskView = false
			confirm.transitioningDelegate = confirmTransitioningDelegate
			confirm.modalPresentationStyle = UIModalPresentationStyle.overFullScreen
			confirm.modalPresentationCapturesStatusBarAppearance = true
			present(confirm, animated: true, completion: nil)

		} else {
			NSLog("Error: transaction  is nil")
		}
	}

	private func handleRequest(_ request: PaymentRequest) {
		switch request.type {
		case .local:

			if let amount = request.amount {
                amountView.forceUpdateAmount(amount: amount)
			}
			if request.label != nil {
				memoCell.content = request.label
			}

		case .remote:
			let loadingView = BRActivityViewController(message: "Loading Request" )
			present(loadingView, animated: true, completion: nil)
			request.fetchRemoteRequest(completion: { [weak self] request in
				DispatchQueue.main.async {
					loadingView.dismiss(animated: true, completion: {
						if let paymentProtocolRequest = request?.paymentProtocolRequest {
							self?.confirmProtocolRequest(protoReq: paymentProtocolRequest)
						} else {
							self?.showErrorMessage("Could not load payment request")
						}
					})
				}
			})
		}
	}

	private func send() {

        guard let store = store,
        let rate = store.state.currentRate,
        let feePerKb = walletManager.wallet?.feePerKb else {
            debugPrint("::: ERROR: Store Rate feePerKb not initialized")
            return
        }

		sender.send(biometricsMessage: "Authorize this transaction" ,
		            rate: rate,
		            comment: memoCell.textView.text,
		            feePerKb: feePerKb,
		            verifyPinFunction: { [weak self] pinValidationCallback in
		            	self?.presentVerifyPin?(String(localized: "Please enter your PIN to authorize this transaction.")) { [weak self] passcode, viewController in
		            		     if pinValidationCallback(passcode) {
                                     viewController.dismiss(animated: true, completion: {
		            				 self?.parent?.view.isFrameChangeBlocked = false
		            			 })
                                     return true
		            		     } else {
		            			     return false
		            		     }
		            	    }
		            }, completion: { [weak self] result in
		            	switch result {
		            	case .success:
		            		self?.dismiss(animated: true, completion: {
		            			guard let myself = self else { return }
		            			myself.store?.trigger(name: .showStatusBar)
		            			if myself.isPresentedFromLock {
		            				myself.store?.trigger(name: .loginFromSend)
		            			}
		            			myself.onPublishSuccess?()
		            		})
		            		self?.saveEvent("send.success")
		            		self?.sendAddressCell.textField.text = ""
		            		self?.memoCell.textView.text = ""
		            		BWAnalytics.logEventWithParameters(itemName: ._20191105_DSL)

		            	case let .creationError(message):
		            		self?.showAlert(title: String(localized: "Could not create transaction." , bundle: .main), message: message, buttonLabel:  String(localized: "Ok", bundle: .main))
		            		self?.saveEvent("send.publishFailed", attributes: ["errorMessage": message])

		            	case let .publishFailure(error):
		            		if case let .posixError(code, description) = error {
		            			self?.showAlert(title: String(localized: "Send failed", bundle: .main), message: "\(description) (\(code))", buttonLabel: String(localized:  "Ok", bundle: .main))
		            			self?.saveEvent("send.publishFailed", attributes: ["errorMessage": "\(description) (\(code))"])
		            		}
		            	}
		            })
	}

	func confirmProtocolRequest(protoReq: PaymentProtocolRequest) {

        guard let firstOutput = protoReq.details.outputs.first,
        let wallet = walletManager.wallet,
        let feePerKb = walletManager.wallet?.feePerKb,
        let store = store else {
            debugPrint("::: ERROR: First Output, wallet or feePerKb not initialized")
            return
        }

		let address = firstOutput.updatedSwiftAddress
		let isValid = protoReq.isValid()
		var isOutputTooSmall = false

		if let errorMessage = protoReq.errorMessage, errorMessage == "request expired" , !isValid {
			return showAlert(title: String(localized:  "Bad Payment Request", bundle: .main), message: errorMessage, buttonLabel: String(localized:  "Ok", bundle: .main))
		}

		// TODO: check for duplicates of already paid requests
		var requestAmount = Satoshis(0)
		for output in protoReq.details.outputs {
			if output.amount > 0, output.amount < wallet.minOutputAmount {
				isOutputTooSmall = true
			}
			requestAmount += output.amount
		}

		if wallet.containsAddress(address) {
			return showAlert(title: String(localized: "Warning", bundle: .main), message: String(localized: "The destination is your own address. You cannot send to yourself.", bundle: .main) , buttonLabel: String(localized:  "Ok", bundle: .main))
		} else if wallet.addressIsUsed(address), !didIgnoreUsedAddressWarning {
			let message = String(localized: "Address Already Used\n\n Litecoin addresses are intended for single use only.\n\nRe-use reduces privacy for both you and the recipient and can result in loss if the recipient doesn't directly control the address.", bundle: .main)
			return showError(title: String(localized: "Warning", bundle: .main), message: message, ignore: { [weak self] in
				self?.didIgnoreUsedAddressWarning = true
				self?.confirmProtocolRequest(protoReq: protoReq)
			})
		} else if let message = protoReq.errorMessage, !message.utf8.isEmpty, (protoReq.commonName?.utf8.count)! > 0, !didIgnoreIdentityNotCertified {
			return showError(title: String(localized: "Payee identity isn't certified.", bundle: .main), message: message, ignore: { [weak self] in
				self?.didIgnoreIdentityNotCertified = true
				self?.confirmProtocolRequest(protoReq: protoReq)
			})
		} else if requestAmount < wallet.minOutputAmount {
			let amount = Amount(amount: wallet.minOutputAmount, rate: Rate.empty, maxDigits: store.state.maxDigits)
			let message = String(format: "Litecoin payments can't be less than %1$@.", amount.bits)
			return showAlert(title: String(localized: "Couldn't make payment", bundle: .main), message: message, buttonLabel: String(localized: "Ok", bundle: .main))
		} else if isOutputTooSmall {
			let amount = Amount(amount: wallet.minOutputAmount, rate: Rate.empty, maxDigits: store.state.maxDigits)
			let message = String(format: "Litecoin transaction outputs can't be less than $@.", amount.bits)
			return showAlert(title: String(localized: "Couldn't make payment", bundle: .main), message: message, buttonLabel: String(localized: "Ok", bundle: .main))
		}

		if requestAmount > 0 {
            amountView.forceUpdateAmount(amount: requestAmount)
		}
		memoCell.content = protoReq.details.memo

		if requestAmount == 0 {
			if let amount = amount {
				guard sender.createTransaction(amount: amount.rawValue, to: address)
				else {
					return showAlert(title: String(localized: "Error", bundle: .main) , message: String(localized: "Could not create transaction.", bundle: .main) , buttonLabel: String(localized: "Ok", bundle: .main))
				}
			}
		}
	}

	private func showError(title: String, message: String, ignore: @escaping () -> Void) {
		let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
		alertController.addAction(UIAlertAction(title: String(localized: "Ignore", bundle: .main), style: .default, handler: { _ in
			ignore()
		}))
		alertController.addAction(UIAlertAction(title: String(localized: "Cancel", bundle: .main) , style: .cancel, handler: nil))
		present(alertController, animated: true, completion: nil)
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

extension SendViewController: ModalDisplayable {

	var modalTitle: String {
		return String(localized: "Send")
	}
}
