import UIKit

// MARK: - Startup Modals

struct ShowStartFlow: Action {
	let reduce: Reducer = {
		$0.clone(isStartFlowVisible: true)
	}
}

struct HideStartFlow: Action {
	let reduce: Reducer = { state in
		ReduxState(isStartFlowVisible: false,
		           isLoginRequired: state.isLoginRequired,
		           rootModal: .none,
		           walletState: state.walletState,
		           isLtcSwapped: state.isLtcSwapped,
		           currentRate: state.currentRate,
		           rates: state.rates,
		           alert: state.alert,
		           isBiometricsEnabled: state.isBiometricsEnabled,
		           userPreferredCurrencyCode: state.userPreferredCurrencyCode,
		           recommendRescan: state.recommendRescan,
		           isLoadingTransactions: state.isLoadingTransactions,
		           maxDigits: state.maxDigits,
		           isPushNotificationsEnabled: state.isPushNotificationsEnabled,
		           isPromptingBiometrics: state.isPromptingBiometrics,
		           pinLength: state.pinLength,
		           fees: state.fees)
	}
}

struct Reset: Action {
	let reduce: Reducer = { _ in
		ReduxState.initial.clone(isLoginRequired: false)
	}
}

struct RequireLogin: Action {
	let reduce: Reducer = {
		$0.clone(isLoginRequired: true)
	}
}

struct LoginSuccess: Action {
	let reduce: Reducer = {
		$0.clone(isLoginRequired: false)
	}
}

// MARK: - Root Modals

struct RootModalActions {
	struct Present: Action {
		let reduce: Reducer
		init(modal: RootModal) {
			reduce = { $0.rootModal(modal) }
		}
	}
}

// MARK: - Wallet State

enum WalletChange {
	struct setProgress: Action {
		let reduce: Reducer
		init(progress: Double, timestamp: UInt32) {
			reduce = { $0.clone(walletSyncProgress: progress, timestamp: timestamp) }
		}
	}

	struct setSyncingState: Action {
		let reduce: Reducer
		init(_ syncState: SyncState) {
			reduce = { $0.clone(syncState: syncState) }
		}
	}

	struct setBalance: Action {
		let reduce: Reducer
		init(_ balance: UInt64) {
			reduce = { $0.clone(balance: balance) }
		}
	}

	struct setTransactions: Action {
		let reduce: Reducer
		init(_ transactions: [Transaction]) {
			reduce = { $0.clone(transactions: transactions) }
		}
	}

	struct setWalletName: Action {
		let reduce: Reducer
		init(_ name: String) {
			reduce = { $0.clone(walletName: name) }
		}
	}

	struct setWalletCreationDate: Action {
		let reduce: Reducer
		init(_ date: Date) {
			reduce = { $0.clone(walletCreationDate: date) }
		}
	}

	struct setIsRescanning: Action {
		let reduce: Reducer
		init(_ isRescanning: Bool) {
			reduce = { $0.clone(isRescanning: isRescanning) }
		}
	}
}

// MARK: - Currency

enum CurrencyChange {
	struct toggle: Action {
		let reduce: Reducer = {
			UserDefaults.isLtcSwapped = !$0.isLtcSwapped
			return $0.clone(isLtcSwapped: !$0.isLtcSwapped)
		}
	}
}

// MARK: - Exchange Rates

enum ExchangeRates {
	struct setRates: Action {
		let reduce: Reducer
		init(currentRate: Rate, rates: [Rate]) {
			UserDefaults.currentRateData = currentRate.dictionary
			reduce = { $0.clone(currentRate: currentRate, rates: rates) }
		}
	}

	struct setRate: Action {
		let reduce: Reducer
		init(_ currentRate: Rate) {
			reduce = { $0.clone(currentRate: currentRate) }
		}
	}
}

// MARK: - Alerts

enum SimpleReduxAlert {
	struct Show: Action {
		let reduce: Reducer
		init(_ type: AlertType) {
			reduce = { $0.clone(alert: type) }
		}
	}

