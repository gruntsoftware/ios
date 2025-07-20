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

	// MARK: - Public Variables
    var store: Store?

	init(store: Store) {
		self.store = store
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
