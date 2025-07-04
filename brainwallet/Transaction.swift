import BRCore
import UIKit

// Ideally this would be a struct, but it needs to be a class to allow
// for lazy variables

struct TransactionStatusTuple {
	var percentageString: String
	var units: Int
}

class Transaction {
	// MARK: - Public

	private let opsAddressSet: Set<String> = Partner.walletOpsSet()

	init?(_ tx: BRTxRef, walletManager: WalletManager, kvStore: BRReplicatedKVStore?, rate: Rate?) {

		guard let wallet = walletManager.wallet else { return nil }
		guard let peerManager = walletManager.peerManager else { return nil }

		self.tx = tx
		self.wallet = wallet
		self.kvStore = kvStore
		let fee = wallet.feeForTx(tx) ?? 0

		var outputAddresses = Set<String>()
		var opsAmount = UInt64(0)

		for (_, output) in tx.outputs.enumerated() {
			outputAddresses.insert(output.updatedSwiftAddress)
		}

		let outputAddress = opsAddressSet.intersection(outputAddresses).first
		if let targetAddress = outputAddress,
		   let opsOutput = tx.outputs.filter({ $0.updatedSwiftAddress == targetAddress }).first {
			opsAmount = opsOutput.amount
		}

		self.fee = fee + opsAmount

		let amountReceived = wallet.amountReceivedFromTx(tx)

        var amountSent =  UInt64(0)
        if opsAmount > wallet.amountSentByTx(tx) {
          amountSent = wallet.amountSentByTx(tx)
        } else {
            amountSent = wallet.amountSentByTx(tx) - opsAmount
        }

		if amountSent > 0, (amountReceived + fee) == amountSent {
			direction = .moved
			satoshis = amountSent
		} else if amountSent > 0 {
			direction = .sent
			satoshis = amountSent - amountReceived - fee
		} else {
			direction = .received
			satoshis = amountReceived
		}
		timestamp = Int(tx.pointee.timestamp)

		isValid = wallet.transactionIsValid(tx)
		let transactionBlockHeight = tx.pointee.blockHeight
		self.blockHeight = tx.pointee.blockHeight == UInt32(INT32_MAX) ? "Not confirmed"  : "\(tx.pointee.blockHeight)"

		let blockHeight = peerManager.lastBlockHeight
		confirms = transactionBlockHeight > blockHeight ? 0 : Int(blockHeight - transactionBlockHeight) + 1
		status = makeStatus(tx, wallet: wallet, peerManager: peerManager, confirms: confirms, direction: direction)

		hash = tx.pointee.txHash.description
		metaDataKey = tx.pointee.txHash.txKey

		if let rate = rate, confirms < 6, direction == .received {
			attemptCreateMetaData(tx: tx, rate: rate)
		}
	}

	func amountDescription(isLtcSwapped: Bool, rate: Rate, maxDigits: Int) -> String {
		let amount = Amount(amount: satoshis, rate: rate, maxDigits: maxDigits)
		return isLtcSwapped ? amount.localCurrency : amount.bits
	}

	func descriptionString(isLtcSwapped: Bool, rate: Rate, maxDigits: Int) -> NSAttributedString {
		let amount = Amount(amount: satoshis, rate: rate, maxDigits: maxDigits).string(isLtcSwapped: isLtcSwapped)
		let format = direction.amountDescriptionFormat
		let string = String(format: format, amount)
		return string.attributedStringForTags
	}

	var detailsAddressText: String {
		let address = toAddress?.largeCondensed
		return String(format: direction.addressTextFormat, address ?? "account" )
	}

