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

/// The 3 selectable fee-per-kb tiers shown by the Settings network fee picker
/// (SettingsLitecoinDetailView), split out from the view so the math is unit-testable
/// without instantiating SwiftUI state.
enum NetworkFeeTier: Int, CaseIterable {
	case economy = 0
	case regular = 1
	case luxury = 2

	/// The tier's fee-per-kb, in litoshis.
	func litoshis(from fees: Fees) -> UInt64 {
		switch self {
		case .economy: return fees.economy
		case .regular: return fees.regular
		case .luxury: return fees.luxury
		}
	}

	/// The tier whose fee (in litoshis) is numerically closest to `storedLitoshis`
	/// (e.g. a previously persisted `UserDefaults.userSetPreferredNetworkFee`).
	/// Ties favor the lower tier (economy over regular, regular over luxury).
	static func closest(to storedLitoshis: Int, in fees: Fees) -> NetworkFeeTier {
		allCases.min {
			abs(Int($0.litoshis(from: fees)) - storedLitoshis) < abs(Int($1.litoshis(from: fees)) - storedLitoshis)
		} ?? .regular
	}

	/// Converts a litoshi fee-per-kb into a formatted fiat string (e.g. "12.34 USD"),
	/// or "" when the calculated amount is zero (no fee, or no rate loaded yet).
	static func formattedFiatAmount(litoshis: UInt64, rate: Rate) -> String {
		let feeInLTC = Double(litoshis) / Double(C.litoshis)
		let calculation = feeInLTC * rate.rate
		return calculation == 0 ? "" : String(format: "%.3f %@", calculation, rate.code)
	}
}
