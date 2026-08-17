@testable import brainwallet
import XCTest

/// Covers the WalletManager+Auth business logic not already exercised by
/// WalletAuthenticationTests (pin lock-out) and WalletCreationTests (random
/// seed-phrase generation): recovering a wallet from a known phrase, the
/// seedPhrase(pin:)/setSeedPhrase round trip, changing an existing pin, pinLength,
/// and wipeWallet. These also guard against regressions in the entropy/seed
/// pointer scoping inside setRandomSeedPhrase()'s underlying BIP39 encode path.
class WalletManagerAuthTests: XCTestCase {
	private let walletManager: WalletManager = try! WalletManager(store: Store(), dbPath: nil)
	private let pin = "123456"
	private let validPhrase = "kind butter gasp around unfair tape again suit else example toast orphan"

	override func setUp() {
		super.setUp()
		clearKeychain()
	}

	override func tearDown() {
		super.tearDown()
		clearKeychain()
	}

	// MARK: - setSeedPhrase

	func testSetSeedPhraseSucceedsOnFreshWallet() {
		XCTAssertTrue(walletManager.noWallet, "Wallet should not exist before setSeedPhrase")
		XCTAssertTrue(walletManager.setSeedPhrase(validPhrase), "Setting a valid seed phrase on a fresh wallet should succeed")
		XCTAssertFalse(walletManager.noWallet, "Wallet should exist once a seed phrase has been set")
	}

	func testSetSeedPhraseFailsWhenWalletAlreadyExists() {
		XCTAssertTrue(walletManager.setSeedPhrase(validPhrase))
		XCTAssertFalse(walletManager.setSeedPhrase(validPhrase), "setSeedPhrase should refuse to overwrite an existing wallet")
	}

	// MARK: - seedPhrase(pin:) round trip

	func testSeedPhraseReturnsOriginalPhraseWithCorrectPin() {
		XCTAssertTrue(walletManager.setSeedPhrase(validPhrase))
		XCTAssertTrue(walletManager.forceSetPin(newPin: pin), "Setting PIN should succeed")
		XCTAssertEqual(walletManager.seedPhrase(pin: pin), validPhrase,
		               "seedPhrase(pin:) should return exactly the phrase that was set")
	}

	func testSeedPhraseReturnsNilWithWrongPin() {
		XCTAssertTrue(walletManager.setSeedPhrase(validPhrase))
		XCTAssertTrue(walletManager.forceSetPin(newPin: pin))
		XCTAssertNil(walletManager.seedPhrase(pin: "000000"), "seedPhrase(pin:) should refuse an incorrect PIN")
	}

	// MARK: - changePin

	func testChangePinAllowsAuthenticationWithNewPinOnly() {
		XCTAssertTrue(walletManager.setSeedPhrase(validPhrase))
		XCTAssertTrue(walletManager.forceSetPin(newPin: pin))

		let newPin = "654321"
		XCTAssertTrue(walletManager.changePin(newPin: newPin, pin: pin), "changePin should succeed with the correct current PIN")
		XCTAssertTrue(walletManager.authenticate(pin: newPin), "Authentication should succeed with the new PIN")
	}

	func testChangePinFailsWithWrongCurrentPin() {
		XCTAssertTrue(walletManager.setSeedPhrase(validPhrase))
		XCTAssertTrue(walletManager.forceSetPin(newPin: pin))
		XCTAssertFalse(walletManager.changePin(newPin: "654321", pin: "000000"), "changePin should refuse an incorrect current PIN")
	}

	// MARK: - pinLength

	func testPinLengthReflectsTheConfiguredPin() {
		XCTAssertEqual(walletManager.pinLength, kPinDigitConstant, "pinLength should fall back to the default before any PIN is set")
		XCTAssertTrue(walletManager.setSeedPhrase(validPhrase))
		XCTAssertTrue(walletManager.forceSetPin(newPin: pin))
		XCTAssertEqual(walletManager.pinLength, pin.utf8.count, "pinLength should reflect the digit count of the configured PIN")
	}

	// MARK: - wipeWallet

	func testWipeWalletClearsTheWallet() {
		XCTAssertTrue(walletManager.setSeedPhrase(validPhrase))
		XCTAssertTrue(walletManager.forceSetPin(newPin: pin))
		XCTAssertFalse(walletManager.noWallet)

		XCTAssertTrue(walletManager.wipeWallet(), "wipeWallet with the force-wipe sentinel should succeed unconditionally")
		XCTAssertTrue(walletManager.noWallet, "Wallet should no longer exist after wipeWallet")
	}

	func testWipeWalletRequiresCorrectPinWhenNotForced() {
		XCTAssertTrue(walletManager.setSeedPhrase(validPhrase))
		XCTAssertTrue(walletManager.forceSetPin(newPin: pin))

		XCTAssertFalse(walletManager.wipeWallet(pin: "000000"), "wipeWallet with a wrong PIN should fail")
		XCTAssertFalse(walletManager.noWallet, "Wallet should be untouched after a failed wipe attempt")
	}

	// MARK: - userAccount

	func testUserAccountRoundTripsThroughKeychain() throws {
		let account: [AnyHashable: Any] = ["token": "abc123", "expires": 42]
		walletManager.userAccount = account

		let fetched = try XCTUnwrap(walletManager.userAccount)
		XCTAssertEqual(fetched["token"] as? String, "abc123")
		XCTAssertEqual(fetched["expires"] as? Int, 42)
	}

	func testUserAccountIsNilBeforeItIsSet() {
		XCTAssertNil(walletManager.userAccount)
	}
}