	func amountDetails(isLtcSwapped: Bool, rate: Rate, rates: [Rate], maxDigits: Int) -> String {
		let feeAmount = Amount(amount: fee, rate: rate, maxDigits: maxDigits)
		let feeString = direction == .sent ? String(format: "Fee" , "\(feeAmount.string(isLtcSwapped: isLtcSwapped))") : ""
		let amountString = "\(direction.sign)\(Amount(amount: satoshis, rate: rate, maxDigits: maxDigits).string(isLtcSwapped: isLtcSwapped)) \(feeString)"
		var startingString = String(format:"Starting balance: %1$@", "\(Amount(amount: startingBalance, rate: rate, maxDigits: maxDigits).string(isLtcSwapped: isLtcSwapped))")
		var endingString = String(format: String(format: "Ending balance: %1$@", "\(Amount(amount: balanceAfter, rate: rate, maxDigits: maxDigits).string(isLtcSwapped: isLtcSwapped))"))

		if startingBalance > C.maxMoney {
			startingString = ""
			endingString = ""
		}

		var exchangeRateInfo = ""
		if let metaData = metaData, let currentRate = rates.filter({ $0.code.lowercased() == metaData.exchangeRateCurrency.lowercased() }).first {
			let difference = (currentRate.rate - metaData.exchangeRate) / metaData.exchangeRate * 100.0
			let prefix = difference > 0.0 ? "+" : "-"
			let firstLine = direction == .sent ? "Exchange rate when sent:" : "Exchange rate when received:"
			let nf = NumberFormatter()
			nf.currencySymbol = currentRate.currencySymbol
			nf.numberStyle = .currency
			if let rateString = nf.string(from: metaData.exchangeRate as NSNumber) {
				let secondLine = "\(rateString)/LTC \(prefix)\(String(format: "%.2f", difference))%"
				exchangeRateInfo = "\(firstLine)\n\(secondLine)"
			}
		}

		return "\(amountString)\n\(startingString)\n\(endingString)\n\(exchangeRateInfo)"
	}

	func amountDetailsAmountString(isLtcSwapped: Bool, rate: Rate, rates _: [Rate], maxDigits: Int) -> String {
		let feeAmount = Amount(amount: fee, rate: rate, maxDigits: maxDigits)
		let feeString = direction == .sent ? String(format: "fee" , "\(feeAmount.string(isLtcSwapped: isLtcSwapped))") : ""
		return "\(direction.sign)\(Amount(amount: satoshis, rate: rate, maxDigits: maxDigits).string(isLtcSwapped: isLtcSwapped)) \(feeString)"
	}

	func amountDetailsStartingBalanceString(isLtcSwapped: Bool, rate: Rate, rates _: [Rate], maxDigits: Int) -> String {
		return String(format: "Starting balance: %1$@" , "\(Amount(amount: startingBalance, rate: rate, maxDigits: maxDigits).string(isLtcSwapped: isLtcSwapped))")
	}

	func amountDetailsEndingBalanceString(isLtcSwapped: Bool, rate: Rate, rates _: [Rate], maxDigits: Int) -> String {
		return String(format: String(format: "Ending balance: %1$@" , "\(Amount(amount: balanceAfter, rate: rate, maxDigits: maxDigits).string(isLtcSwapped: isLtcSwapped))"))
	}

	func amountExchangeString(isLtcSwapped _: Bool, rate _: Rate, rates: [Rate], maxDigits _: Int) -> String {
		var exchangeRateInfo = ""
		if let metaData = metaData, let currentRate = rates.filter({ $0.code.lowercased() == metaData.exchangeRateCurrency.lowercased() }).first {
			let difference = (currentRate.rate - metaData.exchangeRate) / metaData.exchangeRate * 100.0
			let prefix = difference > 0.0 ? "+" : "-"
			let nf = NumberFormatter()
			nf.currencySymbol = currentRate.currencySymbol
			nf.numberStyle = .currency
			if let rateString = nf.string(from: metaData.exchangeRate as NSNumber) {
				// TODO: Decide the usefulness of the rate percentage or a better way to describe it
				let secondLine = "\(rateString)/LTC \(prefix)\(String(format: "%.2f", difference))%"
				exchangeRateInfo = "\(secondLine)"
			}
		}
		return exchangeRateInfo
	}

	let direction: TransactionDirection
	let status: String
	let timestamp: Int
	let fee: UInt64
	let hash: String
	let isValid: Bool
	let blockHeight: String
	private let confirms: Int
	private let metaDataKey: String

