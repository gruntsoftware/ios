import Foundation

private let defaults = UserDefaults.standard
private let isBiometricsEnabledKey = "isbiometricsenabled"
private let userPreferredCurrencyCodeKey = "defaultcurrency"
private let userPreferredBuyCurrencyKey = "userPreferredBuyCurrency"
private let hasAquiredShareDataPermissionKey = "has_acquired_permission"
private let legacyWalletNeedsBackupKey = "WALLET_NEEDS_BACKUP"
private let writePaperPhraseDateKey = "writepaperphrasedatekey"
private let hasPromptedBiometricsKey = "haspromptedtouched"
private let isLTCValueShownKey = "isLTCValueShownKey"
private let maxDigitsKey = "SETTINGS_MAX_DIGITS"
private let pushTokenKey = "pushTokenKey"
private let currentRateKey = "currentRateKey"
private let customNodeIPKey = "customNodeIPKey"
private let customNodePortKey = "customNodePortKey"
private let hasPromptedShareDataKey = "hasPromptedShareDataKey"
private let didSeeTransactionCorruption = "DidSeeTransactionCorruption"
private let hasLoggedInitialSyncDurationKey = "hasLoggedInitialSyncDurationKey"
private let foregroundSyncDurationSecondsKey = "foregroundSyncDurationSecondsKey"
private let pendingNotificationBadgeCountKey = "pendingNotificationBadgeCountKey"

let timeSinceLastExitKey = "TimeSinceLastExit"
let shouldRequireLoginTimeoutKey = "ShouldRequireLoginTimeoutKey"
let numberOfBrainwalletLaunches = "NumberOfBrainwalletLaunches"
let appHasRequestedReviewKey = "appHasRequestedReviewKey"
let userDidPreferDarkModeKey = "UserDidPreferDarkMode"
let userCurrentLocaleMPApprovedKey = "UserCurrentLocaleMPApproved"

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
    static let walletDidIntializeNotification: Notification.Name = Notification.Name("WalletDidIntialize")
}

extension UserDefaults {

    static var userCanBuyInCurrentLocale: Bool {
        get {
            guard defaults.object(forKey: userCurrentLocaleMPApprovedKey) != nil
            else {
                return false
            }
            return defaults.bool(forKey: userCurrentLocaleMPApprovedKey)
        }
        set { defaults.set(newValue, forKey: userCurrentLocaleMPApprovedKey) }
    }

	static var isBiometricsEnabled: Bool {
		get {
			guard defaults.object(forKey: isBiometricsEnabledKey) != nil
			else {
				return false
			}
			return defaults.bool(forKey: isBiometricsEnabledKey)
		}
		set { defaults.set(newValue, forKey: isBiometricsEnabledKey) }
	}

    static var  appHasRequestedReview: Bool {
        get {
            guard defaults.object(forKey: appHasRequestedReviewKey) != nil
            else {
                return false
            }
            return defaults.bool(forKey: appHasRequestedReviewKey)
        }
        set { defaults.set(newValue, forKey: appHasRequestedReviewKey) }
    }

	static var didSeeCorruption: Bool {
		get { return defaults.bool(forKey: didSeeTransactionCorruption) }
		set { defaults.set(newValue, forKey: didSeeTransactionCorruption) }
	}

	static var userPreferredCurrencyCode: String {
		get {
			var currencyCode = "USD"

			if defaults.object(forKey: userPreferredCurrencyCodeKey) == nil {
                if let localeCode: String = Locale.current.currency?.identifier {
                    currencyCode = localeCode
                }
			} else {
				currencyCode = defaults.string(forKey: userPreferredCurrencyCodeKey)!
			}
			return currencyCode
		}
        set {
            defaults.set(newValue, forKey: userPreferredCurrencyCodeKey)
        }
	}

    static var userPreferredDarkTheme: Bool {
        get {
            guard defaults.object(forKey: userDidPreferDarkModeKey) != nil
            else {
                return false
            }
            return defaults.bool(forKey: userDidPreferDarkModeKey)
        }
        set { defaults.set(newValue, forKey: userDidPreferDarkModeKey) }
    }

    static var userPreferredBuyCurrency: String {
        get {
            var currencyCode = "USD"
            if defaults.object(forKey: userPreferredBuyCurrencyKey) == nil {
                currencyCode = "USD"
            } else {
                currencyCode = defaults.string(forKey: userPreferredBuyCurrencyKey)!
            }
            return currencyCode
        }
        set { defaults.set(newValue, forKey: userPreferredBuyCurrencyKey) }
    }

	static var hasAquiredShareDataPermission: Bool {
		get { return defaults.bool(forKey: hasAquiredShareDataPermissionKey) }
		set { defaults.set(newValue, forKey: hasAquiredShareDataPermissionKey) }
	}

	static var isLTCValueShown: Bool {
		get { return defaults.bool(forKey: isLTCValueShownKey)
		}
		set { defaults.set(newValue, forKey: isLTCValueShownKey) }
	}

