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


enum GlobalCurrencies: Int, CaseIterable, Equatable, Identifiable {
    // Major World Currencies
    case USD = 0
    case EUR
    case JPY
    case GBP
    case AUD
    case CAD
    case CHF
    case CNY
    case HKD
    case NZD
    
    // Other Important Currencies
    case SEK
    case NOK
    case DKK
    case PLN
    case CZK
    case HUF
    case RUB
    case KRW
    case SGD
    case THB
    case MYR
    case IDR
    case PHP
    case VND
    case INR
    case PKR
    case BDT
    case LKR
    case NPR
    
    // Middle East & Africa
    case AED
    case SAR
    case QAR
    case KWD
    case BHD
    case OMR
    case JOD
    case ILS
    case TRY
    case EGP
    case ZAR
    case NGN
    case KES
    case GHS
    case MAD
    case TND
    case DZD
    
    // Americas
    case MXN
    case BRL
    case ARS
    case CLP
    case COP
    case PEN
    case UYU
    case BOB
    case PYG
    case VES
    case CRC
    case GTQ
    case HNL
    case NIO
    case PAB
    case DOP
    case JMD
    case TTD
    case BBD
    case XCD
    
    // Europe (Non-Euro)
    case RON
    case BGN
    case HRK
    case RSD
    case MKD
    case BAM
    case ALL
    case MDL
    case UAH
    case BYN
    case GEL
    case AMD
    case AZN
    case KZT
    case UZS
    case KGS
    case TJS
    case TMT
    case ISK
    
    // Additional Asian Currencies
    case AFN
    case BND
    case BTN
    case KHR
    case LAK
    case MMK
    case MNT
    case TWD
    case FJD
    case PGK
    case SBD
    case TOP
    case VUV
    case WST
    
    var id: GlobalCurrencies { self }
    static func from(code: String) -> GlobalCurrencies? {
            return allCases.first { $0.code == code }
    }
    
    var symbol: String {
        switch self {
        case .USD: return "$"
        case .EUR: return "€"
        case .JPY: return "¥"
        case .GBP: return "£"
        case .AUD: return "A$"
        case .CAD: return "C$"
        case .CHF: return "CHF"
        case .CNY: return "¥"
        case .HKD: return "HK$"
        case .NZD: return "NZ$"
        case .SEK: return "kr"
        case .NOK: return "kr"
        case .DKK: return "kr"
        case .PLN: return "zł"
        case .CZK: return "Kč"
        case .HUF: return "Ft"
        case .RUB: return "₽"
        case .KRW: return "₩"
        case .SGD: return "S$"
        case .THB: return "฿"
        case .MYR: return "RM"
        case .IDR: return "Rp"
        case .PHP: return "₱"
        case .VND: return "₫"
        case .INR: return "₹"
        case .PKR: return "₨"
        case .BDT: return "৳"
        case .LKR: return "Rs"
        case .NPR: return "Rs"
        case .AED: return "د.إ"
        case .SAR: return "﷼"
        case .QAR: return "﷼"
        case .KWD: return "د.ك"
        case .BHD: return ".د.ب"
        case .OMR: return "﷼"
        case .JOD: return "د.ا"
        case .ILS: return "₪"
        case .TRY: return "₺"
        case .EGP: return "£"
        case .ZAR: return "R"
        case .NGN: return "₦"
        case .KES: return "Sh"
        case .GHS: return "₵"
        case .MAD: return "د.م."
        case .TND: return "د.ت"
        case .DZD: return "د.ج"
        case .MXN: return "$"
        case .BRL: return "R$"
        case .ARS: return "$"
        case .CLP: return "$"
        case .COP: return "$"
        case .PEN: return "S/"
        case .UYU: return "$"
        case .BOB: return "Bs."
        case .PYG: return "₲"
        case .VES: return "Bs.S"
        case .CRC: return "₡"
        case .GTQ: return "Q"
        case .HNL: return "L"
        case .NIO: return "C$"
        case .PAB: return "B/."
        case .DOP: return "RD$"
        case .JMD: return "J$"
        case .TTD: return "TT$"
        case .BBD: return "Bds$"
        case .XCD: return "$"
        case .RON: return "lei"
        case .BGN: return "лв"
        case .HRK: return "kn"
        case .RSD: return "дин"
        case .MKD: return "ден"
        case .BAM: return "КМ"
        case .ALL: return "L"
        case .MDL: return "L"
        case .UAH: return "₴"
        case .BYN: return "Br"
        case .GEL: return "₾"
        case .AMD: return "֏"
        case .AZN: return "₼"
        case .KZT: return "₸"
        case .UZS: return "лв"
        case .KGS: return "лв"
        case .TJS: return "ЅМ"
        case .TMT: return "m"
        case .ISK: return "kr"
        case .AFN: return "؋"
        case .BND: return "B$"
        case .BTN: return "Nu."
        case .KHR: return "៛"
        case .LAK: return "₭"
        case .MMK: return "Ks"
        case .MNT: return "₮"
        case .TWD: return "NT$"
        case .FJD: return "FJ$"
        case .PGK: return "K"
        case .SBD: return "SI$"
        case .TOP: return "T$"
        case .VUV: return "Vt"
        case .WST: return "WS$"
        }
    }
    