	struct Hide: Action {
		let reduce: Reducer = { $0.clone(alert: nil) }
	}
}

enum Biometrics {
	struct setIsEnabled: Action, Trackable {
		let reduce: Reducer
		init(_ isBiometricsEnabled: Bool) {
			UserDefaults.isBiometricsEnabled = isBiometricsEnabled
			reduce = { $0.clone(isBiometricsEnabled: isBiometricsEnabled) }
			saveEvent("event.enableBiometrics", attributes: ["isEnabled": "\(isBiometricsEnabled)"])
		}
	}
}

enum UserPreferredCurrency {
	struct setDefault: Action, Trackable {
		let reduce: Reducer
		init(_ userPreferredCurrencyCode: String) {
			UserDefaults.userPreferredCurrencyCode = userPreferredCurrencyCode
            UserDefaults.standard.synchronize()
			reduce = { $0.clone(userPreferredCurrencyCode: userPreferredCurrencyCode) }

            DispatchQueue.main.async {
                NotificationCenter.default.post(name: .preferredCurrencyChangedNotification,
                                                object: nil,
                                                userInfo: nil)
            }
 		}
	}
}

enum RecommendRescan {
	struct set: Action, Trackable {
		let reduce: Reducer
		init(_ recommendRescan: Bool) {
			reduce = { $0.clone(recommendRescan: recommendRescan) }
			saveEvent("event.recommendRescan")
		}
	}
}

enum LoadTransactions {
	struct set: Action {
		let reduce: Reducer
		init(_ isLoadingTransactions: Bool) {
			reduce = { $0.clone(isLoadingTransactions: isLoadingTransactions) }
		}
	}
}

enum MaxDigits {
	struct set: Action, Trackable {
		let reduce: Reducer
		init(_ maxDigits: Int) {
			UserDefaults.maxDigits = maxDigits
			reduce = { $0.clone(maxDigits: maxDigits) }
			saveEvent("maxDigits.set", attributes: ["maxDigits": "\(maxDigits)"])
		}
	}
}

enum biometricsActions {
	struct setIsPrompting: Action {
		let reduce: Reducer
		init(_ isPrompting: Bool) {
			reduce = { $0.clone(isPromptingBiometrics: isPrompting) }
		}
	}
}

enum PinLength {
	struct set: Action {
		let reduce: Reducer
		init(_ pinLength: Int) {
			reduce = { $0.clone(pinLength: pinLength) }
		}
	}
}

enum UpdateFees {
	struct set: Action {
		let reduce: Reducer
		init(_ fees: Fees) {
			reduce = { $0.clone(fees: fees) }
		}
	}
}

// MARK: - State Creation Helpers

extension ReduxState {
	func clone(isStartFlowVisible: Bool) -> ReduxState {
		return ReduxState(isStartFlowVisible: isStartFlowVisible,
		                  isLoginRequired: isLoginRequired,
		                  rootModal: rootModal,
		                  walletState: walletState,
		                  isLtcSwapped: isLtcSwapped,
		                  currentRate: currentRate,
		                  rates: rates,
		                  alert: alert,
		                  isBiometricsEnabled: isBiometricsEnabled,
		                  userPreferredCurrencyCode: userPreferredCurrencyCode,
		                  recommendRescan: recommendRescan,
		                  isLoadingTransactions: isLoadingTransactions,
		                  maxDigits: maxDigits,
		                  isPushNotificationsEnabled: isPushNotificationsEnabled,
		                  isPromptingBiometrics: isPromptingBiometrics,
		                  pinLength: pinLength,
		                  fees: fees)
	}

