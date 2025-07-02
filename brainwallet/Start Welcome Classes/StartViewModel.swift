import AVFoundation
import Foundation
import SwiftUI
import UIKit

class StartViewModel: ObservableObject, Subscriber {
	// MARK: - Combine Variables

    @Published
    var userPrefersDarkMode: Bool = false

	@Published
	var tappedIndex: Int = 0

	@Published
	var walletCreationDidFail: Bool = false

	// MARK: - Public Variables

	var didTapCreate: (() -> Void)?
	var didTapRecover: (() -> Void)?
    var store: Store?

    let globalCurrencies: [GlobalCurrency] = GlobalCurrency.allCases

	init(store: Store) {
		self.store = store
	}

	func userWantsToCreate(completion: @escaping () -> Void) {
		didTapCreate = completion
	}

	func userWantsToRecover(completion: @escaping () -> Void) {
		didTapRecover = completion
	}

    func userDidSetThemePreference(userPrefersDarkMode: Bool) {

        UserDefaults.userPreferredDarkTheme = userPrefersDarkMode

        NotificationCenter
            .default
            .post(name: .changedThemePreferenceNotification,
                object: nil)
    }

    func userDidSetCurrencyPreference(currency: GlobalCurrency) {

        guard let store = store
        else {
            debugPrint("::: ERROR: Rate not fetched")
            return
        }

        //  Check if preferred currency can be used for purchase
        let code = currency.code
        let isUnsupportedFiat = SupportedFiatCurrency.allCases.first(where: { $0.code == code }) == nil
        // Preferred currency might not be supported for purchase
        if isUnsupportedFiat {
            UserDefaults.userPreferredBuyCurrency = "USD"
        } else {
            UserDefaults.userPreferredBuyCurrency = code
        }
        UserDefaults.userPreferredCurrencyCode = code

        // Set Preferred Currency
        store.perform(action: UserPreferredCurrency.setDefault(code))

    }
}
