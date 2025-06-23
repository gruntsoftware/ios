import Foundation

enum TransactionDirection: String {
	case sent = "Sent"
	case received = "Received"
	case moved = "Moved"

	var amountFormat: String {
		switch self {
		case .sent:
			return String(localized: "Sent <b>%1@</b>")
		case .received:
			return String(localized: "Received <b>%1@</b>")
		case .moved:
			return String(localized: "Moved <b>%1@</b>")
		}
	}

	var sign: String {
		switch self {
		case .sent:
			return "-"
		case .received:
			return ""
		case .moved:
			return ""
		}
	}

	var addressHeader: String {
		switch self {
		case .sent:
			return String(localized: "Sent to this Address")
		case .received:
			return String(localized: "Received at this Address")
		case .moved:
			return String(localized: "Sent to this Address")
		}
	}

	var amountDescriptionFormat: String {
		switch self {
		case .sent:
			return String(localized: "Sent <b>%1@</b>")
		case .received:
			return String(localized: "Received <b>%1@</b>")
		case .moved:
			return String(localized: "Moved <b>%1@</b>")
		}
	}

	var addressTextFormat: String {
		switch self {
		case .sent:
			return String(localized: "to %1$@")
		case .received:
			return String(localized: "at %1$@")
		case .moved:
			return String(localized: "to %1$@")
		}
	}
}
