import BRCore
import FirebaseAnalytics
import Foundation
import LocalAuthentication
import SQLite3
import UIKit
import CryptoKit

private let WalletSecAttrService = "ltd.gruntsoftware.brainwallet"
private let BIP39CreationTime = TimeInterval(BIP39_CREATION_TIME) - NSTimeIntervalSince1970

/// WalletAuthenticator is a protocol whose implementors are able to interact with wallet authentication
public protocol WalletAuthenticator {
	var noWallet: Bool { get }
	var apiAuthKey: String? { get }
	var userAccount: [AnyHashable: Any]? { get set }
}

struct NoAuthAuthenticator: WalletAuthenticator {
	let noWallet = true
	let apiAuthKey: String? = nil
	var userAccount: [AnyHashable: Any]?
}

enum BiometricsResult {
	case success
	case cancel
	case fallback
	case failure
}

enum TransferCardResult {
	case success
	case cancel
	case fallback
	case failure
}

extension WalletManager: WalletAuthenticator {
	private static var failedPins = [String]()

	convenience init(store: Store, dbPath: String? = nil) throws {
		Task {
			if await !UIApplication.shared.isProtectedDataAvailable {
				throw NSError(domain: NSOSStatusErrorDomain, code: Int(errSecNotAvailable))
			}
		}

		if try keychainItem(key: KeychainKey.seed) as Data? != nil { // upgrade from old keychain scheme
			let seedPhrase: String? = try keychainItem(key: KeychainKey.mnemonic)
			var seed = UInt512()
			debugPrint(":::upgrading to authenticated keychain scheme")
			BRBIP39DeriveKey(&seed, seedPhrase, nil)
			let mpk = BRBIP32MasterPubKey(&seed, MemoryLayout<UInt512>.size)
			seed = UInt512() // clear seed
			try setKeychainItem(key: KeychainKey.mnemonic, item: seedPhrase, authenticated: true)
			try setKeychainItem(key: KeychainKey.masterPubKey, item: Data(masterPubKey: mpk))
			try setKeychainItem(key: KeychainKey.seed, item: nil as Data?)
		}

		let mpkData: Data? = try keychainItem(key: KeychainKey.masterPubKey)
		guard let masterPubKey = mpkData?.masterPubKey
		else {
			try self.init(masterPubKey: BRMasterPubKey(),
			              earliestKeyTime: 0,
			              dbPath: dbPath,
			              store: store,
			              fpRate: FalsePositiveRates.semiPrivate.rawValue)
			return
		}

		var earliestKeyTime = BIP39CreationTime
		if let creationTime: Data = try keychainItem(key: KeychainKey.creationTime),
		   creationTime.count == MemoryLayout<TimeInterval>.stride {
			creationTime.withUnsafeBytes { earliestKeyTime = $0.pointee }
		}

		try self.init(masterPubKey: masterPubKey,
		              earliestKeyTime: earliestKeyTime,
		              dbPath: dbPath,
		              store: store,
		              fpRate: FalsePositiveRates.semiPrivate.rawValue)
	}

	// true if keychain is available and we know that no wallet exists on it
	var noWallet: Bool {
		if didInitWallet { return false }
		return WalletManager.staticNoWallet
	}

	static var staticNoWallet: Bool {
		do {
			if try keychainItem(key: KeychainKey.masterPubKey) as Data? != nil { return false }
			if try keychainItem(key: KeychainKey.seed) as Data? != nil { return false } // check for old keychain scheme
			return true
		} catch { return false }
	}

	// Login with pin should be required if the pin hasn't been used within a week
	var pinLoginRequired: Bool {
		let pinUnlockTime = UserDefaults.standard.double(forKey: DefaultsKey.pinUnlockTime)
		let now = Date.timeIntervalSinceReferenceDate
		let secondsInWeek = 60.0 * 60.0 * 24.0 * 7.0
		return now - pinUnlockTime > secondsInWeek
	}

