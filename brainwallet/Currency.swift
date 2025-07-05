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

enum SupportedFiatCurrency: Int, CaseIterable, Equatable, Identifiable {
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

    static func from(code: String) -> SupportedFiatCurrency? {
            return allCases.first { $0.code == code }
    }

    var id: SupportedFiatCurrency { self }

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

enum GlobalCurrency: Int, CaseIterable, Equatable, Identifiable {

    case USD = 0
    case EUR
    case AED
    case AFN
    case ALL
    case AMD
    case ARS
    case AUD
    case AZN
    case BAM
    case BBD
    case BDT
    case BGN
    case BHD
    case BND
    case BOB
    case BRL
    case BTN
    case BYN
    case CAD
    case CHF
    case CLP
    case CNY
    case COP
    case CRC
    case CZK
    case DKK
    case DOP
    case DZD
    case EGP
    case FJD
    case GBP
    case GEL
    case GHS
    case GTQ
    case HKD
    case HNL
    case HRK
    case HUF
    case IDR
    case ILS
    case INR
    case ISK
    case JMD
    case JOD
    case JPY
    case KES
    case KGS
    case KHR
    case KRW
    case KWD
    case KZT
    case LAK
    case LKR
    case MAD
    case MDL
    case MKD
    case MMK
    case MNT
    case MXN
    case MYR
    case NGN
    case NIO
    case NOK
    case NPR
    case NZD
    case OMR
    case PAB
    case PEN
    case PGK
    case PHP
    case PKR
    case PLN
    case PYG
    case QAR
    case RON
    case RSD
    case RUB
    case SAR
    case SBD
    case SEK
    case SGD
    case THB
    case TJS
    case TMT
    case TND
    case TOP
    case TRY
    case TTD
    case TWD
    case UAH
    case UYU
    case UZS
    case VES
    case VND
    case VUV
    case WST
    case XCD
    case ZAR

    var id: GlobalCurrency { self }
    static func from(code: String) -> GlobalCurrency? {
            return allCases.first { $0.code == code }
    }

    var symbol: String {
            switch self {
            case .USD: return "$"
            case .EUR: return "€"
            case .AED: return "د.إ"
            case .AFN: return "؋"
            case .ALL: return "L"
            case .AMD: return "֏"
            case .ARS: return "$"
            case .AUD: return "A$"
            case .AZN: return "₼"
            case .BAM: return "КМ"
            case .BBD: return "Bds$"
            case .BDT: return "৳"
            case .BGN: return "лв"
            case .BHD: return ".د.ب"
            case .BND: return "B$"
            case .BOB: return "Bs."
            case .BRL: return "R$"
            case .BTN: return "Nu."
            case .BYN: return "Br"
            case .CAD: return "C$"
            case .CHF: return "CHF"
            case .CLP: return "$"
            case .CNY: return "¥"
            case .COP: return "$"
            case .CRC: return "₡"
            case .CZK: return "Kč"
            case .DKK: return "kr"
            case .DOP: return "RD$"
            case .DZD: return "د.ج"
            case .EGP: return "£"
            case .FJD: return "FJ$"
            case .GBP: return "£"
            case .GEL: return "₾"
            case .GHS: return "₵"
            case .GTQ: return "Q"
            case .HKD: return "HK$"
            case .HNL: return "L"
            case .HRK: return "kn"
            case .HUF: return "Ft"
            case .IDR: return "Rp"
            case .ILS: return "₪"
            case .INR: return "₹"
            case .ISK: return "kr"
            case .JMD: return "J$"
            case .JOD: return "د.ا"
            case .JPY: return "¥"
            case .KES: return "Sh"
            case .KGS: return "лв"
            case .KHR: return "៛"
            case .KRW: return "₩"
            case .KWD: return "د.ك"
            case .KZT: return "₸"
            case .LAK: return "₭"
            case .LKR: return "Rs"
            case .MAD: return "د.م."
            case .MDL: return "L"
            case .MKD: return "ден"
            case .MMK: return "Ks"
            case .MNT: return "₮"
            case .MXN: return "$"
            case .MYR: return "RM"
            case .NGN: return "₦"
            case .NIO: return "C$"
            case .NOK: return "kr"
            case .NPR: return "Rs"
            case .NZD: return "NZ$"
            case .OMR: return "﷼"
            case .PAB: return "B/."
            case .PEN: return "S/"
            case .PGK: return "K"
            case .PHP: return "₱"
            case .PKR: return "₨"
            case .PLN: return "zł"
            case .PYG: return "₲"
            case .QAR: return "﷼"
            case .RON: return "lei"
            case .RSD: return "дин"
            case .RUB: return "₽"
            case .SAR: return "﷼"
            case .SBD: return "SI$"
            case .SEK: return "kr"
            case .SGD: return "S$"
            case .THB: return "฿"
            case .TJS: return "ЅМ"
            case .TMT: return "m"
            case .TND: return "د.ت"
            case .TOP: return "T$"
            case .TRY: return "₺"
            case .TTD: return "TT$"
            case .TWD: return "NT$"
            case .UAH: return "₴"
            case .UYU: return "$"
            case .UZS: return "лв"
            case .VES: return "Bs.S"
            case .VND: return "₫"
            case .VUV: return "Vt"
            case .WST: return "WS$"
            case .XCD: return "$"
            case .ZAR: return "R"
            }
        }

