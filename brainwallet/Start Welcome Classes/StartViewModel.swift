import AVFoundation
import Foundation
import SwiftUI
import UIKit

class StartViewModel: ObservableObject, Subscriber {
	// MARK: - Combine Variables
    
    @Published
    var currentValueInFiat = ""
    
    @Published
    var userPrefersDarkMode: Bool = false

	@Published
	var tappedIndex: Int = 0

	@Published
	var walletCreationDidFail: Bool = false

	// MARK: - Public Variables

	var staticTagline = ""
	var didTapCreate: (() -> Void)?
	var didTapRecover: (() -> Void)?
    var store: Store?
	var walletManager: WalletManager
    var pickedGlobalCurrency: GlobalCurrencies = .USD

    private var fetchedRates: [Rate?] = []
    
    let globalCurrencies: [GlobalCurrencies] = GlobalCurrencies.allCases

	init(store: Store, walletManager: WalletManager) {
		self.store = store
		self.walletManager = walletManager
        fetchCurrentPrice()
	}
    func fetchCurrentPrice() {
        
        guard let store = store
        else {
            debugPrint("::: Error: Rate not fetched ")
            return
        }
        
        /// Init exchange sooner
        let exchangeUpdater = ExchangeUpdater(store: store, walletManager: self.walletManager)
        exchangeUpdater.fetchRates { rates in
            var fetchedRate: Double = 0.0
            if !rates.isEmpty {
                self.fetchedRates = rates
                guard let rateObject = self.fetchedRates.filter({ $0?.code != self.pickedGlobalCurrency.code }).first,
                let rateValue = rateObject?.rate
                        else {
                            return
                        }
                fetchedRate = rateValue
            }

        // Price Label
        let fiatRate = Double(round(100000 * fetchedRate / 100000))
        let formattedFiatString = String(format: "%3.2f", fiatRate)
        self.currentValueInFiat = String(formattedFiatString + self.pickedGlobalCurrency.code)
        
        // Set Default Currency
        store.perform(action: DefaultCurrency.setDefault(self.pickedGlobalCurrency.code))
        
        }
        
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
                
                guard let myself = self else {
                    return
                }
                
                let wallet = myself.walletManager
                
                self?.fetchCurrentPrice()
            })
    }
    
	/// Completion Handler process
	///  1. Create a closure var
	///  2. Create an func with an escaping closure and the signature should match the one in step 1
	///  3. In the func make the var equal it to func signature
	///  4. The parent calls the func of this class
	///  5. The third class that is observing the class with the function  triggers the var

	func userWantsToCreate(completion: @escaping () -> Void) {
		didTapCreate = completion
	}

	func userWantsToRecover(completion: @escaping () -> Void) {
		didTapRecover = completion
	}
    
    func userDidChangeDarkMode(state: Bool) {
         
        (UIApplication.shared.connectedScenes.first as?
                      UIWindowScene)?.windows.first!.overrideUserInterfaceStyle = state ?   .dark : .light
        UserDefaults.standard.set(state, forKey: userDidPreferDarkModeKey)
        
        UserDefaults.standard.synchronize()
    }

	/// DEV: For checking wallet
//	private func checkForWalletAndSync() {
//		/// Test seed count
//		guard seedWords.count == 12 else { return }
//
//		/// Set for default.  This model needs a initial value
//		walletManager.forceSetPin(newPin: Partner.partnerKeyPath(name: .brainwalletStart))
//
//		guard walletManager.setRandomSeedPhrase() != nil else {
//			walletCreationDidFail = true
//			let properties = ["error_message": "wallet_creation_fail"]
//			BWAnalytics.logEventWithParameters(itemName: ._20200112_ERR, properties: properties)
//			return
//		}
//
//		store.perform(action: WalletChange.setWalletCreationDate(Date()))
//		DispatchQueue.walletQueue.async {
//			self.walletManager.peerManager?.connect()
//			DispatchQueue.main.async {
//				self.store.trigger(name: .didCreateOrRecoverWallet)
//			}
//		}
//	}
    
    func userDidSetCurrencyPreference(currency: GlobalCurrencies) {
        
        /// Legacy definition of default currency code....copiying here
        /// Will normallize in refactor
        let code = currency.code
        UserDefaults.userPreferredBuyCurrency = code
        UserDefaults.defaultCurrencyCode = code
        UserDefaults.standard.synchronize()
        
        self.fetchCurrentPrice()

        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .preferredCurrencyChangedNotification,
                                            object: nil,
                                            userInfo: nil)
        }
    }
}