	// MARK: - Private

	private let tx: BRTxRef
	private let wallet: BRWallet
	private let satoshis: UInt64
	private var kvStore: BRReplicatedKVStore?

	lazy var toAddress: String? = {
		var outputAddresses = Set<String>()
		for (_, output) in tx.outputs.enumerated() {
			outputAddresses.insert(output.updatedSwiftAddress)
		}
		let usedOpsAddress = outputAddresses.intersection(opsAddressSet).first
		let nonOpsAddressesSet = self.tx.outputs.filter { $0.updatedSwiftAddress != usedOpsAddress }

		switch self.direction {
		case .sent:

			let toAddressOutput = nonOpsAddressesSet.filter { output in
				!self.wallet.containsAddress(output.updatedSwiftAddress)
			}.first

			guard let toAddress = toAddressOutput?.updatedSwiftAddress else {
				return "---ERROR---"
			}
			return toAddress

		case .received:

			let toAddressOutput = nonOpsAddressesSet.filter { output in
				self.wallet.containsAddress(output.updatedSwiftAddress)
			}.first

			guard let fromAddress = toAddressOutput?.updatedSwiftAddress else {
				return "---ERROR---"
			}
			return fromAddress

		case .moved:
			guard let output = self.tx.outputs.filter({ output in
				self.wallet.containsAddress(output.updatedSwiftAddress)
			}).first else {
				return "---ERROR---"
			}
			return output.updatedSwiftAddress
		}
	}()

	var exchangeRate: Double? {
		return metaData?.exchangeRate
	}

	var comment: String? {
		if metaData?.comment != nil {
			// debugPrint(":::=== memo comments \(metaData?.comment ?? "NO MEMO")")
		}
		return metaData?.comment
	}

	var hasKvStore: Bool {
		return kvStore != nil
	}

	var _metaData: TxMetaData?
	var metaData: TxMetaData? {
		if _metaData != nil {
			return _metaData
		} else {
			guard let kvStore = kvStore else { return nil }
			if let data = TxMetaData(txKey: metaDataKey, store: kvStore) {
				_metaData = data
				return _metaData
			} else {
				return nil
			}
		}
	}

	private var balanceAfter: UInt64 {
		return wallet.balanceAfterTx(tx)
	}

	private lazy var startingBalance: UInt64 = {
		switch self.direction {
		case .received:
			return
				self.balanceAfter.subtractingReportingOverflow(self.satoshis).0.subtractingReportingOverflow(self.fee).0
		case .sent:
			return self.balanceAfter.addingReportingOverflow(self.satoshis).0.addingReportingOverflow(self.fee).0
		case .moved:
			return self.balanceAfter.addingReportingOverflow(self.fee).0
		}
	}()

	var timeSince: (String, Bool) {
		if let cached = timeSinceCache {
			return cached
		}

		let result: (String, Bool)
		guard timestamp > 0
		else {
			result = ("just now" , false)
			timeSinceCache = result
			return result
		}
		let then = Date(timeIntervalSince1970: TimeInterval(timestamp))
		let now = Date()

		if !now.hasEqualYear(then) {
			let df = DateFormatter()
			df.setLocalizedDateFormatFromTemplate("dd/MM/yy")
			result = (df.string(from: then), false)
			timeSinceCache = result
			return result
		}

		if !now.hasEqualMonth(then) {
			let df = DateFormatter()
			df.setLocalizedDateFormatFromTemplate("MMM dd")
			result = (df.string(from: then), false)
			timeSinceCache = result
			return result
		}

		let difference = Int(Date().timeIntervalSince1970) - timestamp
		let secondsInMinute = 60
		let secondsInHour = 3600
		let secondsInDay = 86400
		let secondsInWeek = secondsInDay * 7
		if difference < secondsInMinute {
			result = (String(format: "%1$@ s" , "\(difference)"), true)
		} else if difference < secondsInHour {
			result = (String(format: "%1$@ m" , "\(difference / secondsInMinute)"), true)
		} else if difference < secondsInDay {
			result = (String(format: "%1$@ h" , "\(difference / secondsInHour)"), false)
		} else if difference < secondsInWeek {
			result = (String(format: "%1$@ d" , "\(difference / secondsInDay)"), false)
		} else {
			let df = DateFormatter()
			df.setLocalizedDateFormatFromTemplate("MMM dd")
			result = (df.string(from: then), false)
		}
		if result.1 == false {
			timeSinceCache = result
		}
		return result
	}

