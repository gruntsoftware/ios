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
    var userPrefersDarkMode: Bool = UserDefaults.userPreferredDarkTheme

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
    var walletIsSyncing: Bool = false

    @Published
    var shouldShowGameMode: Bool = false
     
    @Published
    var shouldShowShop: Bool = false
     
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

    @Published
    var updateTimer: Timer?

    @Published
    var wasLTCFiatSwapped = false

    @Published
    var userWantsToTopUp = false

    @Published
    var shouldShowSettings = false
    
    @Published
    var shouldShowSocials = false
    
    @Published
    var shouldShowBuyReceive = false
    
    @Published
    var didRegisterForNotifications: Bool = false

    @Published
    var walletBalanceFiat = ""

    @Published
    var walletBalanceLitecoin = ""

    @Published
    var walletBalanceFiatDouble: Double = 0.0

    @Published
    var walletBalanceLitecoinDouble: Double = 0.0

    @Published
    var currentServiceFee = Litecoin(rawValue: 0.0)

    @Published
    var currentNetworkFee = Litecoin(rawValue: 0.0)

    @Published
    var currentPreFeeAmount = Litecoin(rawValue: 0.0)

    @Published
    var currentTotalAmount = Litecoin(rawValue: 0.0)

    @Published
    var currentFiatAmount = 0.0

    @Published
    var currentMemoString: String = ""

    @Published
    var currentSendAddress: String = ""

    @Published
    var sender: Sender?

    @Published
    var bwTransaction = BWTransaction()

    @Published
    var transactions: [Transaction]?

    @Published
    var filteredTransactions: [Transaction] = []

    @Published
    var currentTransaction: Transaction? {
        didSet {
            currentTransactionUUID = currentTransaction?.id ?? UUID()
            debugPrint(":::: currentTransactionUUID \(currentTransactionUUID)")
        }
    }

    @Published
    var currentTransactionUUID =  UUID()

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
            return 6.0
        #else
            return 20.0
        #endif
    }()

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

    @Published
    var currentEmojiTriplet: EmojiTriplet = .first

    @Published
    var didSelectTriplet: Bool = false

    @Published
    var canSelect: Bool = false

    @Published
    var tripletDictionary: [Int : String] = [1 : "",
                                            2 : "",
                                            3  : ""]

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
                        self.currencyCode = "\(currentRate.code)/LTC"
                        self.rate = currentRate
                        self.currentFiatValue = "\(currentRate.rate.description)"

                        debugPrint("::: currentRate.rate.description \(currentRate.rate.description)")
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
        updateTimer?.invalidate()
        self.updateTimer = nil
    }

    func setEmojiTriplet() -> Bool {
        guard let walletManager = self.walletManager else { return false }
        let first = tripletDictionary[1] ?? ""
        let second = tripletDictionary[2] ?? ""
        let third = tripletDictionary[3] ?? ""
        return walletManager.updateEmojiString("\(first)\(second)\(third)")
    }

    private func setBalances() {
        guard let store = self.store else { return }

        if let currentRate = store.state.currentRate,
           let balance = store.state.walletState.balance {
            exchangeRate = currentRate
            walletAmount = Amount(amount: balance, rate: currentRate, maxDigits: store.state.maxDigits)

            walletBalanceLitecoinDouble =  Double(balance) / Double(100_000_000)
            walletBalanceFiatDouble = walletBalanceLitecoinDouble * Double(currentRate.rate)
            walletBalanceFiat = String(format: "%@%8.2f", currentRate.currencySymbol, walletBalanceFiatDouble)
            walletBalanceLitecoin = String(format: "Ł%8.6f", walletBalanceLitecoinDouble)
            // Price Label
            let formattedFiatString = String(format: "%8.2f", currentRate.rate)
            currentFiatValue = String(currentRate.currencySymbol + formattedFiatString)
        }
    }

    private func addSubscriptions() {
        guard let store = store
        else {
            NSLog("::: ERROR: Store not initialized")
            return
        }

        // MARK: - Wallet State:  Sync State
        store.subscribe(self, selector: { $0.walletState.syncState != $1.walletState.syncState },
                        callback: { state in
            if state.walletState.syncState == .syncing {
                    self.walletIsSyncing = true
                } else {
                    self.walletIsSyncing = false
                }

                if state.walletState.syncState == .success {
                    self.walletIsSyncing = false
                }
        })

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
    }

    func userDidTapTheSettingsButton() {
        didTapSettingsButton?()
    }

    func updateTheme(shouldBeDark: Bool) {
        UserDefaults.userPreferredDarkTheme = shouldBeDark
        userPrefersDarkMode = shouldBeDark
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

    func canSendAmountWithFees(isLTCValue: Bool, sendAmountDouble: Double) -> Bool {
        guard let rate = self.rate,
              let kvStore = self.walletManager?.apiClient?.kv,
              let walletManager = self.walletManager,
              let store = self.store,
              let walletLitoshiBalance = store.state.walletState.balance else { return false }

        sender = Sender(walletManager: walletManager,
                            kvStore: kvStore, store: store)

        let amountInLTC = isLTCValue ? sendAmountDouble :  sendAmountDouble / rate.rate // UInt64(sendAmountDouble * 100_000_000)
        let tieredOpsFeeLTC = tieredOpsFee(amount: UInt64(amountInLTC * 100_000_000))
        let totalAmountToCalculateFees = (UInt64(amountInLTC * 100_000_000) + tieredOpsFeeLTC)

        guard let sender = self.sender else { return false }
        let networkFee = sender.feeForTx(amount: totalAmountToCalculateFees)
        let totalFees = tieredOpsFeeLTC + networkFee
        let preFeeAmount = UInt64(amountInLTC * 100_000_000)
        let totalAmountToSendLitoshis = totalFees + preFeeAmount

        currentServiceFee = Litecoin(rawValue: Double(tieredOpsFeeLTC) / Double(100_000_000))
        currentNetworkFee = Litecoin(rawValue: Double(networkFee) / Double(100_000_000))
        currentPreFeeAmount = Litecoin(rawValue: Double(preFeeAmount) / Double(100_000_000))
        currentTotalAmount = Litecoin(rawValue: Double(totalAmountToSendLitoshis) / Double(100_000_000))
        currentFiatAmount = rate.rate * currentTotalAmount.rawValue
        return totalAmountToSendLitoshis > walletLitoshiBalance ? false : true
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
            debugPrint("::: CODE: userPreferredCurrencyCode")

            Analytics
                .logEvent("user_set_preferred_fiat",
                          parameters: nil)
        }
        debugPrint("::: CODE: out if  userPreferredCurrencyCode")

    }

    func setPinPasscode(newPasscode: String) -> Bool {
        guard let store = store,
            let walletManager = self.walletManager else {
            Analytics.logEvent("wallet_manager_error", parameters: [
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
    
    func requestNotificationPermissions() {
        DispatchQueue.main.async {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate {
                appDelegate.launchFCMessaging { didRegister in
                    self.didRegisterForNotifications = didRegister
                }
            }
            else {
                debugPrint("launchFCMessaging not called")
            }
        }
    }
}
