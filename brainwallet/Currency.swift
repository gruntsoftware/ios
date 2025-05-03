import Foundation
import UIKit

class Currency {
	class func getSymbolForCurrencyCode(code: String) -> String? {
		print(" ::: \(code)")
		let result = Locale.availableIdentifiers.map {
			Locale(identifier: $0)
        }.first { $0.currency?.identifier == code }
		return result?.currencySymbol
	}
}

import Foundation
import UIKit

/// 14  Currencies
enum CurrencySelection: Int, CaseIterable, Equatable, Identifiable {
    case USD = 0
    case EUR
    case GBP
    case SGD
    case CAD
    case AUD
    case RUB
    case KRW
    case MXN
    case SAR
    case UAH
    case NGN
    case JPY
    case CNY
    case IDR
    case TRY
      
    var id: CurrencySelection { self }

    var symbol: String {
        switch self {
        case .USD: return "$"
        case .EUR: return "€"
        case .GBP: return "£"
        case .SGD: return "$"
        case .CAD: return "$"
        case .AUD: return "$"
        case .RUB: return "₽"
        case .KRW: return "₩"
        case .MXN: return "$"
        case .SAR: return "﷼"
        case .UAH: return "₴"
        case .NGN: return "₦"
        case .JPY: return "¥"
        case .CNY: return "¥"
        case .IDR: return "Rp"
        case .TRY: return "₺"
        }
    }

    var fullCurrencyName: String {
        switch self {
        case .USD: return "US Dollar"
        case .EUR: return "Euro"
        case .GBP: return "Great British Pound"
        case .SGD: return "Singaporean Dollar"
        case .CAD: return "Canadian Dollar"
        case .AUD: return "Australian Dollar"
        case .RUB: return "Russian Ruble"
        case .KRW: return "Korean Won"
        case .MXN: return "Mexican Peso"
        case .SAR: return "Saudi Riyal"
        case .UAH: return "Ukrainian Hryvnia"
        case .NGN: return "Nigerian Naira"
        case .JPY: return "Japanese Yen"
        case .CNY: return "Chinese Yuan"
        case .IDR: return "Indonesian Rupiah"
        case .TRY: return "Turkish Lira"
        }
    }
}
 
enum PartnerFiatOptions: Int, CustomStringConvertible {
	case cad
	case aud
	case idr
	case tur
	case jpy
	case eur
	case gbp
	case usd

	public var description: String {
		return code
	}

	private var code: String {
		switch self {
		case .cad: return "CAD"
		case .aud: return "AUD"
		case .idr: return "IDR"
		case .tur: return "TRY"
		case .jpy: return "JPY"
		case .eur: return "EUR"
		case .gbp: return "GBP"
		case .usd: return "USD"
		}
	}

	public var index: Int {
		switch self {
		case .cad: return 0
		case .aud: return 1
		case .idr: return 2
		case .tur: return 3
		case .jpy: return 4
		case .eur: return 5
		case .gbp: return 6
		case .usd: return 7
		}
	}
}
