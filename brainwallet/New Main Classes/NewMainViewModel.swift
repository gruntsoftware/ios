//
//  NewMainViewModel.swift
//  brainwallet
//
//  Created by Kerry Washington on 03/05/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

import SwiftUI
import FirebaseAnalytics

enum FilterTransactionMode: Int, CaseIterable {
    case allTransactions = 0
    case sentTransactions = 1
    case receivedTransactions = 2
}

class NewMainViewModel: ObservableObject, Subscriber {

    @Published
    var store: Store?

    @Published
    var walletManager: WalletManager?

    @Published
    var exchangeRate: Rate?

    @Published
    var userPrefersDarkMode: Bool = false

    @Published
    var isLTCValueShown: Bool = false

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
    var restoredPhrase = ""

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
    var shouldBeSyncing: Bool = false

    @Published
    var walletBalanceFiat = ""

    @Published
    var walletBalanceLitecoin = ""

    @Published
    var transactions: [Transaction]?

    @Published
    var filteredTransactions: [Transaction] = []

    @Published
    var detailedTransaction: Transaction?

    @Published
    var filteredSeedWords: [String] = [""]

    @Published
    var transactionCount = 0

    let globalCurrencies: [GlobalCurrency] = GlobalCurrency.allCases

    let globalCurrencyCodes: [String] = GlobalCurrency.allCases.map( \.code )

    var didTapCreate: (() -> Void)?
    var didTapRecover: (() -> Void)?
    var didTapSettingsButton: (() -> Void)?

    private
    let ratesPriceUpdateTimerPeriod: Double = {
        #if DEBUG
            return 3.0
        #else
            return 20.0
        #endif
    }()

