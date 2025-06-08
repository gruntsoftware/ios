import AVFoundation
import Foundation
import SwiftUI
import UIKit

class StartViewModel: ObservableObject, Subscriber {
	// MARK: - Combine Variables
    
    @Published
    var currentFiat: SupportedFiatCurrencies = .USD
    
    @Published
    var currentValueInFiat = ""
    
    @Published
    var userPrefersDarkMode: Bool = false

	@Published
	var tappedIndex: Int = 0

	@Published
	var walletCreationDidFail: Bool = false
    
    @Published
    var fetchedRates: [Rate?] = []

	// MARK: - Public Variables

	var staticTagline = ""
	var didTapCreate: (() -> Void)?
	var didTapRecover: (() -> Void)?
    var store: Store?
	var walletManager: WalletManager
    
    let globalCurrencies: [GlobalCurrencies] = GlobalCurrencies.allCases
    
    let supportedCurrencies: [SupportedFiatCurrencies] = SupportedFiatCurrencies.allCases


	init(store: Store, walletManager: WalletManager) {
		self.store = store
		self.walletManager = walletManager
        fetchCurrentPrice(walletManager: walletManager)
	}
    private func fetchCurrentPrice(walletManager: WalletManager) {
        
        guard let store = store
        else {
            debugPrint("::: Error: Rate not fetched ")
            return
        }
        
//        let rate = rates[indexPath.row]
//                store.perform(action: DefaultCurrency.setDefault(rate.code))
        
        /// Init exchange sooner
        let exchangeUpdater = ExchangeUpdater(store: store, walletManager: walletManager)
        exchangeUpdater.fetchRates { rates in
            
            if !rates.isEmpty {
                self.fetchedRates = rates
            } else {
                self.recallFetchCurrentPrice()
            }
            
        guard let rate = store.state.currentRate?.rate
        else {
            debugPrint("::: Error: Rate not fetched ")
            return
        }

        // Price Label
        let fiatRate = Double(round(100000 * rate / 100000))
        let formattedFiatString = String(format: "%3.2f", fiatRate)
        
        guard let code: String = store.state.currentRate?.code
        else {
            debugPrint("::: Error: Rate not fetched ")
            return
        }
        
            self.currentValueInFiat = String(formattedFiatString + code)
        
        }
        
    }
    private func recallFetchCurrentPrice() {
        delay(3.0) {
            self.fetchCurrentPrice(walletManager: self.walletManager)
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
                
                self?.fetchCurrentPrice(walletManager: wallet)
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
    
    func userDidSetCurrencyPreference(currency: SupportedFiatCurrencies) {
        
        /// Legacy definition of default currency code....copiying here
        /// Will normallize in refactor
        let code = currency.code
        UserDefaults.userPreferredBuyCurrency = code
        UserDefaults.defaultCurrencyCode = code
        UserDefaults.standard.synchronize()
        
        self.fetchCurrentPrice(walletManager: self.walletManager)

        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .preferredCurrencyChangedNotification,
                                            object: nil,
                                            userInfo: nil)
        }
    }
}
