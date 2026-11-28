import BRCore
@testable import brainwallet
import XCTest

final class ApiPeerTests: XCTestCase {
	func testParsesIPv4WithPort() {
		XCTAssertEqual(ApiPeer.parse(key: "86.107.187.54:9333", services: 1037),
		               ApiPeer(host: "86.107.187.54", port: 9333, services: 1037))
	}

	func testParsesBareHostAsStandardPort() {
		XCTAssertEqual(ApiPeer.parse(key: " 86.107.187.54 ", services: 5)?.port, 0)
	}

	func testParsesBracketedAndBareIPv6() {
		XCTAssertEqual(ApiPeer.parse(key: "[2001:db8::1]:9333", services: 5),
		               ApiPeer(host: "2001:db8::1", port: 9333, services: 5))
		XCTAssertEqual(ApiPeer.parse(key: "[2001:db8::1]", services: 5)?.port, 0)
		XCTAssertEqual(ApiPeer.parse(key: "2001:db8::1", services: 5),
		               ApiPeer(host: "2001:db8::1", port: 0, services: 5))
	}

	func testRejectsUnusableKeys() {
		for key in ["", "   ", ":9333", "[]:9333", "[::1", "[::1]9333", "1.2.3.4:70000", "1.2.3.4:-1",
		            "1.2.3.4:abc", "not-an-ip:9333", "999.1.1.1:9333", "seed.example.com"] {
			XCTAssertNil(ApiPeer.parse(key: key, services: 5), key)
		}
	}

	func testRejectsMissingFlags() {
		XCTAssertNil(ApiPeer.parse(key: "1.2.3.4:9333", services: nil))
	}

	func testIPv4BecomesTheMappedAddressCoreUses() throws {
		let peer = try XCTUnwrap(ApiPeer.parse(key: "1.2.3.4:9333", services: 5)?.brPeer)
		// same packing as WalletManager.loadPeers()
		let expected = UInt128(u32: (0, 0, UInt32(0xFFFF).bigEndian, UInt32(0x0102_0304).bigEndian))
		XCTAssertEqual(peer.address.u64.0, expected.u64.0)
		XCTAssertEqual(peer.address.u64.1, expected.u64.1)
		XCTAssertEqual(peer.port, 9333)
		XCTAssertEqual(peer.services, 5)
	}

	func testIPv6Address() throws {
		let peer = try XCTUnwrap(ApiPeer.parse(key: "[::1]:9333", services: 5)?.brPeer)
		XCTAssertEqual(peer.address.u64.0, 0)
		XCTAssertEqual(peer.address.u8.15, 1)
	}

	func testParsesNodesResponse() throws {
		let json = """
		{"count": 5, "lastUpdated": "2026-11-28T00:00:00Z", "nodes": {
		  "86.107.187.54:9333": {"version": "/LitecoinCore:0.21.4/", "country": "DE", "height": 3000000, "flags": 1037},
		  "31.7.59.196:9333": {"flags": 5},
		  "31.7.59.196:9333 ": {"flags": 5},
		  "1.1.1.1:9333": {"version": "x"},
		  "2.2.2.2:9333": {"flags": -1},
		  "bad key": {"flags": 5}
		}}
		"""
		let peers = try XCTUnwrap(ApiPeer.peers(fromNodesResponse: Data(json.utf8)))
		XCTAssertEqual(Set(peers), [ApiPeer(host: "86.107.187.54", port: 9333, services: 1037),
		                            ApiPeer(host: "31.7.59.196", port: 9333, services: 5)])
		XCTAssertEqual(peers.count, 2)
	}

	func testRejectsNonNodesBodies() {
		XCTAssertNil(ApiPeer.peers(fromNodesResponse: Data("not json".utf8)))
		XCTAssertNil(ApiPeer.peers(fromNodesResponse: Data("[]".utf8)))
		XCTAssertEqual(ApiPeer.peers(fromNodesResponse: Data("{}".utf8)), [])
	}
}

final class ApiPeersRepositoryTests: XCTestCase {
	private final class StubFetcher: LitecoinNodesFetching {
		var responses: [Data?] = []
		var calls = 0
		var delay: TimeInterval = 0
		func fetchNodes(timeout _: TimeInterval, completion: @escaping (Data?) -> Void) {
			calls += 1
			let data = responses.isEmpty ? nil : responses.removeFirst()
			DispatchQueue.global().asyncAfter(deadline: .now() + delay) { completion(data) }
		}
	}

	private var defaults: UserDefaults!
	private var suiteName: String!
	private var fetcher: StubFetcher!
	private var clock = Date(timeIntervalSince1970: 1_800_000_000)
	private var repository: ApiPeersRepository!

