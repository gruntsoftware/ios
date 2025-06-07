@testable import brainwallet
import XCTest

class LockScreenTests: XCTestCase {
	func testLockScreenView() throws {
		let viewModel = LockScreenViewModel(store: Store())

		XCTAssertNotNil(viewModel.currencyCode)
	}
}