	// true if the given transaction can be signed with biometric authentication
	func canUseBiometrics(forTx: BRTxRef) -> Bool {
		guard LAContext.canUseBiometrics else { return false }

		do {
			let spendLimit: Int64 = try keychainItem(key: KeychainKey.spendLimit) ?? 0
			guard let wallet = wallet else { assertionFailure("No wallet!"); return false }
			return wallet.amountSentByTx(forTx) - wallet.amountReceivedFromTx(forTx) + wallet.totalSent <= UInt64(spendLimit)
		} catch { return false }
	}

	var spendingLimit: UInt64 {
		get {
			guard UserDefaults.standard.object(forKey: DefaultsKey.spendLimitAmount) != nil
			else {
				return 0
			}
			return UInt64(UserDefaults.standard.double(forKey: DefaultsKey.spendLimitAmount))
		}
		set {
			guard let wallet = wallet
			else {
				assertionFailure("No wallet!")
				return
			}
			do {
				try setKeychainItem(key: KeychainKey.spendLimit, item: Int64(wallet.totalSent + newValue))
				UserDefaults.standard.set(newValue, forKey: DefaultsKey.spendLimitAmount)
			} catch {
				debugPrint(":::Set spending limit error: \(error)")
			}
		}
	}

	// number of unique failed pin attempts remaining before wallet is wiped
	var pinAttemptsRemaining: Int {
		do {
			let failCount: Int64 = try keychainItem(key: KeychainKey.pinFailCount) ?? 0
			return Int(8 - failCount)
		} catch { return -1 }
	}

	// after 3 or more failed pin attempts, authentication is disabled until this time (interval since reference date)
	var walletDisabledUntil: TimeInterval {
		do {
			let failCount: Int64 = try keychainItem(key: KeychainKey.pinFailCount) ?? 0
			guard failCount >= 3 else { return 0 }
			let failTime: Int64 = try keychainItem(key: KeychainKey.pinFailTime) ?? 0
			return Double(failTime) + pow(6, Double(failCount - 3)) * 60
		} catch {
			assertionFailure("Error: \(error)")
			return 0
		}
	}

	// Can be expensive...result should be cached
	var pinLength: Int {
		do {
			if let pin: String = try keychainItem(key: KeychainKey.pin) {
				return pin.utf8.count
			} else {
				return kPinDigitConstant
			}
		} catch {
			debugPrint(":::Pin keychain error: \(error)")
			return kPinDigitConstant
		}
	}

	// true if pin is correct
	func authenticate(pin: String) -> Bool {
		do {
			if try pin == keychainItem(key: KeychainKey.pin) {
				try authenticationSuccess()
				return true
            } else {
                return false
            }
		} catch {
			assertionFailure("Error: \(error)")
			return false
		}
	}

	// true if phrase is correct
	func authenticate(phrase: String) -> Bool {
		do {
			var seed = UInt512()
			guard let nfkdPhrase = CFStringCreateMutableCopy(secureAllocator, 0, phrase as CFString)
			else { return false }
			CFStringNormalize(nfkdPhrase, .KD)
			BRBIP39DeriveKey(&seed, nfkdPhrase as String, nil)
			let mpk = BRBIP32MasterPubKey(&seed, MemoryLayout<UInt512>.size)
			seed = UInt512() // clear seed
			let mpkData: Data? = try keychainItem(key: KeychainKey.masterPubKey)
			guard mpkData?.masterPubKey == mpk else { return false }
			return true
		} catch {
			return false
		}
	}

	private func authenticationSuccess() throws {
		let limit = Int64(UserDefaults.standard.double(forKey: DefaultsKey.spendLimitAmount))

		WalletManager.failedPins.removeAll()
		UserDefaults.standard.set(Date.timeIntervalSinceReferenceDate, forKey: DefaultsKey.pinUnlockTime)
		try setKeychainItem(key: KeychainKey.pinFailTime, item: Int64(0))
		try setKeychainItem(key: KeychainKey.pinFailCount, item: Int64(0))

		if let wallet = wallet, limit > 0 {
			try setKeychainItem(key: KeychainKey.spendLimit,
			                    item: Int64(wallet.totalSent) + limit)
		}
	}

