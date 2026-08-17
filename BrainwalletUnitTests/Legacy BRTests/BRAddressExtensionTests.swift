import BRCore
@testable import brainwallet
import XCTest

/// Exercises BRAddress's Swift-side pointer interop (init from string/scriptPubKey,
/// the scriptPubKey/hash160/description accessors, and Equatable/Hashable) with
/// self-contained, deterministic fixtures. These don't depend on wallet setup or the
/// keychain, so they pin down exact byte-for-byte round-tripping behavior and guard
/// against regressions in the unsafe-pointer scoping those accessors rely on.
class BRAddressExtensionTests: XCTestCase {
	/// A syntactically valid P2PKH scriptPubKey: OP_DUP OP_HASH160 <20-byte hash> OP_EQUALVERIFY OP_CHECKSIG.
	private func p2pkhScript(hash160: [UInt8]) -> [UInt8] {
		precondition(hash160.count == 20)
		return [0x76, 0xa9, 0x14] + hash160 + [0x88, 0xac]
	}

	private let sampleHash160: [UInt8] = (0..<20).map { UInt8($0) }

	// MARK: - init?(scriptPubKey:) / scriptPubKey round trip

	func testInitFromScriptPubKeyRoundTripsExactBytes() throws {
		let script = p2pkhScript(hash160: sampleHash160)
		let address = try XCTUnwrap(BRAddress(scriptPubKey: script))
		XCTAssertEqual(address.scriptPubKey, script,
		               "scriptPubKey getter should reproduce the exact bytes the address was built from")
	}

	func testInitFromScriptPubKeyGarbageReturnsNil() {
		XCTAssertNil(BRAddress(scriptPubKey: [0xFF, 0xFF, 0xFF]),
		             "A malformed scriptPubKey should fail to produce an address")
	}

	// MARK: - hash160

	func testHash160MatchesTheHashTheScriptWasBuiltFrom() throws {
		let script = p2pkhScript(hash160: sampleHash160)
		let address = try XCTUnwrap(BRAddress(scriptPubKey: script))
		let hash = try XCTUnwrap(address.hash160)
		let hashBytes = withUnsafeBytes(of: hash) { Array($0) }
		XCTAssertEqual(hashBytes, sampleHash160,
		               "hash160 should be the same 20 bytes encoded in the source scriptPubKey")
	}

	func testHash160IsConsistentAcrossRepeatedCalls() throws {
		let script = p2pkhScript(hash160: sampleHash160)
		let address = try XCTUnwrap(BRAddress(scriptPubKey: script))
		let first = try XCTUnwrap(address.hash160)
		let second = try XCTUnwrap(address.hash160)
		let firstBytes = withUnsafeBytes(of: first) { Array($0) }
		let secondBytes = withUnsafeBytes(of: second) { Array($0) }
		XCTAssertEqual(firstBytes, secondBytes, "hash160 must be deterministic across repeated reads of the same address")
	}

	// MARK: - init?(string:) / description round trip

	func testInitFromStringRoundTripsThroughDescription() throws {
		let script = p2pkhScript(hash160: sampleHash160)
		let original = try XCTUnwrap(BRAddress(scriptPubKey: script))
		let addressString = original.description
		XCTAssertFalse(addressString.isEmpty)

		let rebuilt = try XCTUnwrap(BRAddress(string: addressString))
		XCTAssertEqual(rebuilt.description, addressString,
		               "description should reproduce the exact string the address was built from")
		XCTAssertEqual(rebuilt.scriptPubKey, script,
		               "an address rebuilt from its own string should still resolve to the same scriptPubKey")
	}

	func testInitFromEmptyStringSucceedsWithEmptyDescription() throws {
		let address = try XCTUnwrap(BRAddress(string: ""))
		XCTAssertEqual(address.description, "")
	}

	func testInitFromOversizedStringReturnsNil() {
		let oversized = String(repeating: "1", count: MemoryLayout<BRAddress>.size + 1)
		XCTAssertNil(BRAddress(string: oversized),
		             "A string longer than the fixed BRAddress buffer must fail to init")
	}

	// MARK: - Equatable / Hashable

	func testAddressesFromSameBytesAreEqualAndHashConsistently() throws {
		let script = p2pkhScript(hash160: sampleHash160)
		let a = try XCTUnwrap(BRAddress(scriptPubKey: script))
		let b = try XCTUnwrap(BRAddress(scriptPubKey: script))
		XCTAssertEqual(a, b)
		XCTAssertEqual(a.hashValue, b.hashValue)
	}

	func testAddressesFromDifferentBytesAreNotEqual() throws {
		let scriptA = p2pkhScript(hash160: sampleHash160)
		let scriptB = p2pkhScript(hash160: sampleHash160.reversed())
		let a = try XCTUnwrap(BRAddress(scriptPubKey: scriptA))
		let b = try XCTUnwrap(BRAddress(scriptPubKey: scriptB))
		XCTAssertNotEqual(a, b)
	}
}
