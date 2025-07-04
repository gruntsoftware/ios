import Foundation
import UIKit
import SwiftUI

class TabBarViewController: UIViewController, Subscriber, Trackable, UITabBarDelegate {
	let kInitialChildViewControllerIndex = 2 // Buy / Receive
	@IBOutlet var headerView: UIView!
	@IBOutlet var containerView: UIView!
	@IBOutlet var tabBar: UITabBar!
	@IBOutlet var settingsButton: UIButton!
	@IBOutlet var walletBalanceLabel: UILabel!

	var primaryBalanceLabel: UpdatingLabel?
	var secondaryBalanceLabel: UpdatingLabel?
	private let largeFontSize: CGFloat = 24.0
	private let smallFontSize: CGFloat = 12.0
	private var hasInitialized = false
    private var canUserBuy = false
	private let dateFormatter = DateFormatter()
	private let equalsLabel = UILabel(font: .barlowMedium(size: 12), color: BrainwalletUIColor.content)
	private var regularConstraints: [NSLayoutConstraint] = []
	private var swappedConstraints: [NSLayoutConstraint] = []
	private let currencyTapView = UIView()
	private let storyboardNames: [String] = ["Send","Transactions","Receive"]
	var storyboardIDs: [String] = ["SendLTCViewController", "TransactionsViewController", "ReceiveLTCViewController"]
	var viewControllers: [UIViewController] = []
	var activeController: UIViewController?
    var receiveHostingController: ReceiveHostingController?
    var buyReceiveHostingController: BuyReceiveHostingController?

	var updateTimer: Timer?
	var store: Store?
	var walletManager: WalletManager?
	var exchangeRate: Rate? {
		didSet { setBalances() }
	}

	private var balance: UInt64 = 0 {
		didSet { setBalances() }
	}

	var isLtcSwapped: Bool? {
		didSet { setBalances() }
	}

	@IBAction func showSettingsAction(_: Any) {
		guard let store = store
		else {
			debugPrint("::: ERROR: Store not set")
			return
		}
		store.perform(action: RootModalActions.Present(modal: .menu))
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		setupModels()
		setupViews()
		configurePriceLabels()
		addSubscriptions()
		dateFormatter.setLocalizedDateFormatFromTemplate("MMM d, h:mm a")

		addViewControllers()

		updateTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { _ in
			self.setBalances()
		}

		guard let array = tabBar.items
		else {
			NSLog("ERROR: no items found")
			return
		}
		tabBar.selectedItem = array[kInitialChildViewControllerIndex]

		NotificationCenter.default.addObserver(self, selector: #selector(languageChanged), name: .languageChangedNotification, object: nil)
	}

	deinit {
		NotificationCenter.default.removeObserver(self, name: .languageChangedNotification, object: nil)
		self.updateTimer = nil
	}

	@objc
	func languageChanged() {
		walletBalanceLabel.text = String(localized: "Balance :", bundle: .main)
		localizeTabBar()
		viewControllers = []
		addViewControllers()
		guard let array = tabBar.items else { return }
		tabBar.selectedItem = array[kInitialChildViewControllerIndex]
		displayContentController(contentController: viewControllers[0])
	}

	func addViewControllers() {
		for (index, storyboardID) in storyboardIDs.enumerated() {
				let controller = UIStoryboard(name: storyboardNames[index], bundle: nil)
                .instantiateViewController(withIdentifier: storyboardID)
				viewControllers.append(controller)
        }
	}

	private func setupModels() {
		guard let store = store else { return }

		isLtcSwapped = store.state.isLtcSwapped

		if let rate = store.state.currentRate {
			exchangeRate = rate
			let placeholderAmount = Amount(amount: 0, rate: rate, maxDigits: store.state.maxDigits)
			secondaryBalanceLabel = UpdatingLabel(formatter: placeholderAmount.localFormat)
			primaryBalanceLabel = UpdatingLabel(formatter: placeholderAmount.ltcFormat)
		} else {
			secondaryBalanceLabel = UpdatingLabel(formatter: NumberFormatter())
			primaryBalanceLabel = UpdatingLabel(formatter: NumberFormatter())
		}

	}

	private func setupViews() {
		walletBalanceLabel.text = String(localized: "Balance :", bundle: .main)

        settingsButton.imageView?.tintColor = BrainwalletUIColor.content

		headerView.backgroundColor = BrainwalletUIColor.surface

        tabBar.barTintColor = BrainwalletUIColor.surface
        tabBar.backgroundColor = BrainwalletUIColor.surface
        tabBar.tintColor = BrainwalletUIColor.content
        tabBar.unselectedItemTintColor = BrainwalletUIColor.content.withAlphaComponent(0.3)

		containerView.backgroundColor = BrainwalletUIColor.surface
		view.backgroundColor = BrainwalletUIColor.surface
	}

	private func configurePriceLabels() {
		// TODO: Debug the reizing of label...very important
		guard let primaryLabel = primaryBalanceLabel,
		      let secondaryLabel = secondaryBalanceLabel
		else {
			debugPrint("::: ERROR: Price labels not initialized")
			return
		}

		let priceLabelArray = [primaryBalanceLabel, secondaryBalanceLabel, equalsLabel, walletBalanceLabel]

		for (_, view) in priceLabelArray.enumerated() {
            view?.backgroundColor = BrainwalletUIColor.surface
            view?.textColor = BrainwalletUIColor.content
		}

		primaryLabel.font = UIFont.barlowSemiBold(size: largeFontSize)
		secondaryLabel.font = UIFont.barlowSemiBold(size: largeFontSize)

		equalsLabel.text = "="
		headerView.addSubview(primaryLabel)
		headerView.addSubview(secondaryLabel)
		headerView.addSubview(equalsLabel)
		headerView.addSubview(currencyTapView)

		secondaryLabel.constrain([
			secondaryLabel.constraint(.firstBaseline, toView: primaryLabel, constant: 0.0)
		])

		equalsLabel.translatesAutoresizingMaskIntoConstraints = false
		primaryLabel.translatesAutoresizingMaskIntoConstraints = false
		regularConstraints = [
			primaryLabel.firstBaselineAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -12),
			primaryLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: C.padding[1] * 1.25),
			equalsLabel.firstBaselineAnchor.constraint(equalTo: primaryLabel.firstBaselineAnchor, constant: 0),
			equalsLabel.leadingAnchor.constraint(equalTo: primaryLabel.trailingAnchor, constant: C.padding[1] / 2.0),
			secondaryLabel.leadingAnchor.constraint(equalTo: equalsLabel.trailingAnchor, constant: C.padding[1] / 2.0)
		]