	func rootModal(_ type: RootModal) -> ReduxState {
		return ReduxState(isStartFlowVisible: false,
		                  isLoginRequired: isLoginRequired,
		                  rootModal: type,
		                  walletState: walletState,
		                  isLtcSwapped: isLtcSwapped,
		                  currentRate: currentRate,
		                  rates: rates,
		                  alert: alert,
		                  isBiometricsEnabled: isBiometricsEnabled,
		                  userPreferredCurrencyCode: userPreferredCurrencyCode,
		                  recommendRescan: recommendRescan,
		                  isLoadingTransactions: isLoadingTransactions,
		                  maxDigits: maxDigits,
		                  isPushNotificationsEnabled: isPushNotificationsEnabled,
		                  isPromptingBiometrics: isPromptingBiometrics,
		                  pinLength: pinLength,
		                  fees: fees)
	}

	func clone(pasteboard _: String?) -> ReduxState {
		return ReduxState(isStartFlowVisible: isStartFlowVisible,
		                  isLoginRequired: isLoginRequired,
		                  rootModal: rootModal,
		                  walletState: walletState,
		                  isLtcSwapped: isLtcSwapped,
		                  currentRate: currentRate,
		                  rates: rates,
		                  alert: alert,
		                  isBiometricsEnabled: isBiometricsEnabled,
		                  userPreferredCurrencyCode: userPreferredCurrencyCode,
		                  recommendRescan: recommendRescan,
		                  isLoadingTransactions: isLoadingTransactions,
		                  maxDigits: maxDigits,
		                  isPushNotificationsEnabled: isPushNotificationsEnabled,
		                  isPromptingBiometrics: isPromptingBiometrics,
		                  pinLength: pinLength,
		                  fees: fees)
	}

	func clone(walletSyncProgress: Double, timestamp: UInt32) -> ReduxState {
		return ReduxState(isStartFlowVisible: isStartFlowVisible,
		                  isLoginRequired: isLoginRequired,
		                  rootModal: rootModal,
		                  walletState: WalletState(isConnected: walletState.isConnected, syncProgress: walletSyncProgress, syncState: walletState.syncState, balance: walletState.balance, transactions: walletState.transactions, lastBlockTimestamp: timestamp, name: walletState.name, creationDate: walletState.creationDate, isRescanning: walletState.isRescanning),
		                  isLtcSwapped: isLtcSwapped,
		                  currentRate: currentRate,
		                  rates: rates,
		                  alert: alert,
		                  isBiometricsEnabled: isBiometricsEnabled,
		                  userPreferredCurrencyCode: userPreferredCurrencyCode,
		                  recommendRescan: recommendRescan,
		                  isLoadingTransactions: isLoadingTransactions,
		                  maxDigits: maxDigits,
		                  isPushNotificationsEnabled: isPushNotificationsEnabled,
		                  isPromptingBiometrics: isPromptingBiometrics,
		                  pinLength: pinLength,
		                  fees: fees)
	}

	func clone(syncState: SyncState) -> ReduxState {
		return ReduxState(isStartFlowVisible: isStartFlowVisible,
		                  isLoginRequired: isLoginRequired,
		                  rootModal: rootModal,
		                  walletState: WalletState(isConnected: walletState.isConnected, syncProgress: walletState.syncProgress, syncState: syncState, balance: walletState.balance, transactions: walletState.transactions, lastBlockTimestamp: walletState.lastBlockTimestamp, name: walletState.name, creationDate: walletState.creationDate, isRescanning: walletState.isRescanning),
		                  isLtcSwapped: isLtcSwapped,
		                  currentRate: currentRate,
		                  rates: rates,
		                  alert: alert,
		                  isBiometricsEnabled: isBiometricsEnabled,
		                  userPreferredCurrencyCode: userPreferredCurrencyCode,
		                  recommendRescan: recommendRescan,
		                  isLoadingTransactions: isLoadingTransactions,
		                  maxDigits: maxDigits,
		                  isPushNotificationsEnabled: isPushNotificationsEnabled,
		                  isPromptingBiometrics: isPromptingBiometrics,
		                  pinLength: pinLength,
		                  fees: fees)
	}

