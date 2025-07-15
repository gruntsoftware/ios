//
//  NewMainViewModel.swift
//  brainwallet
//
//  Created by Kerry Washington on 03/05/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

import SwiftUI
import FirebaseAnalytics

class NewMainViewModel: ObservableObject, Subscriber, Trackable {

    @Published
    var store: Store?

    @Published
    var walletManager: WalletManager?

    @Published
    var exchangeRate: Rate?

    @Published
    var userPrefersDarkMode: Bool = false

    @Published
    var tappedIndex: Int = 0

    @Published
    var walletCreationDidFail: Bool = false

    @Published
    var currentFiatValue = ""

    @Published
    var currencyCode = ""

    @Published
    var isSeedPhraseFilled: Bool = false

    @Published
    var seedPhrase: [SeedWord] = []

    @Published
    var draggableSeedPhrase: [DraggableSeedWord] = []

    @Published
    var currentLanguage = Locale.current.identifier

    @Published
    var currentGlobalFiat: GlobalCurrency = .USD

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

    let globalCurrencies: [GlobalCurrency] = GlobalCurrency.allCases

    let globalCurrencyCodes: [String] = GlobalCurrency.allCases.map( \.code )

    var didTapCreate: (() -> Void)?
    var didTapRecover: (() -> Void)?

    private
    let ratesPriceUpdateTimerPeriod: Double = {
        #if DEBUG
            return 3.0
        #else
            return 20.0
        #endif
    }()

    private var balance: UInt64 = 0 {
        didSet { setBalances() }
    }

    var pinDigits: [Int] = []

    private var rate: Rate?

    private var networkHelper = NetworkHelper()

    var resetSettingsDrawer: (() -> Void)?

    init(store: Store, walletManager: WalletManager) {
        self.store = store
        self.walletManager = walletManager

        let preferredCurrency = UserDefaults.userPreferredCurrencyCode
        if let preferredGlobalCurrencyCode = GlobalCurrency.from(code: preferredCurrency) {
            self.userDidSetCurrencyPreference(currency: preferredGlobalCurrencyCode)
        } else {
            self.userDidSetCurrencyPreference(currency: .USD)
        }
        addSubscriptions()
        updateTimer = Timer
            .scheduledTimer(withTimeInterval: ratesPriceUpdateTimerPeriod,
                            repeats: true) { _ in

                debugPrint("::: userPreferredCurrencyCode \(self.store?.state.userPreferredCurrencyCode) currentFiatValue \(self.currentFiatValue)")
                self.networkHelper.exchangeRates({ rates, error in
                    guard let currentRate = rates.first(where: { $0.code ==
                        self.store?.state.userPreferredCurrencyCode }) else {
                        return
                    }
                    if error == nil && !rates.isEmpty {
                        debugPrint("::: currentRate \(currentRate.rate.description)")
                    }

                    self.store?.perform(action: ExchangeRates.setRate(currentRate))
                    self.userDidSetCurrencyPreference(currency: self.currentGlobalFiat)
                    self.fetchCurrentPrice()
                    self.setBalances()
                })
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

        if let currentRate = store.state.currentRate,
           let balance = store.state.walletState.balance {
            exchangeRate = currentRate
            walletAmount = Amount(amount: balance, rate: currentRate, maxDigits: store.state.maxDigits)
            let ltcBalanceDouble = Double(balance) / Double(100_000_000)
            let fiatBalanceDouble = ltcBalanceDouble * Double(currentRate.rate)
            walletBalanceFiat = String(format: "%@%8.2f", currentRate.currencySymbol, fiatBalanceDouble)
            walletBalanceLitecoin = String(format: "Ł%8.6f", ltcBalanceDouble)
            // Price Label
            let fiatRate = Double(round(100000 * currentRate.rate / 100000))
            let formattedFiatString = String(format: "%3.2f", fiatRate)
            currencyCode = currentRate.code
            let currencySymbol = Currency.getSymbolForCurrencyCode(code: currencyCode) ?? ""
            currentFiatValue = String(currencySymbol + formattedFiatString)
        }
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

    func userWillSyncBlockchain() {
        guard let store = self.store else { return }
        store.trigger(name: .rescan)
    }

    func userWillChangePIN() {
        guard let store = self.store else { return }
        store.trigger(name: .promptUpgradePin)
    }

    func userWillShareData() {
        guard let store = self.store else { return }
        store.trigger(name: .promptShareData)
    }

    func updateTransactions() {
        guard let _ = walletManager
        else {
            debugPrint("::: ERROR: Wallet manager Not initialized")
            return
        }

        transactions = TransactionManager.sharedInstance.transactions
        guard let transactions = transactions else { return }
        transactionCount = transactions.count

        rate = TransactionManager.sharedInstance.rate
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

        let code = currency.code
        guard let store = store
        else {
            debugPrint("::: ERROR: Rate not fetched")
            return
        }

        if let newGlobalCurrency = GlobalCurrency.from(code: code) {
            currentGlobalFiat = newGlobalCurrency
            setBalances()
            // Set Preferred Currency
            UserDefaults.userPreferredCurrencyCode = code
            store.perform(action: UserPreferredCurrency.setDefault(code))
        }
    }

    func setPinPasscode(newPasscode: String) -> Bool {
        guard let store = store,
            let walletManager = self.walletManager else {
            Analytics.logEvent("wallet_manager_error", parameters: [
                "platform": "ios",
                "app_version": AppVersion.string,
                "error_message": "wallet_manager_nil"
            ])
            return false
        }
        store.perform(action: PinLength.set(newPasscode.utf8.count))
        _ = walletManager.forceSetPin(newPin: newPasscode)
        return true
    }

    func generateNewWallet() {
        guard let store = store,
            let walletManager = self.walletManager,
            let seedPhraseString = walletManager.setRandomSeedPhrase() else {
            return
        }

        let seedWordArray: [String] = seedPhraseString.components(separatedBy: " ")
        let filteredSeedWordArray = seedWordArray.filter { !$0.isEmpty }
        if filteredSeedWordArray.count == kSeedPhraseLength {
            DispatchQueue.walletQueue.async { [weak self] in
                walletManager.peerManager?.connect()
                DispatchQueue.main.async { [weak self, weak store] in
                    guard let self = self,
                        let store = store else { return }
                    for (index, element) in filteredSeedWordArray.enumerated() {
                        let seedWordElement = SeedWord(word: element, tagNumber: index + 1)
                        self.seedPhrase.insert(seedWordElement, at: index)
                    }
                    isSeedPhraseFilled = true
                    store.perform(action: WalletChange.setWalletCreationDate(Date()))
                    draggableSeedPhrase = loadDraggableSeedWords()
                }
            }
        }
    }

    func loadDraggableSeedWords() -> [DraggableSeedWord] {

        for seedWord in seedPhrase {
            let dragableSeedWord = DraggableSeedWord(id: UUID(), tagNumber: seedWord.tagNumber, word: seedWord.word, doesMatch: false)
            draggableSeedPhrase.append(dragableSeedWord)
        }
        return draggableSeedPhrase
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