	private var timeSinceCache: (String, Bool)?

	var longTimestamp: String {
		guard timestamp > 0 else { return wallet.transactionIsValid(tx) ? "just now"  : "" }
		let date = Date(timeIntervalSince1970: Double(timestamp))
		return Transaction.longDateFormatter.string(from: date)
	}

	var shortTimestamp: String {
		guard timestamp > 0 else { return wallet.transactionIsValid(tx) ? "just now"  : "" }
		let date = Date(timeIntervalSince1970: Double(timestamp))
		return Transaction.shortDateFormatter.string(from: date)
	}

	var rawTransaction: BRTransaction {
		return tx.pointee
	}

	var isPending: Bool {
		return confirms < 6
	}

	static let longDateFormatter: DateFormatter = {
		let df = DateFormatter()
		df.setLocalizedDateFormatFromTemplate("MMMM d, yyy h:mm a")
		return df
	}()

	static let shortDateFormatter: DateFormatter = {
		let df = DateFormatter()
		df.setLocalizedDateFormatFromTemplate("MMM d, h:mm a")
		return df
	}()

	private func attemptCreateMetaData(tx: BRTxRef, rate: Rate) {
		guard metaData == nil else { return }
		let newData = TxMetaData(transaction: tx.pointee,
		                         exchangeRate: rate.rate,
		                         exchangeRateCurrency: rate.code,
		                         feeRate: 0.0,
		                         deviceId: UserDefaults.standard.deviceID)
		do {
			_ = try kvStore?.set(newData)
		} catch {
			debugPrint("::: ERROR could not update metadata: \(error)")
		}
	}

	var shouldDisplayAvailableToSpend: Bool {
		return confirms > 1 && confirms < 6 && direction == .received
	}
}

private extension String {
	var smallCondensed: String {
		let start = String(self[..<index(startIndex, offsetBy: 5)])
		let end = String(self[index(endIndex, offsetBy: -5)...])
		return start + "..." + end
	}

	var largeCondensed: String {
		let start = String(self[..<index(startIndex, offsetBy: 10)])
		let end = String(self[index(endIndex, offsetBy: -10)...])
		return start + "..." + end
	}
}

private func makeStatus(_ txRef: BRTxRef, wallet: BRWallet, peerManager: BRPeerManager, confirms: Int, direction: TransactionDirection) -> String {
	let tx = txRef.pointee
	guard wallet.transactionIsValid(txRef)
	else {
		return "Invalid"
	}

	if confirms < 6 {
		var percentageString = ""
		if confirms == 0 {
			let relayCount = peerManager.relayCount(tx.txHash)
			if relayCount == 0 {
				percentageString = "0%"
			} else if relayCount == 1 {
				percentageString = "20%"
			} else if relayCount > 1 {
				percentageString = "40%"
			}
		} else if confirms == 1 {
			percentageString = "60%"
		} else if confirms == 2 {
			percentageString = "80%"
		} else if confirms > 2 {
			percentageString = "100%"
		}
		let format = direction == .sent ? String(localized: "In progress: %1$@")  : String(localized: "In progress: %1$@")
		return String(format: format, percentageString)
	} else {
		return String(localized: "Complete", bundle: .main)
	}
}

extension Transaction: Equatable {}

func == (lhs: Transaction, rhs: Transaction) -> Bool {
	return lhs.hash == rhs.hash && lhs.status == rhs.status && lhs.comment == rhs.comment && lhs.hasKvStore == rhs.hasKvStore
}