	func clone(balance: UInt64) -> ReduxState {
		return ReduxState(isStartFlowVisible: isStartFlowVisible,
		                  isLoginRequired: isLoginRequired,
		                  rootModal: rootModal,
		                  walletState: WalletState(isConnected: walletState.isConnected, syncProgress: walletState.syncProgress, syncState: walletState.syncState, balance: balance, transactions: walletState.transactions, lastBlockTimestamp: walletState.lastBlockTimestamp, name: walletState.name, creationDate: walletState.creationDate, isRescanning: walletState.isRescanning),
		                  isLtcSwapped: isLtcSwapped,
		                  currentRate: currentRate,
		                  rates: rates,
		                  alert: alert,
		                  isBiometricsEnabled: isBiometricsEnabled,
		                  userPreferredCurrencyCode: userPreferredCurrencyCode,
		                  recommendRescan: recommendRescan,
		                  isLoadingTransactions: isLoadingTransactions,
		                  maxDigits: maxDigits,
		                  isPushNotificationsEnabled: isPushNotificationsEnabled,
		                  isPromptingBiometrics: isPromptingBiometrics,
		                  pinLength: pinLength,
		                  fees: fees)
	}

	func clone(transactions: [Transaction]) -> ReduxState {
		return ReduxState(isStartFlowVisible: isStartFlowVisible,
		                  isLoginRequired: isLoginRequired,
		                  rootModal: rootModal,
		                  walletState: WalletState(isConnected: walletState.isConnected, syncProgress: walletState.syncProgress, syncState: walletState.syncState, balance: walletState.balance, transactions: transactions, lastBlockTimestamp: walletState.lastBlockTimestamp, name: walletState.name, creationDate: walletState.creationDate, isRescanning: walletState.isRescanning),
		                  isLtcSwapped: isLtcSwapped,
		                  currentRate: currentRate,
		                  rates: rates,
		                  alert: alert,
		                  isBiometricsEnabled: isBiometricsEnabled,
		                  userPreferredCurrencyCode: userPreferredCurrencyCode,
		                  recommendRescan: recommendRescan,
		                  isLoadingTransactions: isLoadingTransactions,
		                  maxDigits: maxDigits,
		                  isPushNotificationsEnabled: isPushNotificationsEnabled,
		                  isPromptingBiometrics: isPromptingBiometrics,
		                  pinLength: pinLength,
		                  fees: fees)
	}

	func clone(walletName: String) -> ReduxState {
		return ReduxState(isStartFlowVisible: isStartFlowVisible,
		                  isLoginRequired: isLoginRequired,
		                  rootModal: rootModal,
		                  walletState: WalletState(isConnected: walletState.isConnected, syncProgress: walletState.syncProgress, syncState: walletState.syncState, balance: walletState.balance, transactions: walletState.transactions, lastBlockTimestamp: walletState.lastBlockTimestamp, name: walletName, creationDate: walletState.creationDate, isRescanning: walletState.isRescanning),
		                  isLtcSwapped: isLtcSwapped,
		                  currentRate: currentRate,
		                  rates: rates,
		                  alert: alert,
		                  isBiometricsEnabled: isBiometricsEnabled,
		                  userPreferredCurrencyCode: userPreferredCurrencyCode,
		                  recommendRescan: recommendRescan,
		                  isLoadingTransactions: isLoadingTransactions,
		                  maxDigits: maxDigits,
		                  isPushNotificationsEnabled: isPushNotificationsEnabled,
		                  isPromptingBiometrics: isPromptingBiometrics,
		                  pinLength: pinLength,
		                  fees: fees)
	}