    var code: String {
        switch self {
        case .USD: return "USD"
        case .EUR: return "EUR"
        case .JPY: return "JPY"
        case .GBP: return "GBP"
        case .AUD: return "AUD"
        case .CAD: return "CAD"
        case .CHF: return "CHF"
        case .CNY: return "CNY"
        case .HKD: return "HKD"
        case .NZD: return "NZD"
        case .SEK: return "SEK"
        case .NOK: return "NOK"
        case .DKK: return "DKK"
        case .PLN: return "PLN"
        case .CZK: return "CZK"
        case .HUF: return "HUF"
        case .RUB: return "RUB"
        case .KRW: return "KRW"
        case .SGD: return "SGD"
        case .THB: return "THB"
        case .MYR: return "MYR"
        case .IDR: return "IDR"
        case .PHP: return "PHP"
        case .VND: return "VND"
        case .INR: return "INR"
        case .PKR: return "PKR"
        case .BDT: return "BDT"
        case .LKR: return "LKR"
        case .NPR: return "NPR"
        case .AED: return "AED"
        case .SAR: return "SAR"
        case .QAR: return "QAR"
        case .KWD: return "KWD"
        case .BHD: return "BHD"
        case .OMR: return "OMR"
        case .JOD: return "JOD"
        case .ILS: return "ILS"
        case .TRY: return "TRY"
        case .EGP: return "EGP"
        case .ZAR: return "ZAR"
        case .NGN: return "NGN"
        case .KES: return "KES"
        case .GHS: return "GHS"
        case .MAD: return "MAD"
        case .TND: return "TND"
        case .DZD: return "DZD"
        case .MXN: return "MXN"
        case .BRL: return "BRL"
        case .ARS: return "ARS"
        case .CLP: return "CLP"
        case .COP: return "COP"
        case .PEN: return "PEN"
        case .UYU: return "UYU"
        case .BOB: return "BOB"
        case .PYG: return "PYG"
        case .VES: return "VES"
        case .CRC: return "CRC"
        case .GTQ: return "GTQ"
        case .HNL: return "HNL"
        case .NIO: return "NIO"
        case .PAB: return "PAB"
        case .DOP: return "DOP"
        case .JMD: return "JMD"
        case .TTD: return "TTD"
        case .BBD: return "BBD"
        case .XCD: return "XCD"
        case .RON: return "RON"
        case .BGN: return "BGN"
        case .HRK: return "HRK"
        case .RSD: return "RSD"
        case .MKD: return "MKD"
        case .BAM: return "BAM"
        case .ALL: return "ALL"
        case .MDL: return "MDL"
        case .UAH: return "UAH"
        case .BYN: return "BYN"
        case .GEL: return "GEL"
        case .AMD: return "AMD"
        case .AZN: return "AZN"
        case .KZT: return "KZT"
        case .UZS: return "UZS"
        case .KGS: return "KGS"
        case .TJS: return "TJS"
        case .TMT: return "TMT"
        case .ISK: return "ISK"
        case .AFN: return "AFN"
        case .BND: return "BND"
        case .BTN: return "BTN"
        case .KHR: return "KHR"
        case .LAK: return "LAK"
        case .MMK: return "MMK"
        case .MNT: return "MNT"
        case .TWD: return "TWD"
        case .FJD: return "FJD"
        case .PGK: return "PGK"
        case .SBD: return "SBD"
        case .TOP: return "TOP"
        case .VUV: return "VUV"
        case .WST: return "WST"
        }
    }
    