	private static func body(_ hosts: [String]) -> Data {
		let nodes = hosts.map { "\"\($0):9333\": {\"flags\": 1037}" }.joined(separator: ",")
		return Data("{\"count\": \(hosts.count), \"nodes\": {\(nodes)}}".utf8)
	}

	override func setUp() {
		suiteName = "ApiPeersRepositoryTests-\(UUID().uuidString)"
		defaults = UserDefaults(suiteName: suiteName)
		fetcher = StubFetcher()
		repository = ApiPeersRepository(defaults: defaults, fetcher: fetcher, now: { [unowned self] in self.clock })
	}

	override func tearDown() {
		defaults.removePersistentDomain(forName: suiteName)
	}

	func testFetchesAndCaches() {
		fetcher.responses = [Self.body(["1.2.3.4"])]
		XCTAssertEqual(repository.fetchPeers().map(\.host), ["1.2.3.4"])
		XCTAssertEqual(repository.cachedPeers().map(\.host), ["1.2.3.4"])
		XCTAssertNotNil(defaults.data(forKey: ApiPeersRepository.peersKey))
	}

	func testFreshCacheSkipsTheNetwork() {
		fetcher.responses = [Self.body(["1.2.3.4"])]
		_ = repository.fetchPeers()
		clock += ApiPeersRepository.cacheTTL - 1
		XCTAssertEqual(repository.fetchPeers().map(\.host), ["1.2.3.4"])
		XCTAssertEqual(fetcher.calls, 1)
	}

	func testStaleCacheIsRefreshed() {
		fetcher.responses = [Self.body(["1.2.3.4"]), Self.body(["5.6.7.8"])]
		_ = repository.fetchPeers()
		clock += ApiPeersRepository.cacheTTL
		XCTAssertEqual(repository.fetchPeers().map(\.host), ["5.6.7.8"])
		XCTAssertEqual(fetcher.calls, 2)
	}

	func testFailureFallsBackToStaleCache() {
		fetcher.responses = [Self.body(["1.2.3.4"]), nil]
		_ = repository.fetchPeers()
		clock += ApiPeersRepository.cacheTTL + 1
		XCTAssertEqual(repository.fetchPeers().map(\.host), ["1.2.3.4"])
	}

	func testEmptyResponseFallsBackToStaleCache() {
		fetcher.responses = [Self.body(["1.2.3.4"]), Self.body([])]
		_ = repository.fetchPeers()
		clock += ApiPeersRepository.cacheTTL + 1
		XCTAssertEqual(repository.fetchPeers().map(\.host), ["1.2.3.4"])
	}

	func testFailureWithNoCacheReturnsNoPeers() {
		fetcher.responses = [nil]
		XCTAssertEqual(repository.fetchPeers(), [])
	}

	func testFailureIsNotRetriedStraightAway() {
		fetcher.responses = [nil, Self.body(["1.2.3.4"])]
		_ = repository.fetchPeers()
		XCTAssertEqual(repository.fetchPeers(), [])
		XCTAssertEqual(fetcher.calls, 1)
		clock += ApiPeersRepository.retryDelay
		XCTAssertEqual(repository.fetchPeers().map(\.host), ["1.2.3.4"])
		XCTAssertEqual(fetcher.calls, 2)
	}

	func testClockGoingBackwardsRefetches() {
		fetcher.responses = [Self.body(["1.2.3.4"]), Self.body(["5.6.7.8"])]
		_ = repository.fetchPeers()
		clock -= 60
		XCTAssertEqual(repository.fetchPeers().map(\.host), ["5.6.7.8"])
	}

	func testUnreadableCacheIsIgnored() {
		defaults.set(Data("garbage".utf8), forKey: ApiPeersRepository.peersKey)
		defaults.set(clock.timeIntervalSince1970, forKey: ApiPeersRepository.cachedAtKey)
		fetcher.responses = [Self.body(["1.2.3.4"])]
		XCTAssertEqual(repository.fetchPeers().map(\.host), ["1.2.3.4"])
	}

	func testConcurrentCallersShareOneRequest() {
		fetcher.responses = [Self.body(["1.2.3.4"])]
		fetcher.delay = 0.2
		let group = DispatchGroup()
		let results = NSMutableArray()
		for _ in 0 ..< 4 {
			DispatchQueue.global().async(group: group) {
				let hosts = self.repository.fetchPeers().map(\.host)
				objc_sync_enter(results); results.add(hosts); objc_sync_exit(results)
			}
		}
		XCTAssertEqual(group.wait(timeout: .now() + 5), .success)
		XCTAssertEqual(fetcher.calls, 1)
		XCTAssertEqual(results.compactMap { $0 as? [String] }, Array(repeating: ["1.2.3.4"], count: 4))
	}
}