	func clone(walletSyncingErrorMessage _: String?) -> ReduxState {
		return ReduxState(isStartFlowVisible: isStartFlowVisible,
		                  isLoginRequired: isLoginRequired,
		                  rootModal: rootModal,
		                  walletState: WalletState(isConnected: walletState.isConnected, syncProgress: walletState.syncProgress, syncState: walletState.syncState, balance: walletState.balance, transactions: walletState.transactions, lastBlockTimestamp: walletState.lastBlockTimestamp, name: walletState.name, creationDate: walletState.creationDate, isRescanning: walletState.isRescanning),
		                  isLtcSwapped: isLtcSwapped,
		                  currentRate: currentRate,
		                  rates: rates,
		                  alert: alert,
		                  isBiometricsEnabled: isBiometricsEnabled,
		                  userPreferredCurrencyCode: userPreferredCurrencyCode,
		                  recommendRescan: recommendRescan,
		                  isLoadingTransactions: isLoadingTransactions,
		                  maxDigits: maxDigits,
		                  isPushNotificationsEnabled: isPushNotificationsEnabled,
		                  isPromptingBiometrics: isPromptingBiometrics,
		                  pinLength: pinLength,
		                  fees: fees)
	}

	func clone(walletCreationDate: Date) -> ReduxState {
		return ReduxState(isStartFlowVisible: isStartFlowVisible,
		                  isLoginRequired: isLoginRequired,
		                  rootModal: rootModal,
		                  walletState: WalletState(isConnected: walletState.isConnected, syncProgress: walletState.syncProgress, syncState: walletState.syncState, balance: walletState.balance, transactions: walletState.transactions, lastBlockTimestamp: walletState.lastBlockTimestamp, name: walletState.name, creationDate: walletCreationDate, isRescanning: walletState.isRescanning),
		                  isLtcSwapped: isLtcSwapped,
		                  currentRate: currentRate,
		                  rates: rates,
		                  alert: alert,
		                  isBiometricsEnabled: isBiometricsEnabled,
		                  userPreferredCurrencyCode: userPreferredCurrencyCode,
		                  recommendRescan: recommendRescan,
		                  isLoadingTransactions: isLoadingTransactions,
		                  maxDigits: maxDigits,
		                  isPushNotificationsEnabled: isPushNotificationsEnabled,
		                  isPromptingBiometrics: isPromptingBiometrics,
		                  pinLength: pinLength,
		                  fees: fees)
	}

	func clone(isRescanning: Bool) -> ReduxState {
		return ReduxState(isStartFlowVisible: isStartFlowVisible,
		                  isLoginRequired: isLoginRequired,
		                  rootModal: rootModal,
		                  walletState: WalletState(isConnected: walletState.isConnected, syncProgress: walletState.syncProgress, syncState: walletState.syncState, balance: walletState.balance, transactions: walletState.transactions, lastBlockTimestamp: walletState.lastBlockTimestamp, name: walletState.name, creationDate: walletState.creationDate, isRescanning: isRescanning),
		                  isLtcSwapped: isLtcSwapped,
		                  currentRate: currentRate,
		                  rates: rates,
		                  alert: alert,
		                  isBiometricsEnabled: isBiometricsEnabled,
		                  userPreferredCurrencyCode: userPreferredCurrencyCode,
		                  recommendRescan: recommendRescan,
		                  isLoadingTransactions: isLoadingTransactions,
		                  maxDigits: maxDigits,
		                  isPushNotificationsEnabled: isPushNotificationsEnabled,
		                  isPromptingBiometrics: isPromptingBiometrics,
		                  pinLength: pinLength,
		                  fees: fees)
	}

	func clone(isLtcSwapped: Bool) -> ReduxState {
		return ReduxState(isStartFlowVisible: isStartFlowVisible,
		                  isLoginRequired: isLoginRequired,
		                  rootModal: rootModal,
		                  walletState: walletState,
		                  isLtcSwapped: isLtcSwapped,
		                  currentRate: currentRate,
		                  rates: rates,
		                  alert: alert,
		                  isBiometricsEnabled: isBiometricsEnabled,
		                  userPreferredCurrencyCode: userPreferredCurrencyCode,
		                  recommendRescan: recommendRescan,
		                  isLoadingTransactions: isLoadingTransactions,
		                  maxDigits: maxDigits,
		                  isPushNotificationsEnabled: isPushNotificationsEnabled,
		                  isPromptingBiometrics: isPromptingBiometrics,
		                  pinLength: pinLength,
		                  fees: fees)
	}

