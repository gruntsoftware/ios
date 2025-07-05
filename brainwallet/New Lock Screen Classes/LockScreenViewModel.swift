import SwiftUI

class LockScreenViewModel: ObservableObject, Subscriber {
	// MARK: - Combine Variables

	@Published
	var currentValueInFiat: String = ""

	@Published
	var currencyCode: String = ""

    @Published
    var userPrefersDarkMode = false

    @Published
    var shouldShowQR: Bool = false

    @Published
    var authenticationFailed =  false

    @Published
    var didCompleteWipingWallet = false

    @Published
    var pinDigits = [Int(),Int(),Int(),Int()]

    var userSubmittedPIN: ((String) -> Void)?

    var userDidTapQR: (() -> Void)?

    var didTapWipeWallet: ((Bool) -> Void)?

    var userDidPreferDarkMode: ((Bool) -> Void)?

	// MARK: - Public Variables

	var store: Store?

	init(store: Store) {
		self.store = store
		addSubscriptions()
		fetchCurrentPrice()
	}

    func startWipeProcess() {
        didTapWipeWallet?(true)
    }

    func userDidSetThemePreference(userPrefersDarkMode: Bool) {
        userDidPreferDarkMode?(userPrefersDarkMode)
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
		currentValueInFiat = String(currencySymbol + formattedFiatString)
	}

	// MARK: - Add Subscriptions

	private func addSubscriptions() {
		guard let store = store
		else {
            debugPrint("::: ERROR: Store not initialized")
			return
		}

		store
            .subscribe(self,
                        selector: { $0.currentRate != $1.currentRate },
		                callback: { [weak self] _ in
		                	self?.fetchCurrentPrice()
		                })
	}

}