	//
	// 2 - photons
	// 5 - lites
	// 8 - LTC
	//
	static var maxDigits: Int {
		get {
			guard defaults.object(forKey: maxDigitsKey) != nil
			else {
				return 8 /// Default to LTC
			}
			return defaults.integer(forKey: maxDigitsKey)
		}
		set { defaults.set(newValue, forKey: maxDigitsKey) }
	}

	static var pushToken: Data? {
		get {
			guard defaults.object(forKey: pushTokenKey) != nil
			else {
				return nil
			}
			return defaults.data(forKey: pushTokenKey)
		}
		set { defaults.set(newValue, forKey: pushTokenKey) }
	}

	static var currentRate: Rate? {
		guard let data = defaults.object(forKey: currentRateKey) as? [String: Any]
		else {
			return nil
		}
		return Rate(data: data)
	}

	static var currentRateData: [String: Any]? {
		get {
			guard let data = defaults.object(forKey: currentRateKey) as? [String: Any]
			else {
				return nil
			}
			return data
		}
		set { defaults.set(newValue, forKey: currentRateKey) }
	}

	static var customNodeIP: Int? {
		get {
			guard defaults.object(forKey: customNodeIPKey) != nil else { return nil }
			return defaults.integer(forKey: customNodeIPKey)
		}
		set { defaults.set(newValue, forKey: customNodeIPKey) }
	}

	static var customNodePort: Int? {
		get {
			guard defaults.object(forKey: customNodePortKey) != nil else { return nil }
			return defaults.integer(forKey: customNodePortKey)
		}
		set { defaults.set(newValue, forKey: customNodePortKey) }
	}

	static var hasPromptedShareData: Bool {
		get { return defaults.bool(forKey: hasPromptedBiometricsKey) }
		set { defaults.set(newValue, forKey: hasPromptedBiometricsKey) }
	}
}

// MARK: - Wallet Requires Backup

extension UserDefaults {
	static var legacyWalletNeedsBackup: Bool? {
		guard defaults.object(forKey: legacyWalletNeedsBackupKey) != nil
		else {
			return nil
		}
		return defaults.bool(forKey: legacyWalletNeedsBackupKey)
	}

	static func removeLegacyWalletNeedsBackupKey() {
		defaults.removeObject(forKey: legacyWalletNeedsBackupKey)
	}

	static var writePaperPhraseDate: Date? {
		get { return defaults.object(forKey: writePaperPhraseDateKey) as! Date? }
		set { defaults.set(newValue, forKey: writePaperPhraseDateKey) }
	}

	static var walletRequiresBackup: Bool {
		if UserDefaults.writePaperPhraseDate != nil {
			return false
		} else {
			return true
		}
	}
}

// MARK: - Prompts

extension UserDefaults {
	static var hasPromptedBiometrics: Bool {
		get { return defaults.bool(forKey: hasPromptedBiometricsKey) }
		set { defaults.set(newValue, forKey: hasPromptedBiometricsKey) }
	}
}

// MARK: - Analytics

extension UserDefaults {
	/// Whether the one-time "time to first sync" duration metric has already
	/// been sent for this wallet. Set once, right after the metric is logged,
	/// so it fires exactly once per wallet (not on every subsequent app
	/// launch's incremental catch-up sync).
	static var hasLoggedInitialSyncDuration: Bool {
		get { return defaults.bool(forKey: hasLoggedInitialSyncDurationKey) }
		set { defaults.set(newValue, forKey: hasLoggedInitialSyncDurationKey) }
	}

	/// Running total of wall-clock seconds spent actively syncing (peer
	/// manager in .syncing state) while the app was in the foreground,
	/// accumulated across every sync segment up to the first time progress
	/// crosses the completion threshold. A "segment" is one continuous
	/// stretch of active foreground syncing — backgrounding, a connectivity
	/// drop, or leaving .syncing closes the current segment; becoming active
	/// again while still mid-sync opens a new one. This deliberately excludes
	/// time spent backgrounded/closed, so it reflects actual sync speed
	/// rather than how long the user took to reopen the app.
	///
	/// Implicitly reset whenever the wallet is wiped
	/// (WalletManager.wipeWallet() removes the whole persistent domain).
	static var foregroundSyncDurationSeconds: TimeInterval {
		get { return defaults.double(forKey: foregroundSyncDurationSecondsKey) }
		set { defaults.set(newValue, forKey: foregroundSyncDurationSecondsKey) }
	}
}

// MARK: - Notifications

extension UserDefaults {
	/// Mirrors the badge count this app has last asked UNUserNotificationCenter
	/// to display. UIApplication.applicationIconBadgeNumber -- the old
	/// synchronous getter/setter -- was deprecated in iOS 17 in favor of
	/// UNUserNotificationCenter.setBadgeCount(_:withCompletionHandler:), which
	/// has no matching getter, so this is the app's own record of what it last
	/// set. Kept in sync with the two places that reset the system badge to 0
	/// (AppDelegate's launch and applicationDidBecomeActive).
	static var pendingNotificationBadgeCount: Int {
		get { return defaults.integer(forKey: pendingNotificationBadgeCountKey) }
		set { defaults.set(newValue, forKey: pendingNotificationBadgeCountKey) }
	}
}
