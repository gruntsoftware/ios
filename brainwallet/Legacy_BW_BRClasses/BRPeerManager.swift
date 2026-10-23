import BRCore
import Foundation


enum PeerSyncMode: String {
    case random_mainnet
    case trusted
}

class BRPeerManager {
	let cPointer: OpaquePointer
	let listener: BRPeerManagerListener
	let mainNetParams = [BRMainNetParams]
	var falsePositiveRate: Double
    var syncMode: PeerSyncMode = .random_mainnet

	init?(wallet: BRWallet,
	      earliestKeyTime: TimeInterval,
	      blocks: [BRBlockRef?], peers: [BRPeer],
	      listener: BRPeerManagerListener,
	      fpRate: Double) {
		var blockRefs = blocks
        guard let cPointer = BRPeerManagerNew(mainNetParams, wallet.cPointer, UInt32(earliestKeyTime + NSTimeIntervalSince1970),
		                                  &blockRefs, blockRefs.count, peers, peers.count, fpRate) else { return nil }
		self.listener = listener
		self.cPointer = cPointer
		falsePositiveRate = fpRate

		BRPeerManagerSetCallbacks(cPointer, Unmanaged.passUnretained(self).toOpaque(),
		                          { info in // syncStarted
		                          	guard let info = info else { return }
		                          	Unmanaged<BRPeerManager>.fromOpaque(info).takeUnretainedValue().listener.syncStarted()
		                          },
		                          { info, error in // syncStopped
		                          	guard let info = info else { return }
		                          	let err = BRPeerManagerError.posixError(errorCode: error, description: String(cString: strerror(error)))
		                          	Unmanaged<BRPeerManager>.fromOpaque(info).takeUnretainedValue().listener.syncStopped(error != 0 ? err : nil)
		                          },
		                          { info in // txStatusUpdate
		                          	guard let info = info else { return }
		                          	Unmanaged<BRPeerManager>.fromOpaque(info).takeUnretainedValue().listener.txStatusUpdate()
		                          },
		                          { info, replace, blocks, blocksCount in // saveBlocks
		                          	guard let info = info else { return }
		                          	let blockRefs = [BRBlockRef?](UnsafeBufferPointer(start: blocks, count: blocksCount))
		                          	Unmanaged<BRPeerManager>.fromOpaque(info).takeUnretainedValue().listener.saveBlocks(replace != 0, blockRefs)
		                          },
		                          { info, replace, peers, peersCount in // savePeers
		                          	guard let info = info else { return }
		                          	let peerList = [BRPeer](UnsafeBufferPointer(start: peers, count: peersCount))
		                          	Unmanaged<BRPeerManager>.fromOpaque(info).takeUnretainedValue().listener.savePeers(replace != 0, peerList)
		                          },
		                          { info -> Int32 in // networkIsReachable
		                          	guard let info = info else { return 0 }
		                          	return Unmanaged<BRPeerManager>.fromOpaque(info).takeUnretainedValue().listener.networkIsReachable() ? 1 : 0
		                          },
		                          nil) // threadCleanup

		// called by core when it detects and recovers from unexpected internal state (e.g. a missing
		// checkpoint block) instead of crashing. warning is a short, static, human-readable string with
		// no dynamic/sensitive content. See BRPeerManagerSetIntegrityWarningCallback() in BRPeerManager.h.
		BRPeerManagerSetIntegrityWarningCallback(cPointer) { info, warning in
			guard let info = info, let warning = warning else { return }
			Unmanaged<BRPeerManager>.fromOpaque(info).takeUnretainedValue().listener.integrityWarning(String(cString: warning))
		}
	}

	// true if currently connected to at least one peer
	var isConnected: Bool {
		return BRPeerManagerConnectStatus(cPointer) == BRPeerStatusConnected
	}

	// connect to litecoin peer-to-peer network (also call this whenever networkIsReachable() status changes)
	func connect() {
		applyTrustedNodePreference()
		BRPeerManagerConnect(cPointer)
	}