	// show biometric dialog and call completion block with success or failure
	func authenticate(biometricsPrompt: String, completion: @escaping (BiometricsResult) -> Void) {
		let policy = LAPolicy.deviceOwnerAuthenticationWithBiometrics
		LAContext().evaluatePolicy(policy, localizedReason: biometricsPrompt,
		                           reply: { success, error in
		                           	DispatchQueue.main.async {
		                           		if success { return completion(.success) }
		                           		guard let error = error else { return completion(.failure) }
		                           		if error._code == Int(kLAErrorUserCancel) {
		                           			return completion(.cancel)
		                           		} else if error._code == Int(kLAErrorUserFallback) {
		                           			return completion(.fallback)
		                           		}
		                           		completion(.failure)
		                           	}
		                           })
	}

	// sign the given transaction using pin authentication
	func signTransaction(_ tx: BRTxRef, forkId: Int = 0, pin: String) -> Bool {
		guard authenticate(pin: pin) else { return false }
		return signTx(tx, forkId: forkId)
	}

	// sign the given transaction using biometric authentication
	func signTransaction(_ tx: BRTxRef, biometricsPrompt: String, completion: @escaping (BiometricsResult) -> Void) {
		do {
			let spendLimit: Int64 = try keychainItem(key: KeychainKey.spendLimit) ?? 0
			guard let wallet = wallet, wallet.amountSentByTx(tx) - wallet.amountReceivedFromTx(tx) + wallet.totalSent <= UInt64(spendLimit)
			else {
				return completion(.failure)
			}
		} catch { return completion(.failure) }
		store.perform(action: biometricsActions.setIsPrompting(true))
		authenticate(biometricsPrompt: biometricsPrompt) { result in
			self.store.perform(action: biometricsActions.setIsPrompting(false))
			guard result == .success else { return completion(result) }
			completion(self.signTx(tx) == true ? .success : .failure)
		}
	}

	// the 12 word wallet recovery phrase
	func seedPhrase(pin: String) -> String? {
		guard authenticate(pin: pin) else { return nil }

		do {
			return try keychainItem(key: KeychainKey.mnemonic)
		} catch { return nil }
	}

	// recover an existing wallet using 12 word wallet recovery phrase
	// will fail if a wallet already exists on the keychain
	func setSeedPhrase(_ phrase: String) -> Bool {
		guard noWallet else { return false }

		do {
			guard let nfkdPhrase = CFStringCreateMutableCopy(secureAllocator, 0, phrase as CFString)
			else { return false }
			CFStringNormalize(nfkdPhrase, .KD)
			var seed = UInt512()
			try setKeychainItem(key: KeychainKey.mnemonic, item: nfkdPhrase as String?, authenticated: true)
			BRBIP39DeriveKey(&seed, nfkdPhrase as String, nil)
			masterPubKey = BRBIP32MasterPubKey(&seed, MemoryLayout<UInt512>.size)
			seed = UInt512() // clear seed
			if earliestKeyTime < BIP39CreationTime { earliestKeyTime = BIP39CreationTime }
			try setKeychainItem(key: KeychainKey.masterPubKey, item: Data(masterPubKey: masterPubKey))
			return true
		} catch { return false }
	}

