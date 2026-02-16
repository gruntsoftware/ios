import SwiftUI

@MainActor
class LockScreenViewModel: ObservableObject, Subscriber {
	// MARK: - Combine Variables

	@Published
	var currentFiatValue: String = ""

	@Published
	var currencyCode: String = ""

    @Published
    var freshReceiveAddress: String = ""

    @Published
    var userPrefersDarkMode = false

    @Published
    var shouldShowReceiveAddress: Bool = false

    @Published
    var authenticationFailed =  false

    @Published
    var didCompleteWipingWallet = false

    @Published
    var pinDigits = [Int(),Int(),Int(),Int()]

    var userSubmittedPIN: ((String) -> Void)?

    var didTapWipeWallet: ((Bool) -> Void)?

    var isPresentedForLock: Bool = false

	// MARK: - Public Variables

	var store: Store?

    init(store: Store) {
		self.store = store

		addSubscriptions()
		fetchCurrentPrice()

        NotificationCenter
            .default
            .addObserver(forName: .walletSyncStartedNotification,
                object: nil,
                         queue: nil) { [weak self] _ in
                Task { @MainActor in
                    self?.updateWalletManager()
                }
        }
	}

    deinit {
        NotificationCenter.default.removeObserver(self)
     }

    func startWipeProcess() {
        didTapWipeWallet?(true)
    }

    func userDidSetThemePreference(userPrefersDarkMode: Bool) {
        UserDefaults.userPreferredDarkTheme = userPrefersDarkMode
                NotificationCenter
                    .default
                    .post(name: .changedThemePreferenceNotification,
                        object: nil)
    }

	private func fetchCurrentPrice() {
		guard let currentRate = store?.state.currentRate
		else {
            debugPrint("::: ERROR: Rate not fetched ")
			return
		}

        // Price Label
		let fiatRate = Double(round(100000 * currentRate.rate / 100000))
		let formattedFiatString = String(format: "%3.2f", fiatRate)
		currencyCode = currentRate.code
		let currencySymbol = Currency.getSymbolForCurrencyCode(code: currencyCode) ?? ""
        currentFiatValue = String(currencySymbol + formattedFiatString)
	}

	// MARK: - Add Subscriptions

	private func addSubscriptions() {
		guard let store = store
		else {
            debugPrint("::: ERROR: Store not initialized")
			return
		}

		store.subscribe(self,
            selector: { $0.currentRate != $1.currentRate },
                callback: { [weak self] _ in
                    self?.fetchCurrentPrice() })
	}
    // MARK: - Add Notfications

    @objc func updateWalletManager() {
    }
}