	private func applyTrustedNodePreference() {
		guard UserDefaults.userPrefersUsingTrustedNode,
		      let ipAddress = UserDefaults.userTrustedNodeIpAddress,
		      let packedAddress = BRPeerManager.packedIPv4Address(ipAddress)
		else {
			setFixedPeer(address: 0, port: 0)
            syncMode = .random_mainnet
			return
		}
        syncMode = .trusted
		let port = UserDefaults.userTrustedNodePort.flatMap(Int.init) ?? C.standardPort
		setFixedPeer(address: packedAddress, port: port)
	}

	// packs a dotted-quad IPv4 string into the network-byte-order integer setFixedPeer expects
	private static func packedIPv4Address(_ ipAddress: String) -> Int? {
		var addr = in_addr()
		guard inet_pton(AF_INET, ipAddress, &addr) == 1 else { return nil }
		return Int(addr.s_addr)
	}

	// disconnect from litecoin peer-to-peer network
	func disconnect() {
		BRPeerManagerDisconnect(cPointer)
	}

	// rescans blocks and transactions after earliestKeyTime (a new random download peer is also selected due to the
	// possibility that a malicious node might lie by omitting transactions that match the bloom filter)
	func rescan() {
		BRPeerManagerRescan(cPointer)
	}

	// current proof-of-work verified best block height
	var lastBlockHeight: UInt32 {
		return BRPeerManagerLastBlockHeight(cPointer)
	}

	// current proof-of-work verified best block timestamp (time interval since unix epoch)
	var lastBlockTimestamp: UInt32 {
		return BRPeerManagerLastBlockTimestamp(cPointer)
	}

	// the (unverified) best block height reported by connected peers
	var estimatedBlockHeight: UInt32 {
		return BRPeerManagerEstimatedBlockHeight(cPointer)
	}

	// current network sync progress from 0 to 1
	// startHeight is the block height of the most recent fully completed sync
	func syncProgress(fromStartHeight: UInt32) -> Double {
		return BRPeerManagerSyncProgress(cPointer, fromStartHeight)
	}

	// the number of currently connected peers
	var peerCount: Int {
		return BRPeerManagerPeerCount(cPointer)
	}

	// description of the peer most recently used to sync blockchain data
	var downloadPeerName: String {
		return String(cString: BRPeerManagerDownloadPeerName(cPointer))
	}

	// publishes tx to litecoin network
	func publishTx(_ tx: BRTxRef, completion: @escaping (Bool, BRPeerManagerError?) -> Void) {
		BRPeerManagerPublishTx(cPointer, tx, Unmanaged.passRetained(CompletionWrapper(completion)).toOpaque()) { info, error in
			guard let info = info else { return }
			guard error == 0
			else {
				let err = BRPeerManagerError.posixError(errorCode: error, description: String(cString: strerror(error)))
				return Unmanaged<CompletionWrapper>.fromOpaque(info).takeRetainedValue().completion(false, err)
			}

			Unmanaged<CompletionWrapper>.fromOpaque(info).takeRetainedValue().completion(true, nil)
		}
	}

	// number of connected peers that have relayed the given unconfirmed transaction
	func relayCount(_ forTxHash: UInt256) -> Int {
		return BRPeerManagerRelayCount(cPointer, forTxHash)
	}

	func setFixedPeer(address: Int, port: Int) {
		if address != 0 {
			var newAddress = UInt128()
			newAddress.u16.5 = 0xFFFF
			newAddress.u32.3 = UInt32(address)
			BRPeerManagerSetFixedPeer(cPointer, newAddress, UInt16(port))
		} else {
			BRPeerManagerSetFixedPeer(cPointer, UInt128(), 0)
		}
	}

	deinit {
		BRPeerManagerDisconnect(cPointer)
		BRPeerManagerFree(cPointer)
	}

	private class CompletionWrapper {
		let completion: (Bool, BRPeerManagerError?) -> Void

		init(_ completion: @escaping (Bool, BRPeerManagerError?) -> Void) {
			self.completion = completion
		}
	}

	// hack to keep the swift compiler happy
	let a = BRMainNetDNSSeeds
	let b = BRMainNetCheckpoints
	let c = BRMainNetVerifyDifficulty
}