	// create a new wallet and return the 12 word wallet recovery phrase
	// will fail if a wallet already exists on the keychain
	func setRandomSeedPhrase() -> String? {
		guard noWallet else { return nil }
		guard var words = rawWordList else { return nil }
		let time = Date.timeIntervalSinceReferenceDate

		// we store the wallet creation time on the keychain because keychain data persists even when app is deleted
		do {
			try setKeychainItem(key: KeychainKey.creationTime,
			                    item: [time].withUnsafeBufferPointer { Data(buffer: $0) })
			earliestKeyTime = time
		} catch { return nil }

		// wrapping in an autorelease pool ensures sensitive memory is wiped and released immediately
		return autoreleasepool {
			var entropy = UInt128()
			let entropyRef = UnsafeMutableRawPointer(mutating: &entropy).assumingMemoryBound(to: UInt8.self)
			guard SecRandomCopyBytes(kSecRandomDefault, MemoryLayout<UInt128>.size, entropyRef) == 0
			else { return nil }
			let phraseLen = BRBIP39Encode(nil, 0, &words, entropyRef, MemoryLayout<UInt128>.size)
			var phraseData = CFDataCreateMutable(secureAllocator, phraseLen) as Data
			phraseData.count = phraseLen
			guard phraseData.withUnsafeMutableBytes({
				BRBIP39Encode($0, phraseLen, &words, entropyRef, MemoryLayout<UInt128>.size)
			}) == phraseData.count else { return nil }
			entropy = UInt128()
			let phrase = CFStringCreateFromExternalRepresentation(secureAllocator, phraseData as CFData,
			                                                      CFStringBuiltInEncodings.UTF8.rawValue) as String
			guard setSeedPhrase(phrase) else { return nil }
			return phrase
		}
	}

	// change wallet authentication pin
	func changePin(newPin: String, pin: String) -> Bool {
		guard authenticate(pin: pin) else { return false }
		do {
			store.perform(action: PinLength.set(newPin.utf8.count))
			try setKeychainItem(key: KeychainKey.pin, item: newPin)
			return true
		} catch { return false }
	}

	// change wallet authentication pin using the wallet recovery phrase
	// recovery phrase is optional if no pin is currently set
	func forceSetPin(newPin: String, seedPhrase: String? = nil) -> Bool {
		do {
			if let phrase = seedPhrase {
				var seed = UInt512()
				guard let nfkdPhrase = CFStringCreateMutableCopy(secureAllocator, 0, phrase as CFString)
				else { return false }
				CFStringNormalize(nfkdPhrase, .KD)
				BRBIP39DeriveKey(&seed, nfkdPhrase as String, nil)
				let mpk = BRBIP32MasterPubKey(&seed, MemoryLayout<UInt512>.size)
				seed = UInt512() // clear seed
				let mpkData: Data? = try keychainItem(key: KeychainKey.masterPubKey)
				guard mpkData?.masterPubKey == mpk else { return false }
			} else if try keychainItem(key: KeychainKey.pin) as String? != nil {
				return authenticate(pin: newPin)
			}
			store.perform(action: PinLength.set(newPin.utf8.count))
			try setKeychainItem(key: KeychainKey.pin, item: newPin)
			try authenticationSuccess()
			return true
		} catch { return false }
	}

	// wipe the existing wallet from the keychain
	func wipeWallet(pin: String = "forceWipe") -> Bool {
		guard pin == "forceWipe" || authenticate(pin: pin) else { return false }

		do {
			lazyWallet = nil
			lazyPeerManager = nil
			if db != nil { sqlite3_close(db) }
			db = nil
			masterPubKey = BRMasterPubKey()
			didInitWallet = false
			earliestKeyTime = 0
			if let bundleId = Bundle.main.bundleIdentifier {
				UserDefaults.standard.removePersistentDomain(forName: bundleId)
			}
			try BWAPIClient(authenticator: self).kv?.rmdb()
			try? FileManager.default.removeItem(atPath: dbPath)
			try? FileManager.default.removeItem(at: BRReplicatedKVStore.dbPath)
			try setKeychainItem(key: KeychainKey.apiAuthKey, item: nil as Data?)
			try setKeychainItem(key: KeychainKey.spendLimit, item: nil as Int64?)
			try setKeychainItem(key: KeychainKey.creationTime, item: nil as Data?)
			try setKeychainItem(key: KeychainKey.pinFailTime, item: nil as Int64?)
			try setKeychainItem(key: KeychainKey.pinFailCount, item: nil as Int64?)
			try setKeychainItem(key: KeychainKey.pin, item: nil as String?)
			try setKeychainItem(key: KeychainKey.masterPubKey, item: nil as Data?)
			try setKeychainItem(key: KeychainKey.seed, item: nil as Data?)
			try setKeychainItem(key: KeychainKey.mnemonic, item: nil as String?, authenticated: true)
			return true
		} catch {
			debugPrint(":::Wipe wallet error: \(error)")
			return false
		}
	}

