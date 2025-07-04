import BRCore
import UIKit

private let mainURL = "https://litecoinspace.org/graphs/mempool"

class StartImportViewController: UIViewController {
	init(walletManager: WalletManager, store: Store) {
		self.walletManager = walletManager
		self.store = store
		super.init(nibName: nil, bundle: nil)
	}

	private let walletManager: WalletManager
	private let store: Store
    private let header = RadialGradientView(backgroundColor: BrainwalletUIColor.info, offset: 64.0)
	private let illustration = UIImageView(image: #imageLiteral(resourceName: "ImportIllustration"))
	private let message = UILabel.wrapping(font: .customBody(size: 16.0), color: BrainwalletUIColor.content)
	private let warning = UILabel.wrapping(font: .customBody(size: 16.0), color: BrainwalletUIColor.content)
	private let button = ShadowButton(title: S.Import.scan.localize(), type: .primary)
	private let bullet = UIImageView(image: #imageLiteral(resourceName: "deletecircle"))
	private let leftCaption = UILabel.wrapping(font: .customMedium(size: 13.0), color: BrainwalletUIColor.content)
	private let rightCaption = UILabel.wrapping(font: .customMedium(size: 13.0), color: BrainwalletUIColor.content)
	private let balanceActivity = BRActivityViewController(message: S.Import.checking.localize())
	private let importingActivity = BRActivityViewController(message: S.Import.importing.localize())
	private let unlockingActivity = BRActivityViewController(message: S.Import.unlockingActivity.localize())

	override func viewDidLoad() {
		addSubviews()
		addConstraints()
		setInitialData()
	}

	private func addSubviews() {
		view.addSubview(header)
		header.addSubview(illustration)
		header.addSubview(leftCaption)
		header.addSubview(rightCaption)
		view.addSubview(message)
		view.addSubview(button)
		view.addSubview(bullet)
		view.addSubview(warning)
	}

	private func addConstraints() {
		header.constrainTopCorners(sidePadding: 0, topPadding: 0)
		header.constrain([
			header.constraint(.height, constant: 220.0)
		])
		illustration.constrain([
			illustration.constraint(.width, constant: 64.0),
			illustration.constraint(.height, constant: 84.0),
			illustration.constraint(.centerX, toView: header, constant: 0.0),
			illustration.constraint(.centerY, toView: header, constant: -C.padding[1])
		])
		leftCaption.constrain([
			leftCaption.topAnchor.constraint(equalTo: illustration.bottomAnchor, constant: C.padding[1]),
			leftCaption.trailingAnchor.constraint(equalTo: header.centerXAnchor, constant: -C.padding[2]),
			leftCaption.widthAnchor.constraint(equalToConstant: 80.0)
		])
		rightCaption.constrain([
			rightCaption.topAnchor.constraint(equalTo: illustration.bottomAnchor, constant: C.padding[1]),
			rightCaption.leadingAnchor.constraint(equalTo: header.centerXAnchor, constant: C.padding[2]),
			rightCaption.widthAnchor.constraint(equalToConstant: 80.0)
		])
		message.constrain([
			message.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: C.padding[2]),
			message.topAnchor.constraint(equalTo: header.bottomAnchor, constant: C.padding[2]),
			message.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -C.padding[2])
		])
		bullet.constrain([
			bullet.leadingAnchor.constraint(equalTo: message.leadingAnchor),
			bullet.topAnchor.constraint(equalTo: message.bottomAnchor, constant: C.padding[4]),
			bullet.widthAnchor.constraint(equalToConstant: 16.0),
			bullet.heightAnchor.constraint(equalToConstant: 16.0)
		])
		warning.constrain([
			warning.leadingAnchor.constraint(equalTo: bullet.trailingAnchor, constant: C.padding[2]),
			warning.topAnchor.constraint(equalTo: bullet.topAnchor, constant: 0.0),
			warning.trailingAnchor.constraint(equalTo: message.trailingAnchor)
		])
		button.constrain([
			button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: C.padding[3]),
			button.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -C.padding[4]),
			button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -C.padding[3]),
			button.constraint(.height, constant: C.Sizes.buttonHeight)
		])
	}

	private func setInitialData() {
		view.backgroundColor = BrainwalletUIColor.surface
		illustration.contentMode = .scaleAspectFill
		message.text = S.Import.importMessage.localize()
		leftCaption.text = S.Import.leftCaption.localize()
		leftCaption.textAlignment = .center
		rightCaption.text = S.Import.rightCaption.localize()
		rightCaption.textAlignment = .center
		warning.text = S.Import.importWarning.localize()

		button.tap = { [weak self] in
			let scan = ScanViewController(scanKeyCompletion: { keyString in
				self?.didReceiveAddress(keyString)
			}, isValidURI: { string -> Bool in
				string.isValidPrivateKey || string.isValidBip38Key
			})
			self?.parent?.present(scan, animated: true, completion: nil)
		}
	}

	private func didReceiveAddress(_ addressOrKeyString: String) {
		if addressOrKeyString.isValidPrivateKey {
			if let key = BRKey(privKey: addressOrKeyString) {
				checkBalance(key: key)
			}
		} else if addressOrKeyString.isValidBip38Key {
			unlock(address: addressOrKeyString, callback: { key in
				self.checkBalance(key: key)
			})
		} else {
			NSLog("ERROR ADDRESS OR KEY STRING: \(addressOrKeyString)")
		}
	}

	private func unlock(address: String, callback: @escaping (BRKey) -> Void) {
		let alert = UIAlertController(title: S.Import.title.localize(), message: S.Import.password.localize(), preferredStyle: .alert)
		alert.addTextField(configurationHandler: { textField in
			textField.placeholder = S.Import.passwordPlaceholder.localize()
			textField.isSecureTextEntry = true
			textField.returnKeyType = .done
		})
		alert.addAction(UIAlertAction(title: S.Button.cancel.localize(), style: .cancel, handler: nil))
		alert.addAction(UIAlertAction(title: S.Button.ok.localize(), style: .default, handler: { _ in
			self.present(self.unlockingActivity, animated: true, completion: {
				if let password = alert.textFields?.first?.text {
					if let key = BRKey(bip38Key: address, passphrase: password) {
						self.unlockingActivity.dismiss(animated: true, completion: {
							callback(key)
						})
						return
					}
				}
				self.unlockingActivity.dismiss(animated: true, completion: {
					self.showErrorMessage(S.Import.wrongPassword.localize())
				})
			})
		}))
		present(alert, animated: true, completion: nil)
	}

	private func checkBalance(key: BRKey) {
		present(balanceActivity, animated: true, completion: {
			var key = key

			guard let address = key.address()
			else {
				NSLog("KEY ADDRESS: No Key Address")
				return
			}

			let urlString = mainURL
			let request = NSMutableURLRequest(url: URL(string: urlString)!,
			                                  cachePolicy: .reloadIgnoringLocalCacheData,
			                                  timeoutInterval: 20.0)
            #if targetEnvironment(simulator)
                request.assumesHTTP3Capable = false
            #endif
			request.httpMethod = "POST"
			request.httpBody = "addrs=\(address)".data(using: .utf8)
			let task = URLSession(configuration: .ephemeral).dataTask(with: request as URLRequest) { [weak self] data, _, error in
				guard let myself = self else { return }
				guard error == nil else { print("error: \(error!)"); return }
				guard let data = data,
				      let jsonData = try? JSONSerialization.jsonObject(with: data, options: []),
				      let json = jsonData as? [[String: Any]] else { return }

				DispatchQueue.main.async {
					myself.handleData(data: json, key: key)
				}
			}
			task.resume()
		})
	}

	private func handleData(data: [[String: Any]], key: BRKey) {
		var key = key
		guard let tx = UnsafeMutablePointer<BRTransaction>() else { return }
		guard let wallet = walletManager.wallet else { return }
		guard let address = key.address() else { return }
		guard !wallet.containsAddress(address)
		else {
			return showErrorMessage(S.Import.Error.duplicate.localize())
		}
		let outputs = data.compactMap { SimpleUTXO(json: $0) }
		let balance = outputs.map { $0.satoshis }.reduce(0, +)
		for output in outputs {
			tx.addInput(txHash: output.hash, index: output.index, amount: output.satoshis, script: output.script)
		}

		let pubKeyLength = key.pubKey()?.count ?? 0
		let fee = wallet.feeForTxSize(tx.size + 34 + (pubKeyLength - 34) * tx.inputs.count)
		balanceActivity.dismiss(animated: true, completion: {
			guard !outputs.isEmpty, balance > 0
			else {
				return self.showErrorMessage(S.Import.Error.empty.localize())
			}
			guard fee + wallet.minOutputAmount <= balance
			else {
				return self.showErrorMessage(S.Import.Error.highFees.localize())
			}
			guard let rate = self.store.state.currentRate else { return }
			let balanceAmount = Amount(amount: balance, rate: rate, maxDigits: self.store.state.maxDigits)
			let feeAmount = Amount(amount: fee, rate: rate, maxDigits: self.store.state.maxDigits)
			let balanceText = self.store.state.isLtcSwapped ? balanceAmount.localCurrency : balanceAmount.bits
			let feeText = self.store.state.isLtcSwapped ? feeAmount.localCurrency : feeAmount.bits
			let message = String(format: S.Import.confirm.localize(), balanceText, feeText)
			let alert = UIAlertController(title: S.Import.title.localize(), message: message, preferredStyle: .alert)
			alert.addAction(UIAlertAction(title: S.Button.cancel.localize(), style: .cancel, handler: nil))
			alert.addAction(UIAlertAction(title: S.Import.importButton.localize(), style: .default, handler: { _ in
				self.publish(tx: tx, balance: balance, fee: fee, key: key)
			}))
			self.present(alert, animated: true, completion: nil)
		})
	}

	private func publish(tx: UnsafeMutablePointer<BRTransaction>, balance: UInt64, fee: UInt64, key: BRKey) {
		present(importingActivity, animated: true, completion: {
			guard let wallet = self.walletManager.wallet else { return }
			guard let script = BRAddress(string: wallet.receiveAddress)?.scriptPubKey else { return }
			tx.addOutput(amount: balance - fee, script: script)
			var keys = [key]
			_ = tx.sign(keys: &keys)

			guard tx.isSigned
			else {
				DispatchQueue.main.async {
					self.importingActivity.dismiss(animated: true, completion: {
						self.showErrorMessage(S.Import.Error.signing.localize())
					})
				}
				return
			}
			self.walletManager.peerManager?.publishTx(tx, completion: { [weak self] _, error in
				guard let myself = self else { return }
				DispatchQueue.main.async {
					myself.importingActivity.dismiss(animated: true, completion: {
						DispatchQueue.main.async {
							if let error = error {
								myself.showErrorMessage(error.localizedDescription)
								return
							}
							myself.showSuccess()
						}
					})
				}
			})
		})
	}

	private func showSuccess() {
		store.perform(action: SimpleReduxAlert.Show(.sweepSuccess(callback: { [weak self] in
			guard let myself = self else { return }
			myself.dismiss(animated: true, completion: nil)
		})))
	}

	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

extension Data {
	var reverse: Data {
		let tempBytes = Array([UInt8](self).reversed())
		return Data(bytes: tempBytes)
	}
}
