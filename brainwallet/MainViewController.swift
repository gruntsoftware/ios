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
	private let tempLoginView: LoginViewController
    var tabController: TabBarViewController
    private let settingsViewController: SettingsHostingController
	private let loginTransitionDelegate = LoginTransitionDelegate()

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
					self.tempLoginView.remove()
				})
			}
		}
	}

	init(store: Store) {
		self.store = store
		loginView = LoginViewController(store: store, isPresentedForLock: false)
		tempLoginView = LoginViewController(store: store, isPresentedForLock: false)
        tabController = TabBarViewController()
        settingsViewController = SettingsHostingController(store: store)
		super.init(nibName: nil, bundle: nil)
	}

	override func viewDidLoad() {
		view.backgroundColor = BrainwalletUIColor.surface

		navigationController?.navigationBar.tintColor = BrainwalletUIColor.surface
		navigationController?.navigationBar.titleTextAttributes = [
			NSAttributedString.Key.foregroundColor: BrainwalletUIColor.content,
			NSAttributedString.Key.font: UIFont.customBold(size: 17.0),
		]

		navigationController?.navigationBar.isTranslucent = false
		navigationController?.navigationBar.barTintColor = BrainwalletUIColor.surface
		loginView.delegate = self

		NotificationCenter.default.addObserver(forName: UserDefaults.didChangeNotification,
		                                       object: nil,
		                                       queue: nil)
		{ _ in
			if UserDefaults.writePaperPhraseDate != nil
			{
                
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
            debugPrint("::: TabBarViewController not intialized")
            return
        }
        tabController  = tabVC
        tabController.store = store
        tabController.walletManager = walletManager
        settingsViewController.store = store
        
        addChildViewController(settingsViewController, layout: {
            settingsViewController.view.constrain(toSuperviewEdges: nil)
            settingsViewController.view.alpha = 0
            settingsViewController.view.layoutIfNeeded()
        })
        
        addChildViewController(tabController, layout: {
            tabController.view.constrain(toSuperviewEdges: nil)
            tabController.view.alpha = 0
            tabController.view.layoutIfNeeded()
        })
        
        tabController.userTappedSettingsButton  = { [weak self] shouldShow in
            let mainViewWidth = self?.view.frame.width ?? 200.0
            if shouldShow {
                UIView.animate(withDuration: 0.3) {
                    self?.tabController.view.transform = CGAffineTransform(translationX: mainViewWidth * 0.85, y: 0)
                    self?.settingsViewController.view.alpha = 1
                }
            } else {
                UIView.animate(withDuration: 0.3) {
                    self?.tabController.view.transform = .identity
                    self?.settingsViewController.view.alpha = 0
                }
             }
            self?.tabController.view.layoutIfNeeded()
        }

        UIView.animate(withDuration: 0.3, delay: 0.1, options: .transitionCrossDissolve, animations: {
            self.tabController.view.alpha = 1
        }) { _ in
            debugPrint("::: US MainView Controller presented")
        }
	}

	private func addTemporaryStartupViews() {
		guardProtected(queue: DispatchQueue.main) {
			if !WalletManager.staticNoWallet {
				self.addChildViewController(self.tempLoginView, layout: {
					self.tempLoginView.view.constrain(toSuperviewEdges: nil)
				})
			} else {
				// Adds a brainwalletBlue card view the hides work while thread finishes
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
			}, completion: { _ in
				self.blurView.removeFromSuperview()
			})
		}

		NotificationCenter.default.addObserver(forName: UIScene.willDeactivateNotification, object: nil, queue: nil) { _ in
			if !self.isLoginRequired, !self.store.state.isPromptingBiometrics {
				self.blurView.alpha = 1.0
				self.view.addSubview(self.blurView)
				self.blurView.constrain(toSuperviewEdges: nil)
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