	func clone(isLoginRequired: Bool) -> ReduxState {
		return ReduxState(isStartFlowVisible: isStartFlowVisible,
		                  isLoginRequired: isLoginRequired,
		                  rootModal: rootModal,
		                  walletState: walletState,
		                  isLtcSwapped: isLtcSwapped,
		                  currentRate: currentRate,
		                  rates: rates,
		                  alert: alert,
		                  isBiometricsEnabled: isBiometricsEnabled,
		                  userPreferredCurrencyCode: userPreferredCurrencyCode,
		                  recommendRescan: recommendRescan,
		                  isLoadingTransactions: isLoadingTransactions,
		                  maxDigits: maxDigits,
		                  isPushNotificationsEnabled: isPushNotificationsEnabled,
		                  isPromptingBiometrics: isPromptingBiometrics,
		                  pinLength: pinLength,
		                  fees: fees)
	}

	func clone(currentRate: Rate, rates: [Rate]) -> ReduxState {
		return ReduxState(isStartFlowVisible: isStartFlowVisible,
		                  isLoginRequired: isLoginRequired,
		                  rootModal: rootModal,
		                  walletState: walletState,
		                  isLtcSwapped: isLtcSwapped,
		                  currentRate: currentRate,
		                  rates: rates,
		                  alert: alert,
		                  isBiometricsEnabled: isBiometricsEnabled,
		                  userPreferredCurrencyCode: userPreferredCurrencyCode,
		                  recommendRescan: recommendRescan,
		                  isLoadingTransactions: isLoadingTransactions,
		                  maxDigits: maxDigits,
		                  isPushNotificationsEnabled: isPushNotificationsEnabled,
		                  isPromptingBiometrics: isPromptingBiometrics,
		                  pinLength: pinLength,
		                  fees: fees)
	}

	func clone(currentRate: Rate) -> ReduxState {
		return ReduxState(isStartFlowVisible: isStartFlowVisible,
		                  isLoginRequired: isLoginRequired,
		                  rootModal: rootModal,
		                  walletState: walletState,
		                  isLtcSwapped: isLtcSwapped,
		                  currentRate: currentRate,
		                  rates: rates,
		                  alert: alert,
		                  isBiometricsEnabled: isBiometricsEnabled,
		                  userPreferredCurrencyCode: userPreferredCurrencyCode,
		                  recommendRescan: recommendRescan,
		                  isLoadingTransactions: isLoadingTransactions,
		                  maxDigits: maxDigits,
		                  isPushNotificationsEnabled: isPushNotificationsEnabled,
		                  isPromptingBiometrics: isPromptingBiometrics,
		                  pinLength: pinLength,
		                  fees: fees)
	}

	func clone(alert: AlertType?) -> ReduxState {
		return ReduxState(isStartFlowVisible: isStartFlowVisible,
		                  isLoginRequired: isLoginRequired,
		                  rootModal: rootModal,
		                  walletState: walletState,
		                  isLtcSwapped: isLtcSwapped,
		                  currentRate: currentRate,
		                  rates: rates,
		                  alert: alert,
		                  isBiometricsEnabled: isBiometricsEnabled,
		                  userPreferredCurrencyCode: userPreferredCurrencyCode,
		                  recommendRescan: recommendRescan,
		                  isLoadingTransactions: isLoadingTransactions,
		                  maxDigits: maxDigits,
		                  isPushNotificationsEnabled: isPushNotificationsEnabled,
		                  isPromptingBiometrics: isPromptingBiometrics,
		                  pinLength: pinLength,
		                  fees: fees)
	}

