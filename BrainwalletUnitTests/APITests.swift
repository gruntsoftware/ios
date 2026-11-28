@testable import brainwallet
import XCTest

class APITests: XCTestCase {
	var apiServer: APIServer!
	var apiClient: BWAPIClient!

	override func setUpWithError() throws {
		apiServer = APIServer()
		apiClient = brainwallet.BWAPIClient(authenticator: NoAuthAuthenticator())
	}

	override func tearDownWithError() throws {
		apiServer = nil
	}

	func testfetchExchangeRates() throws {
		apiClient.exchangeRates { rates, _ in
			for rate in rates {
				if rate.code == "AFN" {
					XCTAssertEqual(rate.name, "Afghan Afghani")
				}
				if rate.code == "GBP" {
					XCTAssertEqual(rate.name, "British Pound Sterling")
				}
				if rate.code == "EUR" {
					XCTAssertEqual(rate.name, "Euro")
				}
				if rate.code == "USD" {
					XCTAssertEqual(rate.name, "US Dollar")
				}
			}
		}
	}

	func testLitecoinNodesReturnsUsablePeers() throws {
		let done = expectation(description: "nodes api")
		var peers: [ApiPeer]?
		URLSessionLitecoinNodesFetcher().fetchNodes(timeout: ApiPeersRepository.fetchTimeout) { data in
			peers = data.flatMap(ApiPeer.peers(fromNodesResponse:))
			done.fulfill()
		}
		wait(for: [done], timeout: ApiPeersRepository.fetchTimeout + 2)
		let result = try XCTUnwrap(peers)
		XCTAssertFalse(result.isEmpty)
		XCTAssertTrue(result.allSatisfy { $0.brPeer != nil })
	}

	func testfeePerKb() throws {
		apiClient.feePerKb { fees, _ in
			XCTAssertGreaterThan(fees.economy, 0)
			XCTAssertGreaterThan(fees.regular, 0)
			XCTAssertGreaterThan(fees.luxury, 0)
		}
	}
}

