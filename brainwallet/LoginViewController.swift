import Firebase
import Combine
import LocalAuthentication
import SwiftUI
import UIKit

private let squareButtonSize: CGFloat = 32.0
private let headerHeight: CGFloat = 180

protocol LoginViewControllerDelegate {
	func didUnlockLogin()
}

class LoginViewController: UIViewController, Subscriber, Trackable {
	// MARK: - Public

	var walletManager: WalletManager? {
		didSet {
			guard walletManager != nil else { return }
			pinView = PinView(style: .login, length: store.state.pinLength)
		}
	}

	var shouldSelfDismiss = false
    
    var lockScreenViewModel: LockScreenViewModel
    
    private var cancellables = Set<AnyCancellable>()


	init(store: Store, isPresentedForLock: Bool, walletManager: WalletManager? = nil) {
		self.store = store
		self.walletManager = walletManager
		self.isPresentedForLock = isPresentedForLock
		disabledView = WalletDisabledView(store: store)
		if walletManager != nil {
			pinView = PinView(style: .login, length: store.state.pinLength)
		}

        lockScreenViewModel = LockScreenViewModel(store: store)
		headerView = UIHostingController(rootView: LockScreenHeaderView(viewModel: lockScreenViewModel))
        footerView = UIHostingController(rootView: LockScreenFooterView(viewModel: lockScreenViewModel))
		super.init(nibName: nil, bundle: nil)
	}

	deinit {
		store.unsubscribe(self)
	}

	// MARK: - Private

	private let store: Store

	private var backgroundView = UIView()
		 

	private var headerView: UIHostingController<LockScreenHeaderView>
    private var footerView: UIHostingController<LockScreenFooterView>
    private let pinPadViewController = PinPadViewController(style: .clearPinPadStyle, keyboardType: .pinPad, maxDigits: 0)
	private let pinViewContainer = UIView()
	private var pinView: PinView?
	private let isPresentedForLock: Bool
	private let disabledView: WalletDisabledView
	private let activityView = UIActivityIndicatorView(style: .large)
	private let wipeBannerButton = UIButton()
    private let enterPINLabel = UILabel(font: .barlowSemiBold(size: 18), color: BrainwalletUIColor.content)
	private var pinPadBottom: NSLayoutConstraint?
	private var topControlTop: NSLayoutConstraint?
	private var unlockTimer: Timer?
	private var pinPadBackground = UIView()
	private var hasAttemptedToShowBiometrics = false
	private var isResetting = false
	private let versionLabel = UILabel(font: .barlowRegular(size: 12), color: BrainwalletUIColor.content)
	private var isWalletEmpty = false

	var delegate: LoginViewControllerDelegate?

