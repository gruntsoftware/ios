import FirebaseAnalytics
import Foundation

// this is the default that matches the mobile-api if the server is unavailable
private let defaultEconomyFeePerKB: UInt64 = 8000 // Updated Dec 2, 2024
private let defaultRegularFeePerKB: UInt64 = 25000
private let defaultLuxuryFeePerKB: UInt64 = 66746
private let defaultTimestamp: UInt64 = 1_583_015_199_122

struct Fees: Equatable {
	let luxury: UInt64
	let regular: UInt64
	let economy: UInt64
	let timestamp: UInt64

	static var usingDefaultValues: Fees {
		return Fees(luxury: defaultLuxuryFeePerKB,
		            regular: defaultRegularFeePerKB,
		            economy: defaultEconomyFeePerKB,
		            timestamp: defaultTimestamp)
	}
}

enum FeeType {
	case regular
	case economy
	case luxury
}
