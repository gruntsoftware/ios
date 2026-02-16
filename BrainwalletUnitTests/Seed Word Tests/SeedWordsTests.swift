@testable import brainwallet
import XCTest

final class SeedWordsTests: XCTestCase {
	let mockSeeds = MockSeeds()
	let mockData = MockData()
    
	override func setUpWithError() throws {
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}

	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}

    func testSeedPhraseLength() throws {
        XCTAssertEqual(MockSeeds.twelveWords.count, 12)
        XCTAssertEqual(MockSeeds.twelveWords.count, kSeedPhraseLength)
	}
}
