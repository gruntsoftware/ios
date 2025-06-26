//
//  NewMainViewModel.swift
//  brainwallet
//
//  Created by Kerry Washington on 03/05/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

import Foundation
import SwiftUI

class NewMainViewModel: ObservableObject, Subscriber, Trackable {

    @Published
    var store: Store?

    @Published
    var walletManager: WalletManager?

    @Published
    var exchangeRate: Rate?

    @Published
    var currentFiatValue = ""

    @Published
    var currencyCode = ""

    @Published
    var currentLanguage = Locale.current.identifier

    @Published
    var walletAmount: Amount?

    @Published
    var localFormatter: NumberFormatter?

    @Published
    var ltcFormatter: NumberFormatter?

    @Published
    var dateFormatter: DateFormatter?

    var updateTimer: Timer?

    @Published
    var wasLTCFiatSwapped = false

    @Published
    var shouldShowSettings = false

    @Published
    var walletBalanceFiat = ""

    @Published
    var walletBalanceLitecoin = ""

    @Published
    var transactions: [Transaction]?

    @Published
    var transactionCount = 0

    private
    let timerPeriod: Double = {
        #if DEBUG
            return 3.0
        #else
            return 20.0
        #endif
    }()

    private var balance: UInt64 = 0 {
        didSet { setBalances() }
    }

    private var rate: Rate?

    var resetSettingsDrawer: (() -> Void)?

    init(store: Store, walletManager: WalletManager) {
        self.store = store
        self.walletManager = walletManager

        addSubscriptions()

        updateTimer = Timer
            .scheduledTimer(withTimeInterval: timerPeriod,
                            repeats: true) { _ in
            self.fetchCurrentPrice()
            self.setBalances()
        }

        dateFormatter = DateFormatter()
        dateFormatter!.setLocalizedDateFormatFromTemplate("dd MMM hh:mm:ss a")
        setBalances()
        updateTransactions()

    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: .languageChangedNotification, object: nil)
        self.updateTimer = nil
    }

    private func fetchCurrentPrice() {
        guard let currentRate = store?.state.currentRate
        else {
            return
        }

        let fiatRate = Double(round(100000 * currentRate.rate / 100000))
        let formattedFiatString = String(format: "%3.2f", fiatRate)
        currencyCode = currentRate.code
        let currencySymbol = Currency.getSymbolForCurrencyCode(code: currencyCode) ?? ""
        currentFiatValue = String(currencySymbol+formattedFiatString + " = Ł1")
    }

    private func setBalances() {
        guard let store = self.store else { return }

        if let rate = store.state.currentRate,
           let balance = store.state.walletState.balance {
            exchangeRate = rate
            walletAmount = Amount(amount: balance, rate: exchangeRate!, maxDigits: store.state.maxDigits)
            let ltcBalanceDouble = Double(balance) / Double(100_000_000)
            let fiatBalanceDouble = ltcBalanceDouble * Double(rate.rate)
            walletBalanceFiat = String(format: "%@%8.2f", rate.currencySymbol, fiatBalanceDouble)
            walletBalanceLitecoin = String(format: "Ł%8.6f", ltcBalanceDouble)
        }
    }

    func userDidSetCurrencyPreference(currency: GlobalCurrency) {

        guard let store = store
        else {
            debugPrint("::: Error: Rate not fetched")
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

    func updateTheme(shouldBeDark: Bool) {
        UserDefaults.userPreferredDarkTheme = shouldBeDark
        NotificationCenter
            .default
            .post(name: .changedThemePreferenceNotification,
                object: nil)
    }

    func lockBrainwallet() {
        delay(0.6) {
            self.resetSettingsDrawer?()
        }
    }

    func userWillChangePIN() {
        guard let store = self.store else { return }
        store.trigger(name: .promptUpgradePin)
    }

    func willShowSeedPhrase() {

    }

    func userWillSeeShowBrainwalletPhrase() {

    }

    func userWillShareData() {
        guard let store = self.store else { return }
        store.trigger(name: .promptShareData)
    }

    func updateTransactions() {
        guard let _ = walletManager
        else {
            debugPrint("::: ERROR: Wallet manager Not initialized")
            BWAnalytics.logEventWithParameters(itemName: ._20200112_ERR)
            return
        }

        transactions = TransactionManager.sharedInstance.transactions
        guard let transactions = transactions else { return }
        transactionCount = transactions.count

        rate = TransactionManager.sharedInstance.rate
    }

    private func addSubscriptions() {

        guard let store = self.store else { return }

        store.lazySubscribe(self,
                            selector: { $0.isLtcSwapped != $1.isLtcSwapped },
                            callback: { _ in
                        })
        store.lazySubscribe(self,
                            selector: { $0.currentRate != $1.currentRate },
                            callback: { [weak self] in
                                if let rate = $0.currentRate {
                                    let placeholderAmount = Amount(amount: 0, rate: rate, maxDigits: $0.maxDigits)
                                    self?.localFormatter = placeholderAmount.localFormat
                                    self?.ltcFormatter = placeholderAmount.ltcFormat
                                }
                                self?.exchangeRate = $0.currentRate
                                self?.fetchCurrentPrice()
                                self?.updateTransactions()
                            })

        store.lazySubscribe(self,
                            selector: { $0.maxDigits != $1.maxDigits },
                            callback: {
                                if let rate = $0.currentRate {
                                    let placeholderAmount = Amount(amount: 0, rate: rate, maxDigits: $0.maxDigits)
                                    self.localFormatter = placeholderAmount.localFormat
                                    self.ltcFormatter = placeholderAmount.ltcFormat
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

}
