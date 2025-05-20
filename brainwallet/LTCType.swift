import Foundation
import UIKit

// MARK: - Litoshis

let litoshisPerLitecoin: UInt64 = 100_000_000
let litesPerLitoshis: Double = 100.0
let maximumLitoshis: UInt64 = 84_000_000 * litoshisPerLitecoin
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

    init(litecoinAmount: LitecoinAmount) {
        rawValue = UInt64((litecoinAmount.rawValue * Double(litoshis)).rounded(.toNearestOrEven))
    }

    init(value: Double, rate: Rate) {
        rawValue = UInt64((value / rate.rate * Double(litoshis)).rounded(.toNearestOrEven))
    }

    init?(ltcString: String) {
        guard let decimalAmount = Decimal(string: ltcString) else {
            return nil
        }

        let litoshisPerLTC = Decimal(100_000_000)
        let litoshiAmount: Decimal = decimalAmount * litoshisPerLTC
        let bridgedLitoshiAmount = NSDecimalNumber(decimal: litoshiAmount)
        
        guard litoshiAmount.isFinite,
              litoshiAmount >= 0,
              let value = UInt64(exactly: bridgedLitoshiAmount) else {
            return nil
        }

        self.rawValue = value
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

struct LitecoinAmount {
    let rawValue: Double
}

extension LitecoinAmount {
    init?(string: String) {
        guard let value = Double(string) else { return nil }
        rawValue = value
    }
}

extension Litoshis: Equatable {}

func == (lhs: Litoshis, rhs: Litoshis) -> Bool {
    return lhs.rawValue == rhs.rawValue
}

func == (lhs: Litoshis?, rhs: UInt64) -> Bool {
    return lhs?.rawValue == rhs
}

func + (lhs: Litoshis, rhs: UInt64) -> Litoshis {
    return Litoshis(lhs.rawValue + rhs)
}

func + (lhs: Litoshis, rhs: Litoshis) -> Litoshis {
    return Litoshis(lhs.rawValue + rhs.rawValue)
}

func += (lhs: inout Litoshis, rhs: UInt64) {
    lhs = lhs + rhs
}

func > (lhs: Litoshis, rhs: UInt64) -> Bool {
    return lhs.rawValue > rhs
}

func < (lhs: Litoshis, rhs: UInt64) -> Bool {
    return lhs.rawValue < rhs
}
