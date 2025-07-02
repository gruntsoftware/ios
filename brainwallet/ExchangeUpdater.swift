import Foundation

class ExchangeUpdater: Subscriber {
	// MARK: - Public

    let store: Store
    let walletManager: WalletManager?

	init(store: Store, walletManager: WalletManager) {
		self.store = store
		self.walletManager = walletManager

		store.subscribe(self,
		                selector: { $0.userPreferredCurrencyCode != $1.userPreferredCurrencyCode },
		                callback: { state in
		                	guard let currentRate = state.rates.first(where: { $0.code == state.userPreferredCurrencyCode }) else {
                                debugPrint("::: Exchange Updater: No rate  \(state.userPreferredCurrencyCode)\n")
                                return }
                            debugPrint("::: \(currentRate) \n")
		                	self.store.perform(action: ExchangeRates.setRate(currentRate))
		                })
	}

	func refresh(completion: @escaping () -> Void) {

        guard let walletManager = walletManager
        else {
            debugPrint("::: ERROR: WalletManager not initialized")
            return
        }

		if walletManager.store.state.walletState.syncState != .syncing {
			walletManager.apiClient?.exchangeRates { rates, error in
                guard let currentRate = rates.first(where: { $0.code == self.store.state.userPreferredCurrencyCode }) else {
                    debugPrint("::: ERROR fetching rates \(String(describing: error))")
                    completion()
                    return
                }
				self.store.perform(action: ExchangeRates.setRates(currentRate: currentRate, rates: rates))
				completion()
			}
		} else {
            debugPrint(":::  Exchange rates walletState.syncState \n:::\(walletManager.store.state.walletState.syncState):::: \n")
        }
	}

    func fetchRates(completion: @escaping ([Rate?]) -> Void) {

        let apiClient = BWAPIClient(authenticator: NoAuthAuthenticator())
        apiClient.exchangeRates { rates, _ in
            if let currentRate = rates.first(where: { $0.code == self.store.state.userPreferredCurrencyCode }) {
                self.store.perform(action: ExchangeRates.setRates(currentRate: currentRate, rates: rates))
            }

         return completion(rates)
        }
    }

}
