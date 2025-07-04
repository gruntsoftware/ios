import Foundation

private let defaults = UserDefaults.standard
private let isBiometricsEnabledKey = "isbiometricsenabled"
private let userPreferredCurrencyCodeKey = "defaultcurrency"
private let userPreferredBuyCurrencyKey = "userPreferredBuyCurrency"
private let hasAquiredShareDataPermissionKey = "has_acquired_permission"
private let legacyWalletNeedsBackupKey = "WALLET_NEEDS_BACKUP"
private let writePaperPhraseDateKey = "writepaperphrasedatekey"
private let hasPromptedBiometricsKey = "haspromptedtouched"
private let isLtcSwappedKey = "isLtcSwappedKey"
private let maxDigitsKey = "SETTINGS_MAX_DIGITS"
private let pushTokenKey = "pushTokenKey"
private let currentRateKey = "currentRateKey"
private let customNodeIPKey = "customNodeIPKey"
private let customNodePortKey = "customNodePortKey"
private let hasPromptedShareDataKey = "hasPromptedShareDataKey"
private let didSeeTransactionCorruption = "DidSeeTransactionCorruption"
private let userIsInUSAKey = "userIsInUSAKey"
private let selectedLanguageKey = "selectedLanguage"

let timeSinceLastExitKey = "TimeSinceLastExit"
let shouldRequireLoginTimeoutKey = "ShouldRequireLoginTimeoutKey"
let numberOfBrainwalletLaunches = "NumberOfBrainwalletLaunches"
let userDidPreferDarkModeKey = "UserDidPreferDarkMode"
let userCurrentLocaleMPApprovedKey = "UserCurrentLocaleMPApproved"

extension UserDefaults {
	static var selectedLanguage: String {
		get {
			guard defaults.object(forKey: selectedLanguageKey) != nil else {
				return "en"
			}
			return defaults.string(forKey: selectedLanguageKey) ?? "en"
		}
		set { defaults.set(newValue, forKey: selectedLanguageKey) }
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

	static var isLtcSwapped: Bool {
		get { return defaults.bool(forKey: isLtcSwappedKey)
		}
		set { defaults.set(newValue, forKey: isLtcSwappedKey) }
	}

	static var userIsInUSA: Bool {
		get { return defaults.bool(forKey: userIsInUSAKey)
		}
		set { defaults.set(newValue, forKey: userIsInUSAKey) }
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