	func deleteWalletDatabase(pin: String = "forceWipe") -> Bool {
		guard pin == "forceWipe" || authenticate(pin: pin) else { return false }

		do {
			lazyWallet = nil
			lazyPeerManager = nil
			if db != nil { sqlite3_close(db) }
			db = nil
			didInitWallet = false
			earliestKeyTime = 0
			try BWAPIClient(authenticator: self).kv?.rmdb()
			try? FileManager.default.removeItem(atPath: dbPath)
			try? FileManager.default.removeItem(at: BRReplicatedKVStore.dbPath)
			NotificationCenter.default.post(name: .didDeleteWalletDBNotification, object: nil)
			return true
		} catch {
			debugPrint(":::Wipe wallet error: \(error)")
			return false
		}
	}

	// key used for authenticated API calls
	var apiAuthKey: String? {
		return autoreleasepool {
			do {
				if let apiKey: String? = try? keychainItem(key: KeychainKey.apiAuthKey) {
					if apiKey != nil {
						return apiKey
					}
				}
				var key = BRKey()
				var seed = UInt512()
				guard let phrase: String = try keychainItem(key: KeychainKey.mnemonic) else { return nil }
				BRBIP39DeriveKey(&seed, phrase, nil)
				BRBIP32APIAuthKey(&key, &seed, MemoryLayout<UInt512>.size)
				seed = UInt512() // clear seed
				let pkLen = BRKeyPrivKey(&key, nil, 0)
				var pkData = CFDataCreateMutable(secureAllocator, pkLen) as Data
				pkData.count = pkLen
				guard pkData.withUnsafeMutableBytes({ BRKeyPrivKey(&key, $0, pkLen) }) == pkLen else { return nil }
				let privKey = CFStringCreateFromExternalRepresentation(secureAllocator, pkData as CFData,
				                                                       CFStringBuiltInEncodings.UTF8.rawValue) as String
				try setKeychainItem(key: KeychainKey.apiAuthKey, item: privKey)
				return privKey
			} catch {
				debugPrint(":::apiAuthKey error: \(error)")
				return nil
			}
		}
	}

	// sensitive user information stored on the keychain
	var userAccount: [AnyHashable: Any]? {
		get {
			do {
				return try keychainItem(key: KeychainKey.userAccount)
			} catch { return nil }
		}

		set(value) {
			do {
				try setKeychainItem(key: KeychainKey.userAccount, item: value)
			} catch {}
		}
	}

	private struct KeychainKey {
		public static let mnemonic = "mnemonic"
		public static let creationTime = "creationtime"
		public static let masterPubKey = "masterpubkey"
		public static let spendLimit = "spendlimit"
		public static let pin = "pin"
		public static let pinFailCount = "pinfailcount"
		public static let pinFailTime = "pinfailheight"
		public static let apiAuthKey = "authprivkey"
		public static let userAccount = "https://api.grunt.ltd"
		public static let seed = "seed" // deprecated
	}

	private struct DefaultsKey {
		public static let spendLimitAmount = "SPEND_LIMIT_AMOUNT"
		public static let pinUnlockTime = "PIN_UNLOCK_TIME"
	}