		swappedConstraints = [
			secondaryLabel.firstBaselineAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -12),
			secondaryLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: C.padding[1] * 1.25),
			equalsLabel.firstBaselineAnchor.constraint(equalTo: secondaryLabel.firstBaselineAnchor, constant: 0),
			equalsLabel.leadingAnchor.constraint(equalTo: secondaryLabel.trailingAnchor, constant: C.padding[1] / 2.0),
			primaryLabel.leadingAnchor.constraint(equalTo: equalsLabel.trailingAnchor, constant: C.padding[1] / 2.0)
		]

		if let isLTCSwapped = isLtcSwapped {
			NSLayoutConstraint.activate(isLTCSwapped ? swappedConstraints : regularConstraints)
		}

		currencyTapView.constrain([
			currencyTapView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 0),
			currencyTapView.trailingAnchor.constraint(equalTo: settingsButton.leadingAnchor, constant: -C.padding[5]),
			currencyTapView.topAnchor.constraint(equalTo: primaryLabel.topAnchor, constant: 0),
			currencyTapView.bottomAnchor.constraint(equalTo: primaryLabel.bottomAnchor, constant: C.padding[1])
		])

		let gr = UITapGestureRecognizer(target: self, action: #selector(currencySwitchTapped))
		currencyTapView.addGestureRecognizer(gr)
	}

	/// This is called when the price changes
	private func setBalances() {
		guard let rate = exchangeRate, let store = store, let isLTCSwapped = isLtcSwapped
		else {
			NSLog("ERROR: Rate, Store not initialized")
			return
		}
		guard let primaryLabel = primaryBalanceLabel,
		      let secondaryLabel = secondaryBalanceLabel
		else {
			NSLog("ERROR: Price labels not initialized")
			return
		}

		let amount = Amount(amount: balance, rate: rate, maxDigits: store.state.maxDigits)

		if !hasInitialized {
			let amount = Amount(amount: balance, rate: exchangeRate!, maxDigits: store.state.maxDigits)
			NSLayoutConstraint.deactivate(isLTCSwapped ? regularConstraints : swappedConstraints)
			NSLayoutConstraint.activate(isLTCSwapped ? swappedConstraints : regularConstraints)
			primaryLabel.setValue(amount.amountForLtcFormat)
			secondaryLabel.setValue(amount.localAmount)
			if isLTCSwapped {
				primaryLabel.transform = transform(forView: primaryLabel)
			} else {
				secondaryLabel.transform = transform(forView: secondaryLabel)
			}
			hasInitialized = true
		} else {
			if primaryLabel.isHidden {
				primaryLabel.isHidden = false
			}

			if secondaryLabel.isHidden {
				secondaryLabel.isHidden = false
			}
		}

		primaryLabel.setValue(amount.amountForLtcFormat)
		secondaryLabel.setValue(amount.localAmount)

		if !isLTCSwapped {
			primaryLabel.transform = .identity
			secondaryLabel.transform = transform(forView: secondaryLabel)
		} else {
			secondaryLabel.transform = .identity
			primaryLabel.transform = transform(forView: primaryLabel)
		}
	}

	/// Transform LTC and Fiat  Balances
	/// - Parameter forView: Views
	/// - Returns: the inverse transform
	private func transform(forView: UIView) -> CGAffineTransform {
		forView.transform = .identity
		let scaleFactor: CGFloat = smallFontSize / largeFontSize
		let deltaX = forView.frame.width * (1 - scaleFactor)
		let deltaY = forView.frame.height * (1 - scaleFactor)
		let scale = CGAffineTransform(scaleX: scaleFactor, y: scaleFactor)
		return scale.translatedBy(x: -deltaX, y: deltaY / 2.0)
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		localizeTabBar()
	}

	func localizeTabBar() {
		guard let array = tabBar.items
		else {
			NSLog("ERROR: no items found")
			return
		}

        /// To show all more compex state (Buy or Receive) toggle here for dev
        canUserBuy = UserDefaults.standard.object(forKey: userCurrentLocaleMPApprovedKey) as? Bool ?? false
		for item in array {
			switch item.tag {
			case 0: item.title = String(localized: "Send")
			case 1: item.title = String(localized: "History")
            case 2: item.title = canUserBuy ? String(localized: "Buy / Receive") : String(localized: "Receive")
			default:
				item.title = "NO-TITLE"
				NSLog("ERROR: UITabbar item count is wrong")
			}
		}
	}

	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		displayContentController(contentController: viewControllers[kInitialChildViewControllerIndex])
	}

	func displayContentController(contentController: UIViewController) {
		// MARK: - Tab View Controllers Configuration

		switch NSStringFromClass(contentController.classForCoder) {
		case "brainwallet.TransactionsViewController":

			guard let transactionVC = contentController as? TransactionsViewController
			else {
				return
			}

			transactionVC.store = store
			transactionVC.walletManager = walletManager
			transactionVC.isLtcSwapped = store?.state.isLtcSwapped

        case "brainwallet.SendLTCViewController":
			guard let sendVC = contentController as? SendLTCViewController
			else {
				return
			}

			sendVC.store = store

		case "brainwallet.ReceiveLTCViewController":
			guard let receiveVC = contentController as? ReceiveLTCViewController
			else {
				return
			}
			receiveVC.store = store

		default:
			fatalError("Tab viewController not set")
		}
		exchangeRate = TransactionManager.sharedInstance.rate

		addChild(contentController)
		contentController.view.frame = containerView.frame
		view.addSubview(contentController.view)
		contentController.didMove(toParent: self)
		activeController = contentController
	}

	func hideContentController(contentController: UIViewController) {
		contentController.willMove(toParent: nil)
		contentController.view.removeFromSuperview()
		contentController.removeFromParent()
	}

	func tabBar(_: UITabBar, didSelect item: UITabBarItem) {
		if let tempActiveController = activeController {
			hideContentController(contentController: tempActiveController)
		}

        self.tabBar.selectedItem = item

        // New Receive SwiftUI HC
        if item.tag == 2 {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.presentNewReceiveModal()
            }
        } else {
            // DEV: This happens because it relies on the tab in the storyboard tag
            displayContentController(contentController: viewControllers[item.tag])
        }
	}

    func presentNewReceiveModal() {
        guard let store = store,
              let walletManager = walletManager else { return }
        let canUserBuy = UserDefaults.standard
            .object(forKey: userCurrentLocaleMPApprovedKey) as? Bool ?? false

        receiveHostingController = nil
        buyReceiveHostingController = nil

        if canUserBuy {
            self.children
                .compactMap { $0 as? UIHostingController<BuyReceiveView> }
                .forEach { buyReceiveHostingController in
                    buyReceiveHostingController.willMove(toParent: nil)
                    buyReceiveHostingController.view.removeFromSuperview()
                    buyReceiveHostingController.removeFromParent()
                }

            buyReceiveHostingController = BuyReceiveHostingController(store: store,
                                                        walletManager: walletManager,
                                                        isModalMode: true)

            guard let buyRecvHC = buyReceiveHostingController else { return }

            addChild(buyRecvHC)
            buyRecvHC.view.frame = containerView.frame
            view.addSubview(buyRecvHC.view)
            buyRecvHC.didMove(toParent: self)

        } else {

            self.children
                .compactMap { $0 as? UIHostingController<NewReceiveView> }
                .forEach { receiveHostingController in
                    receiveHostingController.willMove(toParent: nil)
                    receiveHostingController.view.removeFromSuperview()
                    receiveHostingController.removeFromParent()
                }

            receiveHostingController = ReceiveHostingController(store: store,
                                                     walletManager: walletManager,
                                                     isModalMode: true)

            guard let recvHC = receiveHostingController else { return }

            addChild(recvHC)
            recvHC.view.frame = containerView.frame
            view.addSubview(recvHC.view)
            recvHC.didMove(toParent: self)
        }
    }

}

