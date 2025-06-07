import Foundation
import UIKit

class Currency {
	class func getSymbolForCurrencyCode(code: String) -> String? {
		let result = Locale.availableIdentifiers.map {
			Locale(identifier: $0)
        }.first { $0.currency?.identifier == code }
		return result?.currencySymbol
	}
}

enum SupportedFiatCurrencies: Int, CaseIterable, Equatable, Identifiable {
    case USD = 0
    case EUR
    case GBP
    case IDR
    case CAD
    case AUD
    case MXN
    case BRL
    case CHF
    case NGN
    case TRY
    case ZAR
    
    static func from(code: String) -> SupportedFiatCurrencies? {
            return allCases.first { $0.code == code }
    }
    
    var id: SupportedFiatCurrencies { self }

    var symbol: String {
        switch self {
        case .USD: return "$"
        case .EUR: return "€"
        case .GBP: return "£"
        case .IDR: return "Rp"
        case .CAD: return "$"
        case .AUD: return "$"
        case .MXN: return "$"
        case .BRL: return "R$"
        case .CHF: return "Fr"
        case .NGN: return "₦"
        case .TRY: return "₺"
        case .ZAR: return "R"
        }
    }
    
    var code: String {
        switch self {
        case .USD: return "USD"
        case .EUR: return "EUR"
        case .GBP: return "GBP"
        case .IDR: return "IDR"
        case .CAD: return "CAD"
        case .AUD: return "AUD"
        case .MXN: return "MXN"
        case .BRL: return "BRL"
        case .CHF: return "CHF"
        case .NGN: return "NGN"
        case .TRY: return "TRY"
        case .ZAR: return "ZAR"
        }
    }

    var fullCurrencyName: String {
        switch self {
        case .USD: return "US Dollar"
        case .EUR: return "Euro"
        case .GBP: return "Great British Pound"
        case .IDR: return "Indonesian Rupiah"
        case .CAD: return "Canadian Dollar"
        case .AUD: return "Australian Dollar"
        case .MXN: return "Mexican Peso"
        case .BRL: return "Brasil Real"
        case .CHF: return "Swiss Franc"
        case .NGN: return "Nigerian Naira"
        case .TRY: return "Turkish Lira"
        case .ZAR: return "South African Rand"
        }
    }
}
