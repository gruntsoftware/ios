import BRCore
import Foundation

/// A peer from the nodes API (`GET v1/litecoin/nodes`), handed to core's `BRPeerManagerSetApiPeers`.
struct ApiPeer: Codable, Hashable {
	/// IPv4 or IPv6 literal, without brackets
	let host: String
	/// 0 means core's standard port
	let port: UInt16
	/// the node's advertised service flags (`flags` in the API response)
	let services: UInt64

	/// Parses a nodes API key: `host:port`, `[ipv6]:port`, or a bare host. nil if unusable.
	static func parse(key: String, services: UInt64?) -> ApiPeer? {
		guard let services = services else { return nil }
		let trimmed = key.trimmingCharacters(in: .whitespacesAndNewlines)
		guard !trimmed.isEmpty else { return nil }

		let host: String
		let portPart: String?
		if trimmed.hasPrefix("[") {
			guard let end = trimmed.firstIndex(of: "]") else { return nil }
			host = String(trimmed[trimmed.index(after: trimmed.startIndex) ..< end])
			let rest = trimmed[trimmed.index(after: end)...]
			if rest.isEmpty {
				portPart = nil
			} else if rest.hasPrefix(":") {
				portPart = String(rest.dropFirst())
			} else {
				return nil
			}
		} else if trimmed.filter({ $0 == ":" }).count > 1 {
			// a bare IPv6 literal has several colons and no port
			host = trimmed
			portPart = nil
		} else if let colon = trimmed.firstIndex(of: ":") {
			host = String(trimmed[..<colon])
			portPart = String(trimmed[trimmed.index(after: colon)...])
		} else {
			host = trimmed
			portPart = nil
		}

		guard !host.isEmpty else { return nil }
		var port: UInt16 = 0
		if let portPart = portPart {
			guard let parsed = UInt16(portPart) else { return nil }
			port = parsed
		}
		let peer = ApiPeer(host: host, port: port, services: services)
		return peer.address == nil ? nil : peer
	}

	/// Peers in a nodes API response body, or nil if the body isn't a nodes response.
	static func peers(fromNodesResponse data: Data) -> [ApiPeer]? {
		guard let response = try? JSONDecoder().decode(LitecoinNodesResponse.self, from: data) else { return nil }
		var seen = Set<ApiPeer>()
		return response.nodes
			.sorted { $0.key < $1.key }
			.compactMap { parse(key: $0.key, services: $0.value.flags) }
			.filter { seen.insert($0).inserted }
	}

	/// The host as the IPv6 (or IPv4-mapped) address core uses, nil if it isn't an IP literal.
	var address: UInt128? {
		var bytes = [UInt8](repeating: 0, count: 16)
		var v4 = in_addr()
		var v6 = in6_addr()
		if inet_pton(AF_INET, host, &v4) == 1 {
			bytes[10] = 0xFF
			bytes[11] = 0xFF
			withUnsafeBytes(of: &v4) { bytes.replaceSubrange(12 ..< 16, with: $0) }
		} else if inet_pton(AF_INET6, host, &v6) == 1 {
			withUnsafeBytes(of: &v6) { bytes = Array($0) }
		} else {
			return nil
		}
		var result = UInt128()
		withUnsafeMutableBytes(of: &result) { $0.copyBytes(from: bytes) }
		return result
	}

	var brPeer: BRPeer? {
		guard let address = address else { return nil }
		var peer = BRPeer()
		peer.address = address
		peer.port = port
		peer.services = services
		return peer
	}
}

/// Response of `GET v1/litecoin/nodes`, keyed by `"host:port"` (IPv6 hosts in brackets).
struct LitecoinNodesResponse: Decodable {
	struct Node: Decodable {
		let version: String?
		let country: String?
		let height: Int64?
		let flags: UInt64?
	}

	let count: Int?
	let lastUpdated: String?
	let nodes: [String: Node]

	private enum CodingKeys: String, CodingKey { case count, lastUpdated, nodes }

	init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		count = try? container.decodeIfPresent(Int.self, forKey: .count)
		lastUpdated = try? container.decodeIfPresent(String.self, forKey: .lastUpdated)
		// one malformed node shouldn't drop the rest
		let raw = try container.decodeIfPresent([String: FailableNode].self, forKey: .nodes) ?? [:]
		nodes = raw.compactMapValues(\.node)
	}

	private struct FailableNode: Decodable {
		let node: Node?
		init(from decoder: Decoder) throws { node = try? Node(from: decoder) }
	}
}

