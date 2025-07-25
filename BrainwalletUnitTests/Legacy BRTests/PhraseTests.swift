@testable import brainwallet
import XCTest

class PhraseTests: XCTestCase {
	private let walletManager: WalletManager = try! WalletManager(store: Store(), dbPath: nil)

	func testEmptyPhrase() {
		XCTAssertFalse(walletManager.isPhraseValid(""), "Empty phrase should not be valid")
	}

	func testInvalidPhrase() {
		XCTAssertFalse(walletManager.isPhraseValid("This is totally and absolutely an invalid bip 39 bread recovery phrase"), "Invalid phrase should not be valid")
	}

	func testValidPhrase() {
		XCTAssertTrue(walletManager.isPhraseValid("kind butter gasp around unfair tape again suit else example toast orphan"), "Valid phrase should be valid.")
	}

	func testValidWord() {
		XCTAssertTrue(walletManager.isWordValid("kind"), "Valid word should be valid.")
	}

	func testInValidWord() {
		XCTAssertFalse(walletManager.isWordValid("blasdf;ljk"), "Invalid word should not be valid.")
	}

	func testEmptyWord() {
		XCTAssertFalse(walletManager.isWordValid(""), "Empty string should not be valid")
	}
}