	private func signTx(_ tx: BRTxRef, forkId: Int = 0) -> Bool {
		return autoreleasepool {
			do {
				var seed = UInt512()
				defer { seed = UInt512() }
				guard let wallet = wallet
				else {
					return false
				}
				guard let phrase: String = try keychainItem(key: KeychainKey.mnemonic)
				else {
					return false
				}

				BRBIP39DeriveKey(&seed, phrase, nil)
				return wallet.signTransaction(tx, forkId: forkId, seed: &seed)
			} catch {
				return false
			}
		}
	}
}

private func keychainItem<T>(key: String) throws -> T? {
	let query = [kSecClass as String: kSecClassGenericPassword as String,
	             kSecAttrService as String: WalletSecAttrService,
	             kSecAttrAccount as String: key,
	             kSecReturnData as String: true as Any]
	var result: CFTypeRef?
	let status = SecItemCopyMatching(query as CFDictionary, &result)
	guard status == noErr || status == errSecItemNotFound
	else {
		throw NSError(domain: NSOSStatusErrorDomain, code: Int(status))
	}
	guard let data = result as? Data else { return nil }

	switch T.self {
	case is Data.Type:
		return data as? T
	case is String.Type:
		return CFStringCreateFromExternalRepresentation(secureAllocator, data as CFData,
		                                                CFStringBuiltInEncodings.UTF8.rawValue) as? T
	case is Int64.Type:
		guard data.count == MemoryLayout<T>.stride else { return nil }
		return data.withUnsafeBytes { $0.pointee }
	case is [AnyHashable: Any].Type:
		return NSKeyedUnarchiver.unarchiveObject(with: data) as? T
	default:
		throw NSError(domain: NSOSStatusErrorDomain, code: Int(errSecParam))
	}
}

private func setKeychainItem<T>(key: String, item: T?, authenticated: Bool = false) throws {
	let accessible = authenticated ? kSecAttrAccessibleWhenUnlockedThisDeviceOnly as String
		: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly as String
	let query = [kSecClass as String: kSecClassGenericPassword as String,
	             kSecAttrService as String: WalletSecAttrService,
	             kSecAttrAccount as String: key]
	var status = noErr
	var data: Data?
	if let item = item {
		switch T.self {
		case is Data.Type:
			data = item as? Data
		case is String.Type:
			data = CFStringCreateExternalRepresentation(secureAllocator, item as! CFString,
			                                            CFStringBuiltInEncodings.UTF8.rawValue, 0) as Data
		case is Int64.Type:
			data = CFDataCreateMutable(secureAllocator, MemoryLayout<T>.stride) as Data
			[item].withUnsafeBufferPointer { data?.append($0) }
		case is [AnyHashable: Any].Type:
			data = NSKeyedArchiver.archivedData(withRootObject: item)
		default:
			throw NSError(domain: NSOSStatusErrorDomain, code: Int(errSecParam))
		}
	}

	if data == nil { // delete item
		if SecItemCopyMatching(query as CFDictionary, nil) != errSecItemNotFound {
			status = SecItemDelete(query as CFDictionary)
		}
	} else if SecItemCopyMatching(query as CFDictionary, nil) != errSecItemNotFound { // update existing item
		let update = [kSecAttrAccessible as String: accessible,
		              kSecValueData as String: data as Any]
		status = SecItemUpdate(query as CFDictionary, update as CFDictionary)
	} else { // add new item
		let item = [kSecClass as String: kSecClassGenericPassword as String,
		            kSecAttrService as String: WalletSecAttrService,
		            kSecAttrAccount as String: key,
		            kSecAttrAccessible as String: accessible,
		            kSecValueData as String: data as Any]
		status = SecItemAdd(item as CFDictionary, nil)
	}

	guard status == noErr
	else {
		throw NSError(domain: NSOSStatusErrorDomain, code: Int(status))
	}
}