	override func viewDidLoad() {
		checkWalletBalance()
		addSubviews()
		addConstraints()
        self.view.backgroundColor = BrainwalletUIColor.surface
        backgroundView.backgroundColor = BrainwalletUIColor.surface
        
		addPinPadCallback()
		if pinView != nil {
			addPinView()
		}
        
        lockScreenViewModel.$userPrefersDarkMode.sink { [weak self] newValue in
            
            self?.updateTheme(shouldBeDark: newValue)
            
        }.store(in: &cancellables)
        
        lockScreenViewModel.$userWantsToDelete.sink { [weak self] newBool in
            if newBool {
                self?.wipeTapped()
            }
        }.store(in: &cancellables)
        
        lockScreenViewModel.$userDidTapQR.sink { [weak self] newBool in
         
            if let didTap = newBool {
                self?.showLTCAddress()
            }
        }.store(in: &cancellables)
        
      
		disabledView.didTapReset = { [weak self] in
			guard let store = self?.store else { return }
			guard let walletManager = self?.walletManager else { return }
			self?.isResetting = true
			let nc = UINavigationController()
			let recover = EnterPhraseViewController(store: store, walletManager: walletManager, reason: .validateForResettingPin { phrase in
				let updatePin = UpdatePinViewController(store: store, walletManager: walletManager, type: .creationWithPhrase, showsBackButton: false, phrase: phrase)
				nc.pushViewController(updatePin, animated: true)
				updatePin.resetFromDisabledWillSucceed = {
					self?.disabledView.isHidden = true
				}
				updatePin.resetFromDisabledSuccess = {
					self?.authenticationSucceded()
					LWAnalytics.logEventWithParameters(itemName: ._20200217_DUWP)
				}
			})
			recover.addCloseNavigationItem()
			nc.viewControllers = [recover]
            nc.navigationBar.tintColor = BrainwalletUIColor.surface
			nc.navigationBar.titleTextAttributes = [
				NSAttributedString.Key.foregroundColor: BrainwalletUIColor.content,
				NSAttributedString.Key.font: UIFont.customBold(size: 17.0),
			]
			nc.setClearNavbar()
			nc.navigationBar.isTranslucent = false
            nc.navigationBar.barTintColor = BrainwalletUIColor.surface
			nc.viewControllers = [recover]
			self?.present(nc, animated: true, completion: nil)
		}
		store.subscribe(self, name: .loginFromSend, callback: { _ in
			self.authenticationSucceded()
		})
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		guard UIApplication.shared.applicationState != .background else { return }
		if shouldUseBiometrics, !hasAttemptedToShowBiometrics, !isPresentedForLock {
			hasAttemptedToShowBiometrics = true
			biometricsTapped()
		}

		if !isResetting {
			lockIfNeeded()
		}
	}

	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		unlockTimer?.invalidate()
	}

	private func addPinView() {
		guard let pinView = pinView else { return }
		pinViewContainer.addSubview(pinView)
        
		enterPINLabel.constrain([
			enterPINLabel.topAnchor.constraint(equalTo: pinView.topAnchor, constant: -40),
			enterPINLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
		])

		pinView.constrain([
			pinView.centerYAnchor.constraint(equalTo: pinPadViewController.view.topAnchor, constant: -70),
			pinView.centerXAnchor.constraint(equalTo: pinViewContainer.centerXAnchor),
			pinView.widthAnchor.constraint(equalToConstant: pinView.width),
			pinView.heightAnchor.constraint(equalToConstant: pinView.itemSize),
		])
	}

	private func addSubviews() {
		view.addSubview(backgroundView)
		view.addSubview(headerView.view)
		view.addSubview(pinViewContainer)
		view.addSubview(enterPINLabel)
        view.addSubview(footerView.view)

		pinPadBackground.backgroundColor = .clear
		if walletManager != nil {
			view.addSubview(pinPadBackground)
		} else {
			view.addSubview(activityView)
		}
	}

	private func addConstraints() {
		backgroundView.constrain(toSuperviewEdges: nil)
		headerView.view.constrain([
			headerView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			headerView.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			headerView.view.topAnchor.constraint(equalTo: backgroundView.topAnchor),
			headerView.view.heightAnchor.constraint(equalToConstant: headerHeight),
		])

		if walletManager != nil {
			addChildViewController(pinPadViewController, layout: {
				pinPadBottom = pinPadViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -140)
				pinPadViewController.view.constrain([
					pinPadViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
					pinPadViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
					pinPadBottom,
					pinPadViewController.view.heightAnchor.constraint(equalToConstant: pinPadViewController.height),
				])
			})
		}
		pinViewContainer.constrain(toSuperviewEdges: nil)

		if walletManager != nil {
			pinPadBackground.constrain([
				pinPadBackground.leadingAnchor.constraint(equalTo: pinPadViewController.view.leadingAnchor),
				pinPadBackground.trailingAnchor.constraint(equalTo: pinPadViewController.view.trailingAnchor),
				pinPadBackground.topAnchor.constraint(equalTo: pinPadViewController.view.topAnchor),
				pinPadBackground.bottomAnchor.constraint(equalTo: pinPadViewController.view.bottomAnchor),
			])
		} else {
			activityView.constrain([
				activityView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
				activityView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20.0),
			])
			activityView.startAnimating()
		}
        
        footerView.view.constrain([
            footerView.view.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -80),
            footerView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            footerView.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            footerView.view.heightAnchor.constraint(equalToConstant: 60.0),
        ])

		enterPINLabel.text = S.UnlockScreen.enterPIN.localize()
	}

	private func addPinPadCallback() {
		pinPadViewController.ouputDidUpdate = { [weak self] pin in
			guard let myself = self else { return }
			guard let pinView = self?.pinView else { return }
			let attemptLength = pin.utf8.count
			pinView.fill(attemptLength)
			self?.pinPadViewController.isAppendingDisabled = attemptLength < myself.store.state.pinLength ? false : true
			if attemptLength == myself.store.state.pinLength {
				self?.authenticate(pin: pin)
			}
		}
	}

	private func checkWalletBalance() {
		if let wallet = walletManager?.wallet {
			if wallet.balance == 0 {
				isWalletEmpty = true
			} else {
				isWalletEmpty = false
			}
		}
	}

	private func authenticate(pin: String) {
		guard let walletManager = walletManager else { return }
		guard !E.isScreenshots else { return authenticationSucceded() }
		guard walletManager.authenticate(pin: pin) else { return authenticationFailed() }
		authenticationSucceded()
		LWAnalytics.logEventWithParameters(itemName: ._20200217_DUWP)
	}

	private func authenticationSucceded() {
		saveEvent("login.success")
		let label = UILabel(font: enterPINLabel.font)
        label.textColor = BrainwalletUIColor.content
		label.text = S.UnlockScreen.unlocked.localize()
		let lock = UIImageView(image: #imageLiteral(resourceName: "unlock"))
		lock.transform = .init(scaleX: 0.6, y: 0.6)

		if let _pinView = pinView {
			enterPINLabel.removeFromSuperview()
			_pinView.removeFromSuperview()
		}

		view.addSubview(label)
		view.addSubview(lock)

		label.constrain([
			label.bottomAnchor.constraint(equalTo: view.centerYAnchor, constant: -C.padding[1]),
			label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
		])
		lock.constrain([
			lock.topAnchor.constraint(equalTo: label.bottomAnchor, constant: C.padding[1]),
			lock.centerXAnchor.constraint(equalTo: label.centerXAnchor),
		])
		view.layoutIfNeeded()


		UIView.spring(0.6, delay: 0.4, animations: {
			self.pinPadBottom?.constant = self.pinPadViewController.height
			self.topControlTop?.constant = -100.0

			lock.alpha = 0.0
			label.alpha = 0.0
			self.wipeBannerButton.alpha = 0.0
			self.enterPINLabel.alpha = 0.0
			self.pinView?.alpha = 0.0

			self.view.layoutIfNeeded()
		}) { _ in
			self.delegate?.didUnlockLogin()
			if self.shouldSelfDismiss {
				self.dismiss(animated: true, completion: nil)
			}
			self.store.perform(action: LoginSuccess())
			self.store.trigger(name: .showStatusBar)
		}
	}

	private func authenticationFailed() {
		saveEvent("login.failed")
		guard let pinView = pinView else { return }
		pinPadViewController.view.isUserInteractionEnabled = false
		pinView.shake { [weak self] in
			self?.pinPadViewController.view.isUserInteractionEnabled = true
		}
		pinPadViewController.clear()
		DispatchQueue.main.asyncAfter(deadline: .now() + pinView.shakeDuration) { [weak self] in
			pinView.fill(0)
			self?.lockIfNeeded()
		}
	}

	private var shouldUseBiometrics: Bool {
		guard let walletManager = walletManager else { return false }
		return LAContext.canUseBiometrics && !walletManager.pinLoginRequired && store.state.isBiometricsEnabled
	}

	@objc func biometricsTapped() {
		guard !isWalletDisabled else { return }
		walletManager?.authenticate(biometricsPrompt: S.UnlockScreen.touchIdPrompt.localize(), completion: { result in
			if result == .success {
				self.authenticationSucceded()
				LWAnalytics.logEventWithParameters(itemName: ._20200217_DUWB)
			}
		})
	}

    @objc func updateTheme(shouldBeDark: Bool) {
        UserDefaults.standard.set(shouldBeDark, forKey: userDidPreferDarkModeKey)
        UserDefaults.standard.synchronize()
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        appDelegate.updatePreferredTheme()
    }
    
	@objc func showLTCAddress() {
		guard !isWalletDisabled else { return }
		store.perform(action: RootModalActions.Present(modal: .loginAddress))
        
        self.lockScreenViewModel.userDidTapQR = nil
	}

	@objc func wipeTapped() {
		store.perform(action: RootModalActions.Present(modal: .wipeEmptyWallet))
	}

	private func lockIfNeeded() {
		if let disabledUntil = walletManager?.walletDisabledUntil {
			let now = Date().timeIntervalSince1970
			if disabledUntil > now {
				let disabledUntilDate = Date(timeIntervalSince1970: disabledUntil)
				let unlockInterval = disabledUntil - now
				let df = DateFormatter()
				df.setLocalizedDateFormatFromTemplate(unlockInterval > C.secondsInDay ? "h:mm:ss a MMM d, yyy" : "h:mm:ss a")

				disabledView.setTimeLabel(string: String(format: S.UnlockScreen.disabled.localize(), df.string(from: disabledUntilDate)))

				pinPadViewController.view.isUserInteractionEnabled = false
				unlockTimer?.invalidate()
				unlockTimer = Timer.scheduledTimer(timeInterval: unlockInterval, target: self, selector: #selector(LoginViewController.unlock), userInfo: nil, repeats: false)

				if disabledView.superview == nil {
					view.addSubview(disabledView)
					setNeedsStatusBarAppearanceUpdate()
					disabledView.constrain(toSuperviewEdges: nil)
					disabledView.show()
				}
			} else {
				pinPadViewController.view.isUserInteractionEnabled = true
				disabledView.hide { [weak self] in
					self?.disabledView.removeFromSuperview()
					self?.setNeedsStatusBarAppearanceUpdate()
				}
			}
		}
	}

	private var isWalletDisabled: Bool {
		guard let walletManager = walletManager else { return false }
		let now = Date().timeIntervalSince1970
		return walletManager.walletDisabledUntil > now
	}

	@objc private func unlock() {
		saveEvent("login.unlocked")
		delegate?.didUnlockLogin()
		enterPINLabel.pushNewText(S.UnlockScreen.enterPIN.localize())
		pinPadViewController.view.isUserInteractionEnabled = true
		unlockTimer = nil
		disabledView.hide { [weak self] in
			self?.disabledView.removeFromSuperview()
			self?.setNeedsStatusBarAppearanceUpdate()
		}
	}

	override var preferredStatusBarStyle: UIStatusBarStyle {
		if disabledView.superview == nil {
			return .lightContent
		} else {
			return .default
		}
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