    var fullCurrencyName: String {
        switch self {
        case .USD: return "US Dollar"
        case .EUR: return "Euro"
        case .JPY: return "Japanese Yen"
        case .GBP: return "British Pound Sterling"
        case .AUD: return "Australian Dollar"
        case .CAD: return "Canadian Dollar"
        case .CHF: return "Swiss Franc"
        case .CNY: return "Chinese Yuan"
        case .HKD: return "Hong Kong Dollar"
        case .NZD: return "New Zealand Dollar"
        case .SEK: return "Swedish Krona"
        case .NOK: return "Norwegian Krone"
        case .DKK: return "Danish Krone"
        case .PLN: return "Polish Zloty"
        case .CZK: return "Czech Koruna"
        case .HUF: return "Hungarian Forint"
        case .RUB: return "Russian Ruble"
        case .KRW: return "South Korean Won"
        case .SGD: return "Singapore Dollar"
        case .THB: return "Thai Baht"
        case .MYR: return "Malaysian Ringgit"
        case .IDR: return "Indonesian Rupiah"
        case .PHP: return "Philippine Peso"
        case .VND: return "Vietnamese Dong"
        case .INR: return "Indian Rupee"
        case .PKR: return "Pakistani Rupee"
        case .BDT: return "Bangladeshi Taka"
        case .LKR: return "Sri Lankan Rupee"
        case .NPR: return "Nepalese Rupee"
        case .AED: return "UAE Dirham"
        case .SAR: return "Saudi Riyal"
        case .QAR: return "Qatari Riyal"
        case .KWD: return "Kuwaiti Dinar"
        case .BHD: return "Bahraini Dinar"
        case .OMR: return "Omani Rial"
        case .JOD: return "Jordanian Dinar"
        case .ILS: return "Israeli Shekel"
        case .TRY: return "Turkish Lira"
        case .EGP: return "Egyptian Pound"
        case .ZAR: return "South African Rand"
        case .NGN: return "Nigerian Naira"
        case .KES: return "Kenyan Shilling"
        case .GHS: return "Ghanaian Cedi"
        case .MAD: return "Moroccan Dirham"
        case .TND: return "Tunisian Dinar"
        case .DZD: return "Algerian Dinar"
        case .MXN: return "Mexican Peso"
        case .BRL: return "Brazilian Real"
        case .ARS: return "Argentine Peso"
        case .CLP: return "Chilean Peso"
        case .COP: return "Colombian Peso"
        case .PEN: return "Peruvian Sol"
        case .UYU: return "Uruguayan Peso"
        case .BOB: return "Bolivian Boliviano"
        case .PYG: return "Paraguayan Guarani"
        case .VES: return "Venezuelan Bolívar"
        case .CRC: return "Costa Rican Colón"
        case .GTQ: return "Guatemalan Quetzal"
        case .HNL: return "Honduran Lempira"
        case .NIO: return "Nicaraguan Córdoba"
        case .PAB: return "Panamanian Balboa"
        case .DOP: return "Dominican Peso"
        case .JMD: return "Jamaican Dollar"
        case .TTD: return "Trinidad and Tobago Dollar"
        case .BBD: return "Barbadian Dollar"
        case .XCD: return "East Caribbean Dollar"
        case .RON: return "Romanian Leu"
        case .BGN: return "Bulgarian Lev"
        case .HRK: return "Croatian Kuna"
        case .RSD: return "Serbian Dinar"
        case .MKD: return "Macedonian Denar"
        case .BAM: return "Bosnia and Herzegovina Convertible Mark"
        case .ALL: return "Albanian Lek"
        case .MDL: return "Moldovan Leu"
        case .UAH: return "Ukrainian Hryvnia"
        case .BYN: return "Belarusian Ruble"
        case .GEL: return "Georgian Lari"
        case .AMD: return "Armenian Dram"
        case .AZN: return "Azerbaijani Manat"
        case .KZT: return "Kazakhstani Tenge"
        case .UZS: return "Uzbekistani Som"
        case .KGS: return "Kyrgyzstani Som"
        case .TJS: return "Tajikistani Somoni"
        case .TMT: return "Turkmenistani Manat"
        case .ISK: return "Icelandic Krona"
        case .AFN: return "Afghan Afghani"
        case .BND: return "Brunei Dollar"
        case .BTN: return "Bhutanese Ngultrum"
        case .KHR: return "Cambodian Riel"
        case .LAK: return "Lao Kip"
        case .MMK: return "Myanmar Kyat"
        case .MNT: return "Mongolian Tugrik"
        case .TWD: return "Taiwan Dollar"
        case .FJD: return "Fijian Dollar"
        case .PGK: return "Papua New Guinea Kina"
        case .SBD: return "Solomon Islands Dollar"
        case .TOP: return "Tongan Pa'anga"
        case .VUV: return "Vanuatu Vatu"
        case .WST: return "Samoan Tala"
        }
    }
}