    private var currentPromptType: PromptType? {
        didSet {
            if currentPromptType != nil, oldValue == nil {
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                }
            }
        }
    }

    private var balance: UInt64 = 0 {
        didSet { setBalances() }
    }

    var pinDigits: [Int] = []

    private var rate: Rate?

    private var bip39SeedWords: [NSString]? {
        guard let path = Bundle.main.path(forResource: "BIP39Words", ofType: "plist") else { return nil }
        return NSArray(contentsOfFile: path) as? [NSString]
    }

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

                self.networkHelper.exchangeRates({ rates, error in
                    guard let currentRate = rates.first(where: { $0.code ==
                        self.store?.state.userPreferredCurrencyCode }) else {
                        return
                    }
                    if error == nil && !rates.isEmpty {
                        debugPrint("::: currentRate \(currentRate.rate.description)")
                        self.currencyCode = "\(currentRate.code)"
                        self.currentFiatValue = "\(currentRate.rate.description)"
                    }

                    self.store?.perform(action: ExchangeRates.setRate(currentRate))
                    self.userDidSetCurrencyPreference(currency: self.currentGlobalFiat)
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
            let formattedFiatString = String(format: "%8.2f", currentRate.rate)
            currentFiatValue = String(currentRate.currencySymbol + formattedFiatString)
        }
    }

    func userDidTapTheSettingsButton() {
        didTapSettingsButton?()
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
        filteredTransactions = transactions
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

    @objc
    private func userTappedPromptContinue() {
        /// do continue
         if let store = self.store,
            let trigger = self.currentPromptType?.trigger {
                store.trigger(name: trigger)
            }

        self.currentPromptType = nil
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

    func verifySeedPhrase(phrase: String) -> Bool {
        guard let walletManager = self.walletManager else { return false }
        return walletManager.isPhraseValid(phrase)
    }

    func didRestoreOldBrainwallet() {
        guard let store = store,
            let walletManager = self.walletManager else {
            return
        }

        if walletManager.setSeedPhrase(restoredPhrase) {
            UserDefaults.writePaperPhraseDate = Date()
            store.perform(action: SimpleReduxAlert.Show(.paperKeySet(callback: {})))
            store.trigger(name: .didCreateOrRecoverWallet)
            DispatchQueue.walletQueue.async {
               walletManager.peerManager?.connect()
            }
        } else {
            fatalError("💣💣💣 Error: restore seed phrase failed")
        }
    }

    func loadDraggableSeedWords() -> [DraggableSeedWord] {

        for seedWord in seedPhrase {
            let dragableSeedWord = DraggableSeedWord(id: UUID(), tagNumber: seedWord.tagNumber, word: seedWord.word, doesMatch: false)
            draggableSeedPhrase.append(dragableSeedWord)
        }
        return draggableSeedPhrase
    }

    private func attemptShowPrompt() {
        guard let walletManager = walletManager,
        let store = store else {
            NSLog("::: ERROR: WalletManager or Store not initialized")
            return
        }

        let types = PromptType.defaultOrder
        if let type = types.first(where: { $0.shouldPrompt(walletManager: walletManager, state: store.state) }) {
            currentPromptType = type
            if type == .biometrics {
                UserDefaults.hasPromptedBiometrics = true
            }
            if type == .shareData {
                UserDefaults.hasPromptedShareData = true
            }
        } else {
            currentPromptType = nil
        }
    }

//    private func addSubscriptions() {
//
//        guard let store = self.store else { return }
//
//        store.lazySubscribe(self,
//                            selector: { $0.isLTCValueShown != $1.isLTCValueShown },
//                            callback: { _ in
//                        })
//        store.lazySubscribe(self,
//                            selector: { $0.currentRate != $1.currentRate },
//                            callback: { [weak self] in
//                                if let rate = $0.currentRate {
//                                    let placeholderAmount = Amount(amount: 0, rate: rate, maxDigits: $0.maxDigits)
//                                    self?.localFormatter = placeholderAmount.localFormat
//                                    self?.ltcFormatter = placeholderAmount.ltcFormat
//                                }
//                                self?.exchangeRate = $0.currentRate
//                                self?.updateTransactions()
//                            })
//
//        store.lazySubscribe(self,
//                            selector: { $0.maxDigits != $1.maxDigits },
//                            callback: {
//                                if let rate = $0.currentRate {
//                                    let placeholderAmount = Amount(amount: 0, rate: rate, maxDigits: $0.maxDigits)
//                                    self.localFormatter = placeholderAmount.localFormat
//                                    self.ltcFormatter = placeholderAmount.ltcFormat
//                                    self.setBalances()
//                                }
//                            })
//
//        store.subscribe(self,
//                        selector: { $0.walletState.balance != $1.walletState.balance },
//                        callback: { state in
//                            if let balance = state.walletState.balance {
//                                self.balance = balance
//                                self.setBalances()
//                            }
//                        })
//
//    }

    // MARK: - Subscription Methods

    private func addSubscriptions() {
        guard let store = store
        else {
            NSLog("::: ERROR: Store not initialized")
            return
        }

        // MARK: - Wallet State: Transactions

        store.subscribe(self, selector: { $0.walletState.transactions != $1.walletState.transactions },
                        callback: { state in
                            self.transactions = state.walletState.transactions
                        })

        // MARK: - Wallet State: isLTCValueShown

        store.subscribe(self, selector: { $0.isLTCValueShown != $1.isLTCValueShown },
                        callback: { self.isLTCValueShown = $0.isLTCValueShown })

        // MARK: - Wallet State:  CurrentRate

        store.subscribe(self, selector: { $0.currentRate != $1.currentRate },
                        callback: {
            self.rate = $0.currentRate
        })

        // MARK: - Wallet State:  Balance

                store.subscribe(self,
                                selector: { $0.walletState.balance != $1.walletState.balance },
                                callback: { state in
                                    if let balance = state.walletState.balance {
                                        self.balance = balance
                                        self.setBalances()
                                    }
                                })

        // MARK: - Wallet State:  Max Digits

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

        // MARK: - Wallet State:  Sync Progress

        store.subscribe(self, selector: { $0.walletState.lastBlockTimestamp != $1.walletState.lastBlockTimestamp },
                        callback: { reduxState in

                        print("::: \(reduxState.walletState.isRescanning)")
                        print("::: \(reduxState.walletState.lastBlockTimestamp)")
                        print("::: \(reduxState.walletState.syncProgress)")
                        print("::: \(reduxState.walletState.isConnected)")
                        print("::: sync progress")

                            // guard let syncView = self.newSyncingHeaderView else { return }

//            syncView.viewModel.isRescanning = reduxState.walletState.isRescanning
//                            if syncView.viewModel.isRescanning || (reduxState.walletState.syncState == .syncing) {
//                                syncView.viewModel.progress = CGFloat(self.updateProgressView(syncProgress:
//                                    CGFloat(reduxState.walletState.syncProgress),lastBlockTimestamp: Double(reduxState.walletState.lastBlockTimestamp)))
//                                syncView.viewModel.headerMessage = reduxState.walletState.syncState
//                                syncView.viewModel.dateTimestamp = reduxState.walletState.lastBlockTimestamp
//                                syncView.viewModel.blockHeightString = reduxState.walletState.transactions.first?.blockHeight ?? ""

                                self.shouldBeSyncing = true

//                                if reduxState.walletState.syncProgress == 0.999 {
//                                    self.shouldBeSyncing = false
//                                    self.newSyncingHeaderView = nil
//
//                                    self.measureSyncTimes(startSync: self.syncStartTime, endSync: Date())
//                                }

                        })

        // MARK: - Wallet State:  Sync State

        store.subscribe(self, selector: { $0.walletState.syncState != $1.walletState.syncState },
                        callback: { reduxState in

                            guard let _ = self.walletManager?.peerManager
                            else {
                                return
                            }

                            if reduxState.walletState.syncState == .syncing {
                                self.shouldBeSyncing = true
                            }

                            if reduxState.walletState.syncState == .success {
                                self.shouldBeSyncing = false
                            }
                        })

        // MARK: - Subscription:  Recommend Rescan

        store.subscribe(self, selector: { $0.recommendRescan != $1.recommendRescan },
                        callback: { [weak self] _ in
            self?.attemptShowPrompt()
        })

        // MARK: - Subscription:  Did Upgrade PIN

        store.subscribe(self, name: .didUpgradePin, callback: {  [weak self] _ in
            if self?.currentPromptType == .upgradePin {
                self?.currentPromptType = nil
            }
        })

        // MARK: - Subscription:  Did Enable Share Data

        store.subscribe(self, name: .didEnableShareData, callback: { [weak self] _ in
            if self?.currentPromptType == .shareData {
                self?.currentPromptType = nil
            }
        })

        // MARK: - Subscription:  Did Write Paper Key

        store.subscribe(self, name: .didWritePaperKey, callback: { [weak self] _ in
            if self?.currentPromptType == .paperKey {
                self?.currentPromptType = nil
            }
        })

        // MARK: - Subscription:  Memo Updated

        store.subscribe(self, name: .txMemoUpdated(""), callback: { [weak self] in

            guard let trigger = $0 else { return }

            if case let .txMemoUpdated(txHash) = trigger {
                // self?.updateTransactions(txHash: txHash)
            }
        })
    }

}
