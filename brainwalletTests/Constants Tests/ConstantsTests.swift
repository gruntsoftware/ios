@testable import brainwallet
import XCTest

class ConstantsTests: XCTestCase {
	func testLFDonationAddressPage() throws {
		XCTAssertTrue(FoundationSupport.dashboard == "https://support.brainwallet.io/")
	}
}