/// Fetches the raw nodes API body. Calls back with nil on any network or HTTP error.
protocol LitecoinNodesFetching {
	func fetchNodes(timeout: TimeInterval, completion: @escaping (Data?) -> Void)
}

struct URLSessionLitecoinNodesFetcher: LitecoinNodesFetching {
	func fetchNodes(timeout: TimeInterval, completion: @escaping (Data?) -> Void) {
		guard let url = URL(string: APIServer.baseUrl + "v1/litecoin/nodes") else { return completion(nil) }
		var request = URLRequest(url: url)
		#if targetEnvironment(simulator)
			request.assumesHTTP3Capable = false
		#endif
		request.timeoutInterval = timeout
		request.allHTTPHeaderFields = ["accept": "application/json"]
		URLSession(configuration: .ephemeral).dataTask(with: request) { data, response, error in
			guard error == nil,
			      let status = (response as? HTTPURLResponse)?.statusCode, (200 ..< 300).contains(status)
			else { return completion(nil) }
			completion(data)
		}.resume()
	}
}

/// Current peers from the nodes API, cached for 6 hours. Falls back to the stale cache, then to no peers
/// (core then uses its hardcoded peers). Concurrent callers share one request.
final class ApiPeersRepository {
	static let shared = ApiPeersRepository()

	static let cacheTTL: TimeInterval = 6 * 60 * 60
	static let fetchTimeout: TimeInterval = 8
	/// after a failed request, don't try again for this long (the API's own max-age), so repeated
	/// connect() calls while it's down don't each wait for the timeout
	static let retryDelay: TimeInterval = 5 * 60

	static let peersKey = "api_peers"
	static let cachedAtKey = "api_peers_cached_at"

	private let defaults: UserDefaults
	private let fetcher: LitecoinNodesFetching
	private let now: () -> Date
	private let lock = NSLock()
	private var lastFailure: Date?

	init(defaults: UserDefaults = .standard,
	     fetcher: LitecoinNodesFetching = URLSessionLitecoinNodesFetcher(),
	     now: @escaping () -> Date = Date.init) {
		self.defaults = defaults
		self.fetcher = fetcher
		self.now = now
	}

	/// Blocks for up to `fetchTimeout` when the cache is stale. Don't call on the main thread.
	func fetchPeers() -> [ApiPeer] {
		lock.lock()
		defer { lock.unlock() }

		let cached = readCache()
		if !cached.isEmpty, let cachedAt = defaults.object(forKey: Self.cachedAtKey) as? Double {
			let age = now().timeIntervalSince1970 - cachedAt
			if age >= 0, age < Self.cacheTTL { return cached }
		}
		if let lastFailure = lastFailure, now().timeIntervalSince(lastFailure) < Self.retryDelay {
			return cached
		}

		let fetched = fetchBlocking()
		guard let fetched = fetched, !fetched.isEmpty else {
			lastFailure = now()
			debugPrint("::: ApiPeersRepository: no fresh peers, using \(cached.count) cached")
			return cached
		}

		lastFailure = nil
		if let data = try? JSONEncoder().encode(fetched) {
			defaults.set(data, forKey: Self.peersKey)
			defaults.set(now().timeIntervalSince1970, forKey: Self.cachedAtKey)
		}
		debugPrint("::: ApiPeersRepository: \(fetched.count) peers from the nodes api")
		return fetched
	}

	/// Whatever is cached, without touching the network.
	func cachedPeers() -> [ApiPeer] {
		lock.lock()
		defer { lock.unlock() }
		return readCache()
	}

	private func fetchBlocking() -> [ApiPeer]? {
		let semaphore = DispatchSemaphore(value: 0)
		let box = ResultBox()
		fetcher.fetchNodes(timeout: Self.fetchTimeout) { data in
			box.set(data.flatMap(ApiPeer.peers(fromNodesResponse:)))
			semaphore.signal()
		}
		guard semaphore.wait(timeout: .now() + Self.fetchTimeout) == .success else { return nil }
		return box.get()
	}

	private func readCache() -> [ApiPeer] {
		guard let data = defaults.data(forKey: Self.peersKey) else { return [] }
		return (try? JSONDecoder().decode([ApiPeer].self, from: data)) ?? []
	}

	private final class ResultBox {
		private let lock = NSLock()
		private var value: [ApiPeer]?
		func set(_ newValue: [ApiPeer]?) { lock.lock(); value = newValue; lock.unlock() }
		func get() -> [ApiPeer]? { lock.lock(); defer { lock.unlock() }; return value }
	}
}
