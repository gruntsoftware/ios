//
//  BRAddressExtension.swift
//  Created by Kerry Washington on 11/4/23.
//
import BRCore
import Foundation

extension BRAddress: @retroactive Equatable {}
extension BRAddress: @retroactive CustomStringConvertible, @retroactive Hashable {
	init?(string: String) {
		self.init()
		let cStr = [CChar](string.utf8CString)
		guard cStr.count <= MemoryLayout<BRAddress>.size else { return nil }
        withUnsafeMutableBytes(of: &s) { sBuffer in
            sBuffer.baseAddress!.assumingMemoryBound(to: CChar.self).update(from: cStr, count: cStr.count)
        }
	}

	init?(scriptPubKey: [UInt8]) {
		self.init()
		let success = withUnsafeMutableBytes(of: &s) { sBuffer in
			BRAddressFromScriptPubKey(sBuffer.baseAddress!.assumingMemoryBound(to: CChar.self),
			    MemoryLayout<BRAddress>.size, scriptPubKey, scriptPubKey.count) > 0
		}
		guard success else { return nil }
	}

	init?(scriptSig: [UInt8]) {
		self.init()
		let success = withUnsafeMutableBytes(of: &s) { sBuffer in
			BRAddressFromScriptSig(sBuffer.baseAddress!.assumingMemoryBound(to: CChar.self),
			    MemoryLayout<BRAddress>.size, scriptSig, scriptSig.count) > 0
		}
		guard success else { return nil }
	}

	var scriptPubKey: [UInt8]? {
		var script = [UInt8](repeating: 0, count: 25)
		let count = withUnsafeBytes(of: s) { sBuffer in
			BRAddressScriptPubKey(&script, script.count,
			    sBuffer.baseAddress!.assumingMemoryBound(to: CChar.self))
		}
		guard count > 0 else { return nil }
		if count < script.count { script.removeSubrange(count...) }
		return script
	}

	var hash160: UInt160? {
		var hash = UInt160()
		let success = withUnsafeBytes(of: s) { sBuffer in
			BRAddressHash160(&hash, sBuffer.baseAddress!.assumingMemoryBound(to: CChar.self)) != 0
		}
		guard success else { return nil }
		return hash
	}

	public var description: String {
		return withUnsafeBytes(of: s) { sBuffer in
			String(cString: sBuffer.baseAddress!.assumingMemoryBound(to: CChar.self))
		}
	}

	public var hashValue: Int {
		return BRAddressHash([s])
	}

	public static func == (l: BRAddress, r: BRAddress) -> Bool {
		return BRAddressEq([l.s], [r.s]) != 0
	}
}
