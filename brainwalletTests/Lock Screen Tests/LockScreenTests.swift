@testable import brainwallet
import XCTest

class LockScreenTests: XCTestCase {
    @MainActor func testLockScreenView() throws {
		let viewModel = LockScreenViewModel(store: Store())
		XCTAssertNotNil(viewModel.currencyCode)
	}
}
