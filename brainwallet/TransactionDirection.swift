import Foundation

enum TransactionDirection: String {
	case sent = "Sent"
	case received = "Received"
	case moved = "Moved"

	var amountFormat: String {
		switch self {
		case .sent:
			return "Sent <b>%1@</b>"
		case .received:
			return "Received <b>%1@</b>"
		case .moved:
			return "Moved <b>%1@</b>"
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
			return "Sent to this Address"
		case .received:
			return "Received at this Address"
		case .moved:
			return "Sent to this Address"
		}
	}

	var amountDescriptionFormat: String {
		switch self {
		case .sent:
			return "Sent <b>%1@</b>"
		case .received:
			return "Received <b>%1@</b>"
		case .moved:
			return "Moved <b>%1@</b>"
		}
	}

	var addressTextFormat: String {
		switch self {
		case .sent:
			return "to %1$@"
		case .received:
			return "at %1$@"
		case .moved:
			return "to %1$@"
		}
	}
}
