import BRCore
import MachO
import SwiftUI
import UIKit

class MainViewController: UIViewController, Subscriber, LoginViewControllerDelegate {
	private let store: Store
	private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
	private var isLoginRequired = false
    private var startHostingController: StartHostingController?
    private let loginView: LoginViewController
    private var settingsViewController: SettingsHostingController?
	private let loginTransitionDelegate = LoginTransitionDelegate()
    var showSettingsConstant: CGFloat = 0.0
    var settingsViewPlacement: CGFloat = 0.0
    var shouldShowSettings: Bool = true
    var barShouldBeHidden = false
    var settingsLeadingConstraint = NSLayoutConstraint()
    var settingsTrailingConstraint = NSLayoutConstraint()
    private let clickSound = "click_sound"
	let appDelegate = UIApplication.shared.delegate as! AppDelegate

	var walletManager: WalletManager? {
		didSet {
			guard let walletManager = walletManager else { return }

			if !walletManager.noWallet {
				loginView.walletManager = walletManager
				loginView.transitioningDelegate = loginTransitionDelegate
				loginView.modalPresentationStyle = .overFullScreen
				loginView.modalPresentationCapturesStatusBarAppearance = true
				loginView.shouldSelfDismiss = true
				present(loginView, animated: false, completion: {
				})
			}
		}
	}

	init(store: Store) {
		self.store = store
		loginView = LoginViewController(store: store, isPresentedForLock: false)
		super.init(nibName: nil, bundle: nil)
	}

