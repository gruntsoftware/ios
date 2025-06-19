import BRCore
import MachO
import SwiftUI
import UIKit

class MainViewController: UIViewController, Subscriber, LoginViewControllerDelegate {
	// MARK: - Private

	private let store: Store
	private let blurView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
	private var isLoginRequired = false
	private let loginView: LoginViewController
    private var settingsViewController: SettingsHostingController?
	private let loginTransitionDelegate = LoginTransitionDelegate()
    var showSettingsConstant: CGFloat = 0.0
    var settingsViewPlacement: CGFloat = 0.0
    var shouldShowSettings: Bool = true

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
		view.backgroundColor = BrainwalletUIColor.surface

		navigationController?.navigationBar.tintColor = BrainwalletUIColor.surface
		navigationController?.navigationBar.titleTextAttributes = [
			NSAttributedString.Key.foregroundColor: BrainwalletUIColor.content,
			NSAttributedString.Key.font: UIFont.customBold(size: 17.0)
		]

		navigationController?.navigationBar.isTranslucent = false
		navigationController?.navigationBar.barTintColor = BrainwalletUIColor.surface
		loginView.delegate = self

		NotificationCenter.default.addObserver(forName: UserDefaults.didChangeNotification,
		                                       object: nil,
		                                       queue: nil) { _ in
			if UserDefaults.writePaperPhraseDate != nil {

            }
		}

		addSubscriptions()
		addAppLifecycleNotificationEvents()
		addTemporaryStartupViews()
	}

    func didUnlockLogin() {

        guard let walletManager = self.walletManager
        else {
            return
        }

        guard let tabVC = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "TabBarViewController")
                as? TabBarViewController
        else {
            NSLog("TabBarViewController not intialized")
            return
        }

        tabVC.store = store
        tabVC.walletManager = walletManager

        addChildViewController(tabVC, layout: {
            // Setup constraints
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

        settingsViewController = SettingsHostingController(store: store, walletManager: walletManager)
        guard let settingsHC = settingsViewController else {
            return
        }

        settingsViewPlacement = self.view.frame.width
        showSettingsConstant = 0
        addChildViewController(settingsHC, layout: {
            settingsHC.view.translatesAutoresizingMaskIntoConstraints = false
                   NSLayoutConstraint.activate([
                    settingsHC.view.topAnchor.constraint(equalTo: view.topAnchor),
                    settingsHC.view.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant:  settingsViewPlacement - showSettingsConstant),
                    settingsHC.view.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: settingsViewPlacement - showSettingsConstant),
                    settingsHC.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
                   ])
            settingsHC.view.layoutIfNeeded()
        })

        tabVC.didTapSettingsButton = { [weak self]  in
            guard let mySelf = self else { return }
            guard let settingsHC = mySelf.settingsViewController else { return }
            if mySelf.shouldShowSettings {
                mySelf.showSettingsConstant = 70.0
                mySelf.settingsViewPlacement = 0
                UIView.animate(withDuration: 0.9, delay: 0.1, options: .curveEaseInOut, animations: {
                    NSLayoutConstraint.activate([
                        settingsHC.view.topAnchor.constraint(equalTo: mySelf.view.topAnchor),
                        settingsHC.view.leadingAnchor.constraint(equalTo: mySelf.view.leadingAnchor,
                                                                 constant: mySelf.settingsViewPlacement - mySelf.showSettingsConstant),
                        settingsHC.view.trailingAnchor.constraint(equalTo: mySelf.view.trailingAnchor,
                                                                  constant:  mySelf.settingsViewPlacement - mySelf.showSettingsConstant),
                        settingsHC.view.bottomAnchor.constraint(equalTo: mySelf.view.bottomAnchor)
                    ])
                    settingsHC.view.layoutIfNeeded()
                }) { _ in
                    mySelf.shouldShowSettings = false
                }
            } else {
                mySelf.settingsViewPlacement = mySelf.view.frame.width
                mySelf.showSettingsConstant = 0
                UIView.animate(withDuration: 0.9, delay: 0.1, options: .curveEaseInOut, animations: {
                    NSLayoutConstraint.activate([
                        settingsHC.view.topAnchor.constraint(equalTo: mySelf.view.topAnchor),
                        settingsHC.view.leadingAnchor.constraint(equalTo: mySelf.view.leadingAnchor,
                                                                 constant: mySelf.settingsViewPlacement - mySelf.showSettingsConstant),
                        settingsHC.view.trailingAnchor.constraint(equalTo: mySelf.view.trailingAnchor,
                                                                  constant: mySelf.settingsViewPlacement - mySelf.showSettingsConstant),
                        settingsHC.view.bottomAnchor.constraint(equalTo: mySelf.view.bottomAnchor)
                    ])
                    settingsHC.view.layoutIfNeeded()
                }) { _ in
                    mySelf.shouldShowSettings = true
                }
            }
        }

        UIView.animate(withDuration: 0.3, delay: 0.1, options: .transitionCrossDissolve, animations: {
            tabVC.view.alpha = 1
        }) { _ in
        }
        // STASH FOR NEW UI
        //        let newMainViewHostingController = NewMainHostingController(store: self.store, walletManager: walletManager)
        //
        //        addChildViewController(newMainViewHostingController, layout: {
        //            newMainViewHostingController.view.constrain(toSuperviewEdges: nil)
        //            newMainViewHostingController.view.layoutIfNeeded()
        //        }}
    }

	private func addTemporaryStartupViews() {
		guardProtected(queue: DispatchQueue.main) {
			if !WalletManager.staticNoWallet {

			} else {
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
	}

	private func addAppLifecycleNotificationEvents() {
		NotificationCenter.default.addObserver(forName: UIScene.didActivateNotification, object: nil, queue: nil) { _ in
			UIView.animate(withDuration: 0.1, animations: {
				self.blurView.alpha = 0.0
			}, completion: { [weak self] _ in
				self?.blurView.removeFromSuperview()
			})
		}

		NotificationCenter.default.addObserver(forName: UIScene.willDeactivateNotification, object: nil, queue: nil) { [weak self] _ in

			if let mySelf = self,
               !mySelf.isLoginRequired, !mySelf.store.state.isPromptingBiometrics {
                mySelf.blurView.alpha = 1.0
                mySelf.view.addSubview(mySelf.blurView)
                mySelf.blurView.constrain(toSuperviewEdges: nil)
			}
		}
	}

	override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
		return .fade
	}

	override var preferredStatusBarStyle: UIStatusBarStyle {
		return .lightContent
	}

	@available(*, unavailable)
	required init?(coder _: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
