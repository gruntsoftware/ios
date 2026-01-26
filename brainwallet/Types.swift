import Foundation
import UIKit

// MARK: - Litoshis

struct Litoshis {
    let rawValue: UInt64
}

extension Litoshis {
    init(_ rawValue: UInt64) {
        self.rawValue = rawValue
    }

    init(lites: Lites) {
        rawValue = UInt64((lites.rawValue * 100.0).rounded(.toNearestOrEven))
    }

    init(litecoin: Litecoin) {
        rawValue = UInt64((litecoin.rawValue * Double(C.litoshis)).rounded(.toNearestOrEven))
    }

    init(value: Double, rate: Rate) {
        rawValue = UInt64((value / rate.rate * Double(C.litoshis)).rounded(.toNearestOrEven))
    }

    init?(ltcString: String) {
        guard let decimal = Decimal(string: ltcString) else { return nil }
        let amount = decimal * pow(10, 8)
        rawValue = NSDecimalNumber(decimal: amount).uint64Value
    }
}

// MARK: - Lites

struct Lites {
    let rawValue: Double
}

extension Lites {
    init(litoshis: Litoshis) {
        rawValue = Double(litoshis.rawValue) / 100.0
    }

    init?(string: String) {
        guard let value = Double(string) else { return nil }
        rawValue = value
    }
}

// MARK: - Litecoin

struct Litecoin {
    let rawValue: Double
}

extension Litecoin {
    init?(string: String) {
        guard let value = Double(string) else { return nil }
        rawValue = value
    }
}

// MARK: - Satoshis

struct Satoshis {
    let rawValue: UInt64
}

extension Satoshis {
    init(_ rawValue: UInt64) {
        self.rawValue = rawValue
    }

    init(bits: Bits) {
        rawValue = UInt64((bits.rawValue * 100.0).rounded(.toNearestOrEven))
    }

    init(bitcoin: Bitcoin) {
        rawValue = UInt64((bitcoin.rawValue * Double(C.satoshis)).rounded(.toNearestOrEven))
    }

    init(value: Double, rate: Rate) {
        rawValue = UInt64((value / rate.rate * Double(C.satoshis)).rounded(.toNearestOrEven))
    }

    init?(btcString: String) {
        guard let decimal = Decimal(string: btcString) else { return nil }
        let amount = decimal * pow(10, 8)
        rawValue = NSDecimalNumber(decimal: amount).uint64Value
    }
}

extension Satoshis: Equatable {}

func == (lhs: Satoshis, rhs: Satoshis) -> Bool {
	return lhs.rawValue == rhs.rawValue
}

func == (lhs: Satoshis?, rhs: UInt64) -> Bool {
	return lhs?.rawValue == rhs
}

func + (lhs: Satoshis, rhs: UInt64) -> Satoshis {
	return Satoshis(lhs.rawValue + rhs)
}

func + (lhs: Satoshis, rhs: Satoshis) -> Satoshis {
	return Satoshis(lhs.rawValue + rhs.rawValue)
}

func += (lhs: inout Satoshis, rhs: UInt64) {
	lhs = lhs + rhs
}

func > (lhs: Satoshis, rhs: UInt64) -> Bool {
	return lhs.rawValue > rhs
}

func < (lhs: Satoshis, rhs: UInt64) -> Bool {
	return lhs.rawValue < rhs
}

// MARK: - Bits

struct Bits {
	let rawValue: Double
}

extension Bits {
	init(satoshis: Satoshis) {
		rawValue = Double(satoshis.rawValue) / 100.0
	}

	init?(string: String) {
		guard let value = Double(string) else { return nil }
		rawValue = value
	}
}

// MARK: - Bitcoin

struct Bitcoin {
	let rawValue: Double
}

extension Bitcoin {
	init?(string: String) {
		guard let value = Double(string) else { return nil }
		rawValue = value
	}
}