	func clone(isBiometricsEnabled: Bool) -> ReduxState {
		return ReduxState(isStartFlowVisible: isStartFlowVisible,
		                  isLoginRequired: isLoginRequired,
		                  rootModal: rootModal,
		                  walletState: walletState,
		                  isLtcSwapped: isLtcSwapped,
		                  currentRate: currentRate,
		                  rates: rates,
		                  alert: alert,
		                  isBiometricsEnabled: isBiometricsEnabled,
		                  userPreferredCurrencyCode: userPreferredCurrencyCode,
		                  recommendRescan: recommendRescan,
		                  isLoadingTransactions: isLoadingTransactions,
		                  maxDigits: maxDigits,
		                  isPushNotificationsEnabled: isPushNotificationsEnabled,
		                  isPromptingBiometrics: isPromptingBiometrics,
		                  pinLength: pinLength,
		                  fees: fees)
	}

	func clone(userPreferredCurrencyCode: String) -> ReduxState {
		return ReduxState(isStartFlowVisible: isStartFlowVisible,
		                  isLoginRequired: isLoginRequired,
		                  rootModal: rootModal,
		                  walletState: walletState,
		                  isLtcSwapped: isLtcSwapped,
		                  currentRate: currentRate,
		                  rates: rates,
		                  alert: alert,
		                  isBiometricsEnabled: isBiometricsEnabled,
		                  userPreferredCurrencyCode: userPreferredCurrencyCode,
		                  recommendRescan: recommendRescan,
		                  isLoadingTransactions: isLoadingTransactions,
		                  maxDigits: maxDigits,
		                  isPushNotificationsEnabled: isPushNotificationsEnabled,
		                  isPromptingBiometrics: isPromptingBiometrics,
		                  pinLength: pinLength,
		                  fees: fees)
	}

	func clone(recommendRescan: Bool) -> ReduxState {
		return ReduxState(isStartFlowVisible: isStartFlowVisible,
		                  isLoginRequired: isLoginRequired,
		                  rootModal: rootModal,
		                  walletState: walletState,
		                  isLtcSwapped: isLtcSwapped,
		                  currentRate: currentRate,
		                  rates: rates,
		                  alert: alert,
		                  isBiometricsEnabled: isBiometricsEnabled,
		                  userPreferredCurrencyCode: userPreferredCurrencyCode,
		                  recommendRescan: recommendRescan,
		                  isLoadingTransactions: isLoadingTransactions,
		                  maxDigits: maxDigits,
		                  isPushNotificationsEnabled: isPushNotificationsEnabled,
		                  isPromptingBiometrics: isPromptingBiometrics,
		                  pinLength: pinLength,
		                  fees: fees)
	}

	func clone(isLoadingTransactions: Bool) -> ReduxState {
		return ReduxState(isStartFlowVisible: isStartFlowVisible,
		                  isLoginRequired: isLoginRequired,
		                  rootModal: rootModal,
		                  walletState: walletState,
		                  isLtcSwapped: isLtcSwapped,
		                  currentRate: currentRate,
		                  rates: rates,
		                  alert: alert,
		                  isBiometricsEnabled: isBiometricsEnabled,
		                  userPreferredCurrencyCode: userPreferredCurrencyCode,
		                  recommendRescan: recommendRescan,
		                  isLoadingTransactions: isLoadingTransactions,
		                  maxDigits: maxDigits,
		                  isPushNotificationsEnabled: isPushNotificationsEnabled,
		                  isPromptingBiometrics: isPromptingBiometrics,
		                  pinLength: pinLength,
		                  fees: fees)
	}

	func clone(maxDigits: Int) -> ReduxState {
		return ReduxState(isStartFlowVisible: isStartFlowVisible,
		                  isLoginRequired: isLoginRequired,
		                  rootModal: rootModal,
		                  walletState: walletState,
		                  isLtcSwapped: isLtcSwapped,
		                  currentRate: currentRate,
		                  rates: rates,
		                  alert: alert,
		                  isBiometricsEnabled: isBiometricsEnabled,
		                  userPreferredCurrencyCode: userPreferredCurrencyCode,
		                  recommendRescan: recommendRescan,
		                  isLoadingTransactions: isLoadingTransactions,
		                  maxDigits: maxDigits,
		                  isPushNotificationsEnabled: isPushNotificationsEnabled,
		                  isPromptingBiometrics: isPromptingBiometrics,
		                  pinLength: pinLength,
		                  fees: fees)
	}