extension TabBarViewController {

    // MARK: - Adding Subscriptions

    private func addSubscriptions() {
        guard let store = store
        else {
            debugPrint("::: ERROR - Store not passed")
            return
        }

        guard let primaryLabel = primaryBalanceLabel,
              let secondaryLabel = secondaryBalanceLabel
        else {
            debugPrint("::: ERROR: Price labels not initialized")
            return
        }

        store.subscribe(self, selector: { $0.walletState.syncProgress != $1.walletState.syncProgress },
                        callback: { _ in
                    if let rate = store.state.currentRate {
                        let maxDigits = store.state.maxDigits
                        let placeholderAmount = Amount(amount: 0, rate: rate, maxDigits: maxDigits)
                        secondaryLabel.formatter = placeholderAmount.localFormat
                        primaryLabel.formatter = placeholderAmount.ltcFormat
                        self.exchangeRate = rate
                    }
        })

        store.lazySubscribe(self,
                            selector: { $0.isLtcSwapped != $1.isLtcSwapped },
                            callback: { self.isLtcSwapped = $0.isLtcSwapped })
        store.lazySubscribe(self,
                            selector: { $0.currentRate != $1.currentRate },
                            callback: {
                                if let rate = $0.currentRate {
                                    let placeholderAmount = Amount(amount: 0, rate: rate, maxDigits: $0.maxDigits)
                                    secondaryLabel.formatter = placeholderAmount.localFormat
                                    primaryLabel.formatter = placeholderAmount.ltcFormat
                                }
                                self.exchangeRate = $0.currentRate
                            })

        store.lazySubscribe(self,
                            selector: { $0.maxDigits != $1.maxDigits },
                            callback: {
                                if let rate = $0.currentRate {
                                    let placeholderAmount = Amount(amount: 0, rate: rate, maxDigits: $0.maxDigits)
                                    secondaryLabel.formatter = placeholderAmount.localFormat
                                    primaryLabel.formatter = placeholderAmount.ltcFormat
                                    self.setBalances()
                                }
                            })

        store.subscribe(self,
                        selector: { $0.walletState.balance != $1.walletState.balance },
                        callback: { state in
                            if let balance = state.walletState.balance {
                                self.balance = balance
                                self.setBalances()
                            }
                        })
    }

	@objc private func currencySwitchTapped() {
		view.layoutIfNeeded()
		guard let store = store else { return }
		guard let isLTCSwapped = isLtcSwapped else { return }
		guard let primaryLabel = primaryBalanceLabel,
		      let secondaryLabel = secondaryBalanceLabel
		else {
			NSLog("ERROR: Price labels not initialized")
			return
		}

		UIView.spring(0.7, animations: {
			primaryLabel.transform = primaryLabel.transform.isIdentity ? self.transform(forView: primaryLabel) : .identity
			secondaryLabel.transform = secondaryLabel.transform.isIdentity ? self.transform(forView: secondaryLabel) : .identity
			NSLayoutConstraint.deactivate(!isLTCSwapped ? self.regularConstraints : self.swappedConstraints)
			NSLayoutConstraint.activate(!isLTCSwapped ? self.swappedConstraints : self.regularConstraints)
			self.view.layoutIfNeeded()
		}) { _ in }
		store.perform(action: CurrencyChange.toggle())
	}
}
