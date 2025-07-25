@testable import brainwallet
import XCTest

class UserPreferredCurrencyTests: XCTestCase {
	let userPreferredCurrency = Locale(identifier: "en_US")

	override func setUp() {
		UserDefaults.standard.removeObject(forKey: "defaultcurrency")
	}

	func testUpdateEUR() {
		UserDefaults.userPreferredCurrencyCode = "EUR"
		XCTAssertTrue(UserDefaults.userPreferredCurrencyCode == "EUR", "Default currency should update.")
	}

	func testUpdateJPY() {
		UserDefaults.userPreferredCurrencyCode = "JPY"
		XCTAssertTrue(UserDefaults.userPreferredCurrencyCode == "JPY", "Default currency should update.")
	}

	func testAction() {
		UserDefaults.userPreferredCurrencyCode = "USD"
		let store = Store()
		store.perform(action: UserPreferredCurrency.setDefault("CAD"))
		XCTAssertTrue(UserDefaults.userPreferredCurrencyCode == "CAD", "Actions should persist new value")
	}
}
