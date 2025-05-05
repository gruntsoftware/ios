import AVFoundation
import Foundation
import SwiftUI
import UIKit

enum VoidQRState {
    
}

class LockScreenViewModel: ObservableObject, Subscriber {
	// MARK: - Combine Variables

	@Published
	var currentValueInFiat: String = ""

	@Published
	var currencyCode: String = ""
    
    @Published
    var userPrefersDarkMode = false
    
    @Published
    var userWantsToDelete = false
    
    @Published
    var userDidTapQR: Bool?
    

	// MARK: - Public Variables

	var store: Store?

	init(store: Store) {
		self.store = store
		addSubscriptions()
		fetchCurrentPrice()
	}

	private func fetchCurrentPrice() {
		guard let currentRate = store?.state.currentRate
		else {
            print("::: Error: Rate not fetched ")
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
			NSLog("ERROR: Store not initialized")
			return
		}

		store.subscribe(self, selector: { $0.currentRate != $1.currentRate },
		                callback: { _ in
		                	self.fetchCurrentPrice()
		                })
	}
}
