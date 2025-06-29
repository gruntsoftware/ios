import Firebase
import Combine
import LocalAuthentication
import SwiftUI
import UIKit

protocol LoginViewControllerDelegate {
	func didUnlockLogin()
}

class LoginViewController: UIViewController, Subscriber, Trackable {

	var walletManager: WalletManager?
	var shouldSelfDismiss = false
    var lockScreenView: LockScreenHostingController
    var delegate: LoginViewControllerDelegate?

	init(store: Store, isPresentedForLock: Bool, walletManager: WalletManager? = nil) {
		self.store = store
		self.walletManager = walletManager
		self.isPresentedForLock = isPresentedForLock

        lockScreenView = LockScreenHostingController(store: self.store)
		super.init(nibName: nil, bundle: nil)
	}

	deinit {
		store.unsubscribe(self)
	}

	// MARK: - Private
	private let store: Store
	private var backgroundView = UIView()
	private let isPresentedForLock: Bool
	private var unlockTimer: Timer?
	private var hasAttemptedToShowBiometrics = false
    private var cancellables = Set<AnyCancellable>()

	override func viewDidLoad() {
		addSubviews()
		addConstraints()
        self.view.backgroundColor = BrainwalletUIColor.surface
        backgroundView.backgroundColor = BrainwalletUIColor.surface
        addLockScreenHostingControllerCallbacks()
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		guard UIApplication.shared.applicationState != .background else { return }
		if shouldUseBiometrics, !hasAttemptedToShowBiometrics, !isPresentedForLock {
			hasAttemptedToShowBiometrics = true
			biometricsTapped()
		}
	}

	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		unlockTimer?.invalidate()
	}

    private func addLockScreenHostingControllerCallbacks() {
        lockScreenView.didEnterPIN = { [weak self] pin in
            guard let myself = self else { return }
            if pin.count == myself.store.state.pinLength {
                self?.authenticate(pin: pin)
            }
        }

        lockScreenView.didTapQR = { [weak self]  in
            guard let myself = self else { return }
            myself.showLTCAddress()
        }

        lockScreenView.didTapWipeWallet = { [weak self] userWantsToDelete in
            guard let myself = self else { return }

            if userWantsToDelete {
                myself.wipeWallet()
            }
        }

        lockScreenView.userDidPreferDarkMode = { [weak self] userDidPreferDarkMode in
            guard let myself = self else { return }
            myself.updateTheme(shouldBeDark: userDidPreferDarkMode)
        }
    }

	private func addSubviews() {
		view.addSubview(backgroundView)
		view.addSubview(lockScreenView.view)
	}

	private func addConstraints() {
		backgroundView.constrain(toSuperviewEdges: nil)
        lockScreenView.view.constrain([
            lockScreenView.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            lockScreenView.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            lockScreenView.view.topAnchor.constraint(equalTo: backgroundView.topAnchor),
            lockScreenView.view.heightAnchor.constraint(equalToConstant: view.frame.height)
		])
	}

    private func wipeWallet() {
                guard let walletManager = walletManager else {
                    return
                }

                let group = DispatchGroup()

                group.enter()
                DispatchQueue.walletQueue.async {
                    _ = walletManager.peerManager?.disconnect()
                    group.leave()
                }

                group.enter()
                DispatchQueue.walletQueue.async {
                    _ = walletManager.wipeWallet(pin: "forceWipe")
                    group.leave()
                }

                group.enter()
                DispatchQueue.walletQueue.asyncAfter(deadline: .now() + 1.0) {
                    _ = walletManager.deleteWalletDatabase(pin: "forceWipe")
                    group.leave()
                }

                group.notify(queue: .main) {
                    self.lockScreenView.walletWiped()
                    NotificationCenter.default.post(name: .walletDidWipeNotification, object: nil)
                }
    }

	private func authenticate(pin: String) {
		guard let walletManager = walletManager else { return }
        guard walletManager.authenticate(pin: pin) else {
            return authenticationFailed()
        }
		authenticationSucceded()
	}

	private func authenticationSucceded() {
		UIView.spring(0.6, delay: 0.4, animations: {
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
        lockScreenView.viewModel.authenticationFailed = true
        // TBD  Add Animation
        //		pinView.shake { [weak self] in
        //			self?.pinPadViewController.view.isUserInteractionEnabled = true
        //		}
        //		pinPadViewController.clear()
        //		DispatchQueue.main.asyncAfter(deadline: .now() + pinView.shakeDuration) { [weak self] in
        //			pinView.fill(0)
        //			self?.lockIfNeeded()
        //		}
    }

	private var shouldUseBiometrics: Bool {
		guard let walletManager = walletManager else { return false }
		return LAContext.canUseBiometrics && !walletManager.pinLoginRequired && store.state.isBiometricsEnabled
	}

	@objc func biometricsTapped() {
		guard !isWalletDisabled else { return }
		walletManager?.authenticate(biometricsPrompt: "Unlock your Brainwallet." , completion: { result in
			if result == .success {
				self.authenticationSucceded()
			}
		})
	}

    @objc func updateTheme(shouldBeDark: Bool) {
        UserDefaults.userPreferredDarkTheme = shouldBeDark
        NotificationCenter
            .default
            .post(name: .changedThemePreferenceNotification,
                object: nil)
    }

	@objc func showLTCAddress() {
		store.perform(action: RootModalActions.Present(modal: .loginAddress))
        self.lockScreenView.viewModel.shouldShowQR = false
	}

	private var isWalletDisabled: Bool {
		guard let walletManager = walletManager else { return false }
		let now = Date().timeIntervalSince1970
		return walletManager.walletDisabledUntil > now
	}

	@objc private func unlock() {
		saveEvent("login.unlocked")
		delegate?.didUnlockLogin()
		unlockTimer = nil
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