    var code: String {
            switch self {
            case .USD: return "USD"
            case .EUR: return "EUR"
            case .AED: return "AED"
            case .AFN: return "AFN"
            case .ALL: return "ALL"
            case .AMD: return "AMD"
            case .ARS: return "ARS"
            case .AUD: return "AUD"
            case .AZN: return "AZN"
            case .BAM: return "BAM"
            case .BBD: return "BBD"
            case .BDT: return "BDT"
            case .BGN: return "BGN"
            case .BHD: return "BHD"
            case .BND: return "BND"
            case .BOB: return "BOB"
            case .BRL: return "BRL"
            case .BTN: return "BTN"
            case .BYN: return "BYN"
            case .CAD: return "CAD"
            case .CHF: return "CHF"
            case .CLP: return "CLP"
            case .CNY: return "CNY"
            case .COP: return "COP"
            case .CRC: return "CRC"
            case .CZK: return "CZK"
            case .DKK: return "DKK"
            case .DOP: return "DOP"
            case .DZD: return "DZD"
            case .EGP: return "EGP"
            case .FJD: return "FJD"
            case .GBP: return "GBP"
            case .GEL: return "GEL"
            case .GHS: return "GHS"
            case .GTQ: return "GTQ"
            case .HKD: return "HKD"
            case .HNL: return "HNL"
            case .HRK: return "HRK"
            case .HUF: return "HUF"
            case .IDR: return "IDR"
            case .ILS: return "ILS"
            case .INR: return "INR"
            case .ISK: return "ISK"
            case .JMD: return "JMD"
            case .JOD: return "JOD"
            case .JPY: return "JPY"
            case .KES: return "KES"
            case .KGS: return "KGS"
            case .KHR: return "KHR"
            case .KRW: return "KRW"
            case .KWD: return "KWD"
            case .KZT: return "KZT"
            case .LAK: return "LAK"
            case .LKR: return "LKR"
            case .MAD: return "MAD"
            case .MDL: return "MDL"
            case .MKD: return "MKD"
            case .MMK: return "MMK"
            case .MNT: return "MNT"
            case .MXN: return "MXN"
            case .MYR: return "MYR"
            case .NGN: return "NGN"
            case .NIO: return "NIO"
            case .NOK: return "NOK"
            case .NPR: return "NPR"
            case .NZD: return "NZD"
            case .OMR: return "OMR"
            case .PAB: return "PAB"
            case .PEN: return "PEN"
            case .PGK: return "PGK"
            case .PHP: return "PHP"
            case .PKR: return "PKR"
            case .PLN: return "PLN"
            case .PYG: return "PYG"
            case .QAR: return "QAR"
            case .RON: return "RON"
            case .RSD: return "RSD"
            case .RUB: return "RUB"
            case .SAR: return "SAR"
            case .SBD: return "SBD"
            case .SEK: return "SEK"
            case .SGD: return "SGD"
            case .THB: return "THB"
            case .TJS: return "TJS"
            case .TMT: return "TMT"
            case .TND: return "TND"
            case .TOP: return "TOP"
            case .TRY: return "TRY"
            case .TTD: return "TTD"
            case .TWD: return "TWD"
            case .UAH: return "UAH"
            case .UYU: return "UYU"
            case .UZS: return "UZS"
            case .VES: return "VES"
            case .VND: return "VND"
            case .VUV: return "VUV"
            case .WST: return "WST"
            case .XCD: return "XCD"
            case .ZAR: return "ZAR"
            }
        }

