import Foundation

struct Amount: Equatable {
	// MARK: - Public

	let amount: UInt64 // amount in satoshis
	let rate: Rate
	let maxDigits: Int

	var amountForLtcFormat: Double {
		var decimal = Decimal(self.amount)
		var amount: Decimal = 0.0
		NSDecimalMultiplyByPowerOf10(&amount, &decimal, Int16(-maxDigits), .up)
		return NSDecimalNumber(decimal: amount).doubleValue
	}

	var localAmount: Double {
		return Double(amount) / 100_000_000.0 * rate.rate
	}

	var bits: String {
		var decimal = Decimal(self.amount)
		var amount: Decimal = 0.0
		NSDecimalMultiplyByPowerOf10(&amount, &decimal, Int16(-maxDigits), .up)
		let number = NSDecimalNumber(decimal: amount)
		guard let string = ltcFormat.string(from: number) else { return "" }
		return string
	}

	var localCurrency: String {
		guard let string = localFormat.string(from: Double(amount) / 100_000_000.0 * rate.rate as NSNumber) else { return "" }
		return string
	}

	func string(forLocal local: Locale) -> String {
		let format = NumberFormatter()
		format.locale = local
		format.isLenient = true
		format.numberStyle = .currency
		format.generatesDecimalNumbers = true
		format.negativePrefix = "-"
		guard let string = format.string(from: Double(amount) / 100_000_000.0 * rate.rate as NSNumber) else { return "" }
		return string
	}

	func string(isLtcSwapped: Bool) -> String {
		return isLtcSwapped ? localCurrency : bits
	}

	var ltcFormat: NumberFormatter {
		let format = NumberFormatter()
		format.isLenient = true
		format.numberStyle = .currency
		format.generatesDecimalNumbers = true
		format.negativePrefix = "-"
		format.currencyCode = "LTC"

		switch maxDigits {
		case 2: // photons
			format.currencySymbol = "mł  "
			format.maximum = (C.maxMoney / C.satoshis) * 100_000 as NSNumber
		case 5: // lites
			format.currencySymbol = "ł  "
			format.maximum = (C.maxMoney / C.satoshis) * 1000 as NSNumber
		case 8: // litecoin
			format.currencySymbol = "Ł "
			format.maximum = C.maxMoney / C.satoshis as NSNumber
		default:
			format.currencySymbol = "ł  "
		}

		format.maximumFractionDigits = maxDigits
		format.minimumFractionDigits = 0 // iOS 8 bug, minimumFractionDigits now has to be set after currencySymbol
		format.maximum = Decimal(C.maxMoney) / pow(10.0, maxDigits) as NSNumber

		return format
	}

	var localFormat: NumberFormatter {
		let format = NumberFormatter()
		format.isLenient = true
		format.numberStyle = .currency
		format.generatesDecimalNumbers = true
		format.negativePrefix = "-"
		format.currencySymbol = rate.currencySymbol
		return format
	}
}

struct DisplayAmount {
	let amount: Satoshis
	let state: ReduxState
	let selectedRate: Rate?
	let minimumFractionDigits: Int?

	var description: String {
		return selectedRate != nil ? fiatDescription : litecoinDescription
	}

	var combinedDescription: String {
		return state.isLtcSwapped ? "\(fiatDescription) (\(litecoinDescription))" : "\(litecoinDescription) (\(fiatDescription))"
	}

	private var fiatDescription: String {
		guard let rate = selectedRate ?? state.currentRate else { return "" }
		guard let string = localFormat.string(from: Double(amount.rawValue) / 100_000_000.0 * rate.rate as NSNumber) else { return "" }
		return string
	}

	private var litecoinDescription: String {
		var decimal = Decimal(self.amount.rawValue)
		var amount: Decimal = 0.0
		NSDecimalMultiplyByPowerOf10(&amount, &decimal, Int16(-state.maxDigits), .up)
		let number = NSDecimalNumber(decimal: amount)
		guard let string = ltcFormat.string(from: number) else { return "" }
		return string
	}

	var localFormat: NumberFormatter {
		let format = NumberFormatter()
		format.isLenient = true
		format.numberStyle = .currency
		format.generatesDecimalNumbers = true
		format.negativePrefix = "-"
		if let rate = selectedRate {
			format.currencySymbol = rate.currencySymbol
		} else if let rate = state.currentRate {
			format.currencySymbol = rate.currencySymbol
		}
		if let minimumFractionDigits = minimumFractionDigits {
			format.minimumFractionDigits = minimumFractionDigits
		}
		return format
	}

	var ltcFormat: NumberFormatter {
		let format = NumberFormatter()
		format.isLenient = true
		format.numberStyle = .currency
		format.generatesDecimalNumbers = true
		format.negativePrefix = "-"
		format.currencyCode = "LTC"

		switch state.maxDigits {
		case 2:
			format.currencySymbol = "mł  "
			format.maximum = (C.maxMoney / C.satoshis) * 100_000 as NSNumber
		case 5:
			format.currencySymbol = "ł  "
			format.maximum = (C.maxMoney / C.satoshis) * 1000 as NSNumber
		case 8:
			format.currencySymbol = "Ł "
			format.maximum = C.maxMoney / C.satoshis as NSNumber
		default:
			format.currencySymbol = "ł  "
		}

		format.maximumFractionDigits = state.maxDigits
		if let minimumFractionDigits = minimumFractionDigits {
			format.minimumFractionDigits = minimumFractionDigits
		}
		format.maximum = Decimal(C.maxMoney) / pow(10.0, state.maxDigits) as NSNumber

		return format
	}
}
