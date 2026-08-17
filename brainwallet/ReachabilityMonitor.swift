import Foundation
import Network

/// Watches network reachability using the Network framework's path monitor —
/// replaces the deprecated SystemConfiguration SCNetworkReachability APIs.
class ReachabilityMonitor {
	init() {
		monitor.pathUpdateHandler = { [weak self] path in
			DispatchQueue.main.async {
				self?.didChange?(path.status == .satisfied)
			}
		}
		monitor.start(queue: reachabilitySerialQueue)
	}

	deinit {
		monitor.cancel()
	}

	var didChange: ((Bool) -> Void)?

	private let monitor = NWPathMonitor()
	private let reachabilitySerialQueue = DispatchQueue(label: "co.brainwallet.reachabilityQueue")

	var isReachable: Bool {
		monitor.currentPath.status == .satisfied
	}
}