	override func viewDidLoad() {
        loginView.delegate = self
        /// Set colors
		view.backgroundColor = BrainwalletUIColor.surface
		navigationController?.navigationBar.tintColor = BrainwalletUIColor.surface
		navigationController?.navigationBar.titleTextAttributes = [
			NSAttributedString.Key.foregroundColor: BrainwalletUIColor.content,
			NSAttributedString.Key.font: UIFont.customBold(size: 17.0)
		]
		navigationController?.navigationBar.isTranslucent = false
		navigationController?.navigationBar.barTintColor = BrainwalletUIColor.surface
		addSubscriptions()
		addTemporaryStartupViews()
        activateSettingsDrawer(shouldClose: false)
	}
    func startOnboarding() {
        guard let walletManager = self.walletManager else { return }
        startHostingController = StartHostingController(store: self.store,
            walletManager: walletManager)
        guard let startHC = self.startHostingController else { return }
        addChildViewController(startHC, layout: {
            startHC.view.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    startHC.view.topAnchor.constraint(equalTo: view.topAnchor),
                    startHC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
                    startHC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
                    startHC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor) ])
            startHC.view.alpha = 0
            startHC.view.layoutIfNeeded()
        })
        UIView.animate(withDuration: 0.3, delay: 0.1, options: .transitionCrossDissolve, animations: {
            startHC.view.alpha = 1
        }) { _ in
        }
    }
    /// This or that
    //// This is a legacy redux method of triggering adctions versus delegation
    func didCompleteOnboarding() {
        self.presentLockScreen()
    }

    func didUnlockLogin() {
        /// Remove Onboarding
        children.forEach { childVC in
            if childVC.isKind(of: StartHostingController.self) {
                childVC.willMove(toParent: nil)
                childVC.view.removeFromSuperview()
                childVC.removeFromParent()
            }
        }

        guard let tabVC = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "TabBarViewController")
                as? TabBarViewController, let walletManager = self.walletManager
        else {
            debugPrint("::: ERROR: TabBarViewController or wallet not intialized")
            return }

        tabVC.store = store
        tabVC.walletManager = walletManager
        addChildViewController(tabVC, layout: {
            tabVC.view.translatesAutoresizingMaskIntoConstraints = false
                   NSLayoutConstraint.activate([
                    tabVC.view.topAnchor.constraint(equalTo: view.topAnchor),
                    tabVC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
                    tabVC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0),
                    tabVC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
                   ])
            tabVC.view.alpha = 0
            tabVC.view.layoutIfNeeded()
        })

        settingsViewController = SettingsHostingController(store: store,
                                                           walletManager: walletManager)
        guard let settingsHC = settingsViewController else { return }

        /// Reset the settings so when lock happens drawer is closed
        settingsHC.resetSettingsDrawer = { [weak self] in
            self?.activateSettingsDrawer(shouldClose: false)
            self?.store.trigger(name: .lock)
        }

        /// Settings constant setup
        settingsViewPlacement = -self.view.frame.width
        showSettingsConstant = 0

        addChildViewController(settingsHC, layout: {
            settingsHC.view.translatesAutoresizingMaskIntoConstraints = false

            // Create and store constraint references
            settingsLeadingConstraint = settingsHC.view.leadingAnchor.constraint(
                equalTo: view.leadingAnchor,
                constant: settingsViewPlacement - showSettingsConstant
            )
            settingsTrailingConstraint = settingsHC.view.trailingAnchor.constraint(
                equalTo: view.trailingAnchor,
                constant: settingsViewPlacement - showSettingsConstant
            )

            NSLayoutConstraint.activate([
                settingsHC.view.topAnchor.constraint(equalTo: view.topAnchor),
                settingsLeadingConstraint,
                settingsTrailingConstraint,
                settingsHC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            ])
            settingsHC.view.layoutIfNeeded()
        })

        tabVC.didTapSettingsButton = { [weak self]  in
            self?.activateSettingsDrawer()
        }

        UIView.animate(withDuration: 0.3, delay: 0.1, options: .transitionCrossDissolve, animations: {
            tabVC.view.alpha = 1
        }) { _ in
        }

        // STASH FOR NEW UI
        //        let newMainViewHostingController = NewMainHostingController(store: self.store, walletManager: walletManager)
        //        addChildViewController(newMainViewHostingController, layout: {
        //            newMainViewHostingController.view.constrain(toSuperviewEdges: nil)
        //            newMainViewHostingController.view.layoutIfNeeded()
        //        }}
    }

    func activateSettingsDrawer(shouldClose: Bool? = nil) {
        var shouldShow = shouldShowSettings
        if let closeState = shouldClose {
            shouldShow = closeState
        }

        if shouldShow {
            self.showSettingsConstant = 65.0
            self.settingsViewPlacement = 0.0
            self.barShouldBeHidden = true

            self.setNeedsStatusBarAppearanceUpdate()
            // Update existing constraints
            self.settingsLeadingConstraint.constant = self.settingsViewPlacement - self.showSettingsConstant
            self.settingsTrailingConstraint.constant = self.settingsViewPlacement - self.showSettingsConstant

            UIView.animate(withDuration: 0.2, delay: 0.0, options: .curveEaseIn, animations: {
                self.view.layoutIfNeeded()
                // TBD: Sound not ideal..in progress
                // _ = SoundsHelper.play(filename: "clicksound", type: "mp3")
            }) { _ in self.shouldShowSettings = false }

        } else {
            // Hide settings (slide out to right)
            self.settingsViewPlacement = -self.view.frame.width
            self.showSettingsConstant = 0
            self.barShouldBeHidden = false

            self.setNeedsStatusBarAppearanceUpdate()
            // Update existing constraints
            self.settingsLeadingConstraint.constant = self.settingsViewPlacement - self.showSettingsConstant
            self.settingsTrailingConstraint.constant = self.settingsViewPlacement - self.showSettingsConstant

            UIView.animate(withDuration: 0.1, delay: 0.1, options: .curveEaseOut, animations: {
                self.view.layoutIfNeeded()
                // TBD: Sound not ideal..in progress
                // _ = SoundsHelper.play(filename: "clicksound", type: "mp3")
            }) { _ in self.shouldShowSettings = true }
        }
    }

	private func addTemporaryStartupViews() {
		guardProtected(queue: DispatchQueue.main) {
			if WalletManager.staticNoWallet {
				// Adds a  card view the hides work while thread finishes
				let launchView = LaunchCardHostingController()
				self.addChildViewController(launchView, layout: {
					launchView.view.constrain(toSuperviewEdges: nil)
					launchView.view.isUserInteractionEnabled = false
				})
				DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
					launchView.remove()
				}
			}
		}
	}

	private func addSubscriptions() {
		store.subscribe(self, selector: { $0.isLoginRequired != $1.isLoginRequired },
		                callback: { self.isLoginRequired = $0.isLoginRequired
		                })

        /// This or that
        //// This is a legacy redux method of triggering adctions versus delegation
        store.subscribe(self, name: .lock,
                        callback: { [weak self] _ in
                            Task { @MainActor in
                                self?.presentLockScreen()
                            }
                        })
	}

    private func presentLockScreen() {

        loginView.walletManager = walletManager
        loginView.transitioningDelegate = loginTransitionDelegate
        loginView.modalPresentationStyle = .overFullScreen
        loginView.modalPresentationCapturesStatusBarAppearance = true
        loginView.shouldSelfDismiss = true
        loginView.view.alpha = 1
        present(loginView, animated: false, completion: { })
    }

	override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
		return .fade
	}

    override var prefersStatusBarHidden: Bool {
        return barShouldBeHidden
    }

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