	func clone(isPushNotificationsEnabled: Bool) -> ReduxState {
		return ReduxState(isStartFlowVisible: isStartFlowVisible,
		                  isLoginRequired: isLoginRequired,
		                  rootModal: rootModal,
		                  walletState: walletState,
		                  isLtcSwapped: isLtcSwapped,
		                  currentRate: currentRate,
		                  rates: rates,
		                  alert: alert,
		                  isBiometricsEnabled: isBiometricsEnabled,
		                  userPreferredCurrencyCode: userPreferredCurrencyCode,
		                  recommendRescan: recommendRescan,
		                  isLoadingTransactions: isLoadingTransactions,
		                  maxDigits: maxDigits,
		                  isPushNotificationsEnabled: isPushNotificationsEnabled,
		                  isPromptingBiometrics: isPromptingBiometrics,
		                  pinLength: pinLength,
		                  fees: fees)
	}

	func clone(isPromptingBiometrics: Bool) -> ReduxState {
		return ReduxState(isStartFlowVisible: isStartFlowVisible,
		                  isLoginRequired: isLoginRequired,
		                  rootModal: rootModal,
		                  walletState: walletState,
		                  isLtcSwapped: isLtcSwapped,
		                  currentRate: currentRate,
		                  rates: rates,
		                  alert: alert,
		                  isBiometricsEnabled: isBiometricsEnabled,
		                  userPreferredCurrencyCode: userPreferredCurrencyCode,
		                  recommendRescan: recommendRescan,
		                  isLoadingTransactions: isLoadingTransactions,
		                  maxDigits: maxDigits,
		                  isPushNotificationsEnabled: isPushNotificationsEnabled,
		                  isPromptingBiometrics: isPromptingBiometrics,
		                  pinLength: pinLength,
		                  fees: fees)
	}

	func clone(pinLength: Int) -> ReduxState {
		return ReduxState(isStartFlowVisible: isStartFlowVisible,
		                  isLoginRequired: isLoginRequired,
		                  rootModal: rootModal,
		                  walletState: walletState,
		                  isLtcSwapped: isLtcSwapped,
		                  currentRate: currentRate,
		                  rates: rates,
		                  alert: alert,
		                  isBiometricsEnabled: isBiometricsEnabled,
		                  userPreferredCurrencyCode: userPreferredCurrencyCode,
		                  recommendRescan: recommendRescan,
		                  isLoadingTransactions: isLoadingTransactions,
		                  maxDigits: maxDigits,
		                  isPushNotificationsEnabled: isPushNotificationsEnabled,
		                  isPromptingBiometrics: isPromptingBiometrics,
		                  pinLength: pinLength,
		                  fees: fees)
	}

	func clone(fees: Fees) -> ReduxState {
		return ReduxState(isStartFlowVisible: isStartFlowVisible,
		                  isLoginRequired: isLoginRequired,
		                  rootModal: rootModal,
		                  walletState: walletState,
		                  isLtcSwapped: isLtcSwapped,
		                  currentRate: currentRate,
		                  rates: rates,
		                  alert: alert,
		                  isBiometricsEnabled: isBiometricsEnabled,
		                  userPreferredCurrencyCode: userPreferredCurrencyCode,
		                  recommendRescan: recommendRescan,
		                  isLoadingTransactions: isLoadingTransactions,
		                  maxDigits: maxDigits,
		                  isPushNotificationsEnabled: isPushNotificationsEnabled,
		                  isPromptingBiometrics: isPromptingBiometrics,
		                  pinLength: pinLength,
		                  fees: fees)
	}
}
