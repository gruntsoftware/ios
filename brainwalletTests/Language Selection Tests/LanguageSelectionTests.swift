@testable import brainwallet
import XCTest

final class LanguageSelectionTests: XCTestCase {
	var viewModel: LanguageSelectionViewModel!

	override func setUpWithError() throws {
		// Put setup code here.
		// This method is called before the invocation of each test method in the class.

		viewModel = LanguageSelectionViewModel()
		viewModel.setLanguage(code: "en")
	}

	override func tearDownWithError() throws {
		// Put teardown code here.
		// This method is called after the invocation of each test method in the class.
		viewModel.setLanguage(code: "en")
	}

	func testIfLanguagesExist() throws {
		XCTAssert(!viewModel.localizations.isEmpty)
	}

	func testLanguageChange() throws {
        let initialLanguage = UserDefaults.selectedLanguage
		XCTAssertEqual(initialLanguage, "en")
		XCTAssertEqual(S.BrainwalletAlert.warning.localize(), "Warning")  
	}
}
