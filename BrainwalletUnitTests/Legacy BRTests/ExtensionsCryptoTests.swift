import BRCore
@testable import brainwallet
import XCTest

/// Verifies the hashing/encoding helpers in Extensions.swift against known
/// test vectors and round-trip self-consistency. There was no coverage of
/// these at all before -- added alongside migrating them off the deprecated
/// typed-pointer withUnsafeBytes/withUnsafeMutableBytes overloads to
/// UnsafeRawBufferPointer/UnsafeMutableRawBufferPointer, so a mistake in the
/// pointer plumbing shows up as a wrong hash rather than just a warning.
class ExtensionsCryptoTests: XCTestCase {
	func testMD5KnownVector() {
		XCTAssertEqual("abc".md5(), "900150983cd24fb0d6963f7d28e17f72")
	}

	func testSHA256KnownVector() {
		let data = "abc".data(using: .utf8)!
		XCTAssertEqual(data.sha256.hexString, "ba7816bf8f01cfea414140de5dae2223b00361a396177a9cb410ff61f20015ad")
	}

	func testSHA1ProducesTwentyBytes() {
		let data = "abc".data(using: .utf8)!
		XCTAssertEqual(data.sha1.count, 20)
	}

	func testBase58RoundTrip() {
		let data = "abc".data(using: .utf8)!
		let encoded = data.base58
		XCTAssertFalse(encoded.isEmpty)
		XCTAssertEqual(encoded.base58DecodedData(), data,
		               "decoding a base58 string should reproduce the original bytes")
	}

	func testUInt256RoundTrip() {
		let bytes = (0..<32).map { UInt8($0) }
		let data = Data(bytes)
		let value = data.uInt256
		let reEncoded = withUnsafeBytes(of: value) { Data($0) }
		XCTAssertEqual(reEncoded, data, "uInt256 should reinterpret the exact 32 bytes it was read from")
	}

	func testOffsetAccessorsReadLittleEndian() {
		// 0x0102030405060708 stored little-endian, followed by one more byte.
		let data = Data([0x08, 0x07, 0x06, 0x05, 0x04, 0x03, 0x02, 0x01, 0xFF])
		XCTAssertEqual(data.uInt8(atOffset: 8), 0xFF)
		XCTAssertEqual(data.uInt32(atOffset: 0), 0x0506_0708)
		XCTAssertEqual(data.uInt64(atOffset: 0), 0x0102_0304_0506_0708)
	}

	func testOffsetAccessorsReturnZeroPastTheEnd() {
		let data = Data([0x01, 0x02])
		XCTAssertEqual(data.uInt32(atOffset: 0), 0)
		XCTAssertEqual(data.uInt64(atOffset: 0), 0)
	}

	// MARK: - BRMasterPubKey Data round trip

	func testMasterPubKeyRoundTripsThroughData() throws {
		var mpk = BRMasterPubKey()
		mpk.fingerPrint = 0xDEAD_BEEF
		let chainCodeBytes = Data((0..<32).map { UInt8($0) + 1 })
		mpk.chainCode = chainCodeBytes.withUnsafeBytes { $0.load(as: UInt256.self) }

		let encoded = Data(masterPubKey: mpk)
		XCTAssertEqual(encoded.count, 4 + 32 + 33)

		let decoded = try XCTUnwrap(encoded.masterPubKey)
		XCTAssertEqual(decoded.fingerPrint, mpk.fingerPrint)
		let originalChainCode = withUnsafeBytes(of: mpk.chainCode) { Data($0) }
		let decodedChainCode = withUnsafeBytes(of: decoded.chainCode) { Data($0) }
		XCTAssertEqual(decodedChainCode, originalChainCode)
		let originalPubKey = withUnsafeBytes(of: mpk.pubKey) { Data($0) }
		let decodedPubKey = withUnsafeBytes(of: decoded.pubKey) { Data($0) }
		XCTAssertEqual(decodedPubKey, originalPubKey)
	}

	func testMasterPubKeyReturnsNilForShortData() {
		XCTAssertNil(Data(count: 10).masterPubKey)
	}
}