    var fullCurrencyName: String {
            switch self {
            case .USD: return "US Dollar"
            case .EUR: return "Euro"
            case .AED: return "UAE Dirham"
            case .AFN: return "Afghan Afghani"
            case .ALL: return "Albanian Lek"
            case .AMD: return "Armenian Dram"
            case .ARS: return "Argentine Peso"
            case .AUD: return "Australian Dollar"
            case .AZN: return "Azerbaijani Manat"
            case .BAM: return "Bosnia and Herzegovina Convertible Mark"
            case .BBD: return "Barbadian Dollar"
            case .BDT: return "Bangladeshi Taka"
            case .BGN: return "Bulgarian Lev"
            case .BHD: return "Bahraini Dinar"
            case .BND: return "Brunei Dollar"
            case .BOB: return "Bolivian Boliviano"
            case .BRL: return "Brazilian Real"
            case .BTN: return "Bhutanese Ngultrum"
            case .BYN: return "Belarusian Ruble"
            case .CAD: return "Canadian Dollar"
            case .CHF: return "Swiss Franc"
            case .CLP: return "Chilean Peso"
            case .CNY: return "Chinese Yuan"
            case .COP: return "Colombian Peso"
            case .CRC: return "Costa Rican Colón"
            case .CZK: return "Czech Koruna"
            case .DKK: return "Danish Krone"
            case .DOP: return "Dominican Peso"
            case .DZD: return "Algerian Dinar"
            case .EGP: return "Egyptian Pound"
            case .FJD: return "Fijian Dollar"
            case .GBP: return "British Pound Sterling"
            case .GEL: return "Georgian Lari"
            case .GHS: return "Ghanaian Cedi"
            case .GTQ: return "Guatemalan Quetzal"
            case .HKD: return "Hong Kong Dollar"
            case .HNL: return "Honduran Lempira"
            case .HRK: return "Croatian Kuna"
            case .HUF: return "Hungarian Forint"
            case .IDR: return "Indonesian Rupiah"
            case .ILS: return "Israeli Shekel"
            case .INR: return "Indian Rupee"
            case .ISK: return "Icelandic Krona"
            case .JMD: return "Jamaican Dollar"
            case .JOD: return "Jordanian Dinar"
            case .JPY: return "Japanese Yen"
            case .KES: return "Kenyan Shilling"
            case .KGS: return "Kyrgyzstani Som"
            case .KHR: return "Cambodian Riel"
            case .KRW: return "South Korean Won"
            case .KWD: return "Kuwaiti Dinar"
            case .KZT: return "Kazakhstani Tenge"
            case .LAK: return "Lao Kip"
            case .LKR: return "Sri Lankan Rupee"
            case .MAD: return "Moroccan Dirham"
            case .MDL: return "Moldovan Leu"
            case .MKD: return "Macedonian Denar"
            case .MMK: return "Myanmar Kyat"
            case .MNT: return "Mongolian Tugrik"
            case .MXN: return "Mexican Peso"
            case .MYR: return "Malaysian Ringgit"
            case .NGN: return "Nigerian Naira"
            case .NIO: return "Nicaraguan Córdoba"
            case .NOK: return "Norwegian Krone"
            case .NPR: return "Nepalese Rupee"
            case .NZD: return "New Zealand Dollar"
            case .OMR: return "Omani Rial"
            case .PAB: return "Panamanian Balboa"
            case .PEN: return "Peruvian Sol"
            case .PGK: return "Papua New Guinea Kina"
            case .PHP: return "Philippine Peso"
            case .PKR: return "Pakistani Rupee"
            case .PLN: return "Polish Zloty"
            case .PYG: return "Paraguayan Guarani"
            case .QAR: return "Qatari Riyal"
            case .RON: return "Romanian Leu"
            case .RSD: return "Serbian Dinar"
            case .RUB: return "Russian Ruble"
            case .SAR: return "Saudi Riyal"
            case .SBD: return "Solomon Islands Dollar"
            case .SEK: return "Swedish Krona"
            case .SGD: return "Singapore Dollar"
            case .THB: return "Thai Baht"
            case .TJS: return "Tajikistani Somoni"
            case .TMT: return "Turkmenistani Manat"
            case .TND: return "Tunisian Dinar"
            case .TOP: return "Tongan Pa'anga"
            case .TRY: return "Turkish Lira"
            case .TTD: return "Trinidad and Tobago Dollar"
            case .TWD: return "Taiwan Dollar"
            case .UAH: return "Ukrainian Hryvnia"
            case .UYU: return "Uruguayan Peso"
            case .UZS: return "Uzbekistani Som"
            case .VES: return "Venezuelan Bolívar"
            case .VND: return "Vietnamese Dong"
            case .VUV: return "Vanuatu Vatu"
            case .WST: return "Samoan Tala"
            case .XCD: return "East Caribbean Dollar"
            case .ZAR: return "South African Rand"
            }
        }
}
