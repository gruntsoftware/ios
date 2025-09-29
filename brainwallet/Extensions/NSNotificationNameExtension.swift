import Foundation

public extension NSNotification.Name {
	static let walletBalanceChangedNotification = NSNotification.Name("WalletBalanceChanged")
	static let walletTxStatusUpdateNotification = NSNotification.Name("WalletTxStatusUpdate")
	static let walletTxRejectedNotification = NSNotification.Name("WalletTxRejected")
	static let walletSyncStartedNotification = NSNotification.Name("WalletSyncStarted")
	static let walletSyncStoppedNotification = NSNotification.Name("WalletSyncStopped")
	static let walletDidWipeNotification = NSNotification.Name("WalletDidWipe")
    static let didCompleteOnboardingNotification = NSNotification.Name("DidCompleteOnboarding")
	static let didDeleteWalletDBNotification = NSNotification.Name("DidDeleteDatabase")
	static let languageChangedNotification = Notification.Name("languageChanged")
    static let preferredCurrencyChangedNotification = Notification.Name("currencyChanged")
    static let userTapsClosePromptNotification = Notification.Name("userTapClosePrompt")
    static let userTapsContinuePromptNotification = Notification.Name("userTapContinuePrompt")
    static let changedThemePreferenceNotification = Notification.Name("changedThemePreference")
    static let transactionsDidScrollNotification = Notification.Name("transactionsDidScroll")
    static let transactionsStoppedScrollNotification = Notification.Name("transactionsStoppedScroll")
    static let transactionsCountUpdateNotification = Notification.Name("transactionsCountUpdate")
    static let transactionsDataUpdateNotification = Notification.Name("transactionsDataUpdate")

}
