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
enum GlobalCurrency: Int, CaseIterable, Equatable, Identifiable {

    case USD = 0
    case EUR
    case AED
    case AFN
    case ALL
    case AMD
    case ANG
    case AOA
    case ARS
    case AUD
    case AWG
    case AZN
    case BAM
    case BBD
    case BCH
    case BDT
    case BGN
    case BHD
    case BIF
    case BMD
    case BND
    case BOB
    case BRL
    case BSD
    case BTC
    case BTN
    case BWP
    case BYN
    case BZD
    case CAD
    case CDF
    case CHF
    case CLP
    case CNY
    case COP
    case CRC
    case CVE
    case CZK
    case DJF
    case DKK
    case DOP
    case DZD
    case EGP
    case ERN
    case ETB
    case ETC
    case ETH
    case FJD
    case FKP
    case GBP
    case GEL
    case GGP
    case GHS
    case GIP
    case GMD
    case GNF
    case GTQ
    case GYD
    case HKD
    case HNL
    case HRK
    case HTG
    case HUF
    case IDR
    case ILS
    case IMP
    case INR
    case IQD
    case IRR
    case ISK
    case JEP
    case JMD
    case JOD
    case JPY
    case KES
    case KGS
    case KHR
    case KMF
    case KRW
    case KWD
    case KYD
    case KZT
    case LAK
    case LBP
    case LKR
    case LRD
    case LSL
    case LTC
    case LTL
    case LYD
    case MAD
    case MDL
    case MGA
    case MKD
    case MMK
    case MNT
    case MOP
    case MRO
    case MTL
    case MUR
    case MVR
    case MWK
    case MXN
    case MYR
    case MZN
    case NAD
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
    case RWF
    case SAR
    case SBD
    case SCR
    case SDG
    case SEK
    case SGD
    case SHP
    case SOS
    case SRD
    case SVC
    case SZL
    case THB
    case TJS
    case TMT
    case TND
    case TOP
    case TRY
    case TTD
    case TWD
    case TZS
    case UAH
    case UGX
    case UYU
    case UZS
    case VES
    case VND
    case VUV
    case WST
    case XAF
    case XCD
    case XOF
    case XPF
    case YER
    case ZAR
    case ZMK
    case ZMW

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
        case .ANG: return "ƒ"
        case .AOA: return "Kz"
        case .ARS: return "$"
        case .AUD: return "A$"
        case .AWG: return "ƒ"
        case .AZN: return "₼"
        case .BAM: return "КМ"
        case .BBD: return "Bds$"
        case .BCH: return "BCH"
        case .BDT: return "৳"
        case .BGN: return "лв"
        case .BHD: return ".د.ب"
        case .BIF: return "Fr"
        case .BMD: return "$"
        case .BND: return "B$"
        case .BOB: return "Bs."
        case .BRL: return "R$"
        case .BSD: return "$"
        case .BTC: return "₿"
        case .BTN: return "Nu."
        case .BWP: return "P"
        case .BYN: return "Br"
        case .BZD: return "BZ$"
        case .CAD: return "C$"
        case .CDF: return "Fr"
        case .CHF: return "CHF"
        case .CLP: return "$"
        case .CNY: return "¥"
        case .COP: return "$"
        case .CRC: return "₡"
        case .CVE: return "$"
        case .CZK: return "Kč"
        case .DJF: return "Fr"
        case .DKK: return "kr"
        case .DOP: return "RD$"
        case .DZD: return "د.ج"
        case .EGP: return "£"
        case .ERN: return "Nfk"
        case .ETB: return "Br"
        case .ETC: return "Ξ"
        case .ETH: return "Ξ"
        case .FJD: return "FJ$"
        case .FKP: return "£"
        case .GBP: return "£"
        case .GEL: return "₾"
        case .GGP: return "£"
        case .GHS: return "₵"
        case .GIP: return "£"
        case .GMD: return "D"
        case .GNF: return "Fr"
        case .GTQ: return "Q"
        case .GYD: return "$"
        case .HKD: return "HK$"
        case .HNL: return "L"
        case .HRK: return "kn"
        case .HTG: return "G"
        case .HUF: return "Ft"
        case .IDR: return "Rp"
        case .ILS: return "₪"
        case .IMP: return "£"
        case .INR: return "₹"
        case .IQD: return "ع.د"
        case .IRR: return "﷼"
        case .ISK: return "kr"
        case .JEP: return "£"
        case .JMD: return "J$"
        case .JOD: return "د.ا"
        case .JPY: return "¥"
        case .KES: return "Sh"
        case .KGS: return "лв"
        case .KHR: return "៛"
        case .KMF: return "Fr"
        case .KRW: return "₩"
        case .KWD: return "د.ك"
        case .KYD: return "$"
        case .KZT: return "₸"
        case .LAK: return "₭"
        case .LBP: return "ل.ل"
        case .LKR: return "Rs"
        case .LRD: return "$"
        case .LSL: return "L"
        case .LTC: return "Ł"
        case .LTL: return "Lt"
        case .LYD: return "ل.د"
        case .MAD: return "د.م."
        case .MDL: return "L"
        case .MGA: return "Ar"
        case .MKD: return "ден"
        case .MMK: return "Ks"
        case .MNT: return "₮"
        case .MOP: return "P"
        case .MRO: return "UM"
        case .MTL: return "₤"
        case .MUR: return "Rs"
        case .MVR: return "Rf"
        case .MWK: return "MK"
        case .MXN: return "$"
        case .MYR: return "RM"
        case .MZN: return "MT"
        case .NAD: return "N$"
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
        case .RWF: return "Fr"
        case .SAR: return "﷼"
        case .SBD: return "SI$"
        case .SCR: return "Rs"
        case .SDG: return "£"
        case .SEK: return "kr"
        case .SGD: return "S$"
        case .SHP: return "£"
        case .SOS: return "Sh"
        case .SRD: return "$"
        case .SVC: return "₡"
        case .SZL: return "L"
        case .THB: return "฿"
        case .TJS: return "ЅМ"
        case .TMT: return "m"
        case .TND: return "د.ت"
        case .TOP: return "T$"
        case .TRY: return "₺"
        case .TTD: return "TT$"
        case .TWD: return "NT$"
        case .TZS: return "Sh"
        case .UAH: return "₴"
        case .UGX: return "Sh"
        case .UYU: return "$"
        case .UZS: return "лв"
        case .VES: return "Bs.S"
        case .VND: return "₫"
        case .VUV: return "Vt"
        case .WST: return "WS$"
        case .XAF: return "Fr"
        case .XCD: return "$"
        case .XOF: return "Fr"
        case .XPF: return "Fr"
        case .YER: return "﷼"
        case .ZAR: return "R"
        case .ZMK: return "ZK"
        case .ZMW: return "ZK"
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
        case .ANG: return "ANG"
        case .AOA: return "AOA"
        case .ARS: return "ARS"
        case .AUD: return "AUD"
        case .AWG: return "AWG"
        case .AZN: return "AZN"
        case .BAM: return "BAM"
        case .BBD: return "BBD"
        case .BCH: return "BCH"
        case .BDT: return "BDT"
        case .BGN: return "BGN"
        case .BHD: return "BHD"
        case .BIF: return "BIF"
        case .BMD: return "BMD"
        case .BND: return "BND"
        case .BOB: return "BOB"
        case .BRL: return "BRL"
        case .BSD: return "BSD"
        case .BTC: return "BTC"
        case .BTN: return "BTN"
        case .BWP: return "BWP"
        case .BYN: return "BYN"
        case .BZD: return "BZD"
        case .CAD: return "CAD"
        case .CDF: return "CDF"
        case .CHF: return "CHF"
        case .CLP: return "CLP"
        case .CNY: return "CNY"
        case .COP: return "COP"
        case .CRC: return "CRC"
        case .CVE: return "CVE"
        case .CZK: return "CZK"
        case .DJF: return "DJF"
        case .DKK: return "DKK"
        case .DOP: return "DOP"
        case .DZD: return "DZD"
        case .EGP: return "EGP"
        case .ERN: return "ERN"
        case .ETB: return "ETB"
        case .ETC: return "ETC"
        case .ETH: return "ETH"
        case .FJD: return "FJD"
        case .FKP: return "FKP"
        case .GBP: return "GBP"
        case .GEL: return "GEL"
        case .GGP: return "GGP"
        case .GHS: return "GHS"
        case .GIP: return "GIP"
        case .GMD: return "GMD"
        case .GNF: return "GNF"
        case .GTQ: return "GTQ"
        case .GYD: return "GYD"
        case .HKD: return "HKD"
        case .HNL: return "HNL"
        case .HRK: return "HRK"
        case .HTG: return "HTG"
        case .HUF: return "HUF"
        case .IDR: return "IDR"
        case .ILS: return "ILS"
        case .IMP: return "IMP"
        case .INR: return "INR"
        case .IQD: return "IQD"
        case .IRR: return "IRR"
        case .ISK: return "ISK"
        case .JEP: return "JEP"
        case .JMD: return "JMD"
        case .JOD: return "JOD"
        case .JPY: return "JPY"
        case .KES: return "KES"
        case .KGS: return "KGS"
        case .KHR: return "KHR"
        case .KMF: return "KMF"
        case .KRW: return "KRW"
        case .KWD: return "KWD"
        case .KYD: return "KYD"
        case .KZT: return "KZT"
        case .LAK: return "LAK"
        case .LBP: return "LBP"
        case .LKR: return "LKR"
        case .LRD: return "LRD"
        case .LSL: return "LSL"
        case .LTC: return "LTC"
        case .LTL: return "LTL"
        case .LYD: return "LYD"
        case .MAD: return "MAD"
        case .MDL: return "MDL"
        case .MGA: return "MGA"
        case .MKD: return "MKD"
        case .MMK: return "MMK"
        case .MNT: return "MNT"
        case .MOP: return "MOP"
        case .MRO: return "MRO"
        case .MTL: return "MTL"
        case .MUR: return "MUR"
        case .MVR: return "MVR"
        case .MWK: return "MWK"
        case .MXN: return "MXN"
        case .MYR: return "MYR"
        case .MZN: return "MZN"
        case .NAD: return "NAD"
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
        case .RWF: return "RWF"
        case .SAR: return "SAR"
        case .SBD: return "SBD"
        case .SCR: return "SCR"
        case .SDG: return "SDG"
        case .SEK: return "SEK"
        case .SGD: return "SGD"
        case .SHP: return "SHP"
        case .SOS: return "SOS"
        case .SRD: return "SRD"
        case .SVC: return "SVC"
        case .SZL: return "SZL"
        case .THB: return "THB"
        case .TJS: return "TJS"
        case .TMT: return "TMT"
        case .TND: return "TND"
        case .TOP: return "TOP"
        case .TRY: return "TRY"
        case .TTD: return "TTD"
        case .TWD: return "TWD"
        case .TZS: return "TZS"
        case .UAH: return "UAH"
        case .UGX: return "UGX"
        case .UYU: return "UYU"
        case .UZS: return "UZS"
        case .VES: return "VES"
        case .VND: return "VND"
        case .VUV: return "VUV"
        case .WST: return "WST"
        case .XAF: return "XAF"
        case .XCD: return "XCD"
        case .XOF: return "XOF"
        case .XPF: return "XPF"
        case .YER: return "YER"
        case .ZAR: return "ZAR"
        case .ZMK: return "ZMK"
        case .ZMW: return "ZMW"
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
        case .ANG: return "Netherlands Antillean Guilder"
        case .AOA: return "Angolan Kwanza"
        case .ARS: return "Argentine Peso"
        case .AUD: return "Australian Dollar"
        case .AWG: return "Aruban Florin"
        case .AZN: return "Azerbaijani Manat"
        case .BAM: return "Bosnia and Herzegovina Convertible Mark"
        case .BBD: return "Barbadian Dollar"
        case .BCH: return "Bitcoin Cash"
        case .BDT: return "Bangladeshi Taka"
        case .BGN: return "Bulgarian Lev"
        case .BHD: return "Bahraini Dinar"
        case .BIF: return "Burundian Franc"
        case .BMD: return "Bermudian Dollar"
        case .BND: return "Brunei Dollar"
        case .BOB: return "Bolivian Boliviano"
        case .BRL: return "Brazilian Real"
        case .BSD: return "Bahamian Dollar"
        case .BTC: return "Bitcoin"
        case .BTN: return "Bhutanese Ngultrum"
        case .BWP: return "Botswana Pula"
        case .BYN: return "Belarusian Ruble"
        case .BZD: return "Belize Dollar"
        case .CAD: return "Canadian Dollar"
        case .CDF: return "Congolese Franc"
        case .CHF: return "Swiss Franc"
        case .CLP: return "Chilean Peso"
        case .CNY: return "Chinese Yuan"
        case .COP: return "Colombian Peso"
        case .CRC: return "Costa Rican Colón"
        case .CVE: return "Cape Verdean Escudo"
        case .CZK: return "Czech Koruna"
        case .DJF: return "Djiboutian Franc"
        case .DKK: return "Danish Krone"
        case .DOP: return "Dominican Peso"
        case .DZD: return "Algerian Dinar"
        case .EGP: return "Egyptian Pound"
        case .ERN: return "Eritrean Nakfa"
        case .ETB: return "Ethiopian Birr"
        case .ETC: return "Ethereum Classic"
        case .ETH: return "Ethereum"
        case .FJD: return "Fijian Dollar"
        case .FKP: return "Falkland Islands Pound"
        case .GBP: return "British Pound Sterling"
        case .GEL: return "Georgian Lari"
        case .GGP: return "Guernsey Pound"
        case .GHS: return "Ghanaian Cedi"
        case .GIP: return "Gibraltar Pound"
        case .GMD: return "Gambian Dalasi"
        case .GNF: return "Guinean Franc"
        case .GTQ: return "Guatemalan Quetzal"
        case .GYD: return "Guyanese Dollar"
        case .HKD: return "Hong Kong Dollar"
        case .HNL: return "Honduran Lempira"
        case .HRK: return "Croatian Kuna"
        case .HTG: return "Haitian Gourde"
        case .HUF: return "Hungarian Forint"
        case .IDR: return "Indonesian Rupiah"
        case .ILS: return "Israeli Shekel"
        case .IMP: return "Isle of Man Pound"
        case .INR: return "Indian Rupee"
        case .IQD: return "Iraqi Dinar"
        case .IRR: return "Iranian Rial"
        case .ISK: return "Icelandic Krona"
        case .JEP: return "Jersey Pound"
        case .JMD: return "Jamaican Dollar"
        case .JOD: return "Jordanian Dinar"
        case .JPY: return "Japanese Yen"
        case .KES: return "Kenyan Shilling"
        case .KGS: return "Kyrgyzstani Som"
        case .KHR: return "Cambodian Riel"
        case .KMF: return "Comorian Franc"
        case .KRW: return "South Korean Won"
        case .KWD: return "Kuwaiti Dinar"
        case .KYD: return "Cayman Islands Dollar"
        case .KZT: return "Kazakhstani Tenge"
        case .LAK: return "Lao Kip"
        case .LBP: return "Lebanese Pound"
        case .LKR: return "Sri Lankan Rupee"
        case .LRD: return "Liberian Dollar"
        case .LSL: return "Lesotho Loti"
        case .LTC: return "Litecoin"
        case .LTL: return "Lithuanian Litas"
        case .LYD: return "Libyan Dinar"
        case .MAD: return "Moroccan Dirham"
        case .MDL: return "Moldovan Leu"
        case .MGA: return "Malagasy Ariary"
        case .MKD: return "Macedonian Denar"
        case .MMK: return "Myanmar Kyat"
        case .MNT: return "Mongolian Tugrik"
        case .MOP: return "Macanese Pataca"
        case .MRO: return "Mauritanian Ouguiya"
        case .MTL: return "Maltese Lira"
        case .MUR: return "Mauritian Rupee"
        case .MVR: return "Maldivian Rufiyaa"
        case .MWK: return "Malawian Kwacha"
        case .MXN: return "Mexican Peso"
        case .MYR: return "Malaysian Ringgit"
        case .MZN: return "Mozambican Metical"
        case .NAD: return "Namibian Dollar"
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
        case .RWF: return "Rwandan Franc"
        case .SAR: return "Saudi Riyal"
        case .SBD: return "Solomon Islands Dollar"
        case .SCR: return "Seychellois Rupee"
        case .SDG: return "Sudanese Pound"
        case .SEK: return "Swedish Krona"
        case .SGD: return "Singapore Dollar"
        case .SHP: return "Saint Helena Pound"
        case .SOS: return "Somali Shilling"
        case .SRD: return "Surinamese Dollar"
        case .SVC: return "Salvadoran Colón"
        case .SZL: return "Swazi Lilangeni"
        case .THB: return "Thai Baht"
        case .TJS: return "Tajikistani Somoni"
        case .TMT: return "Turkmenistani Manat"
        case .TND: return "Tunisian Dinar"
        case .TOP: return "Tongan Pa'anga"
        case .TRY: return "Turkish Lira"
        case .TTD: return "Trinidad and Tobago Dollar"
        case .TWD: return "Taiwan Dollar"
        case .TZS: return "Tanzanian Shilling"
        case .UAH: return "Ukrainian Hryvnia"
        case .UGX: return "Ugandan Shilling"
        case .UYU: return "Uruguayan Peso"
        case .UZS: return "Uzbekistani Som"
        case .VES: return "Venezuelan Bolívar"
        case .VND: return "Vietnamese Dong"
        case .VUV: return "Vanuatu Vatu"
        case .WST: return "Samoan Tala"
        case .XAF: return "CFA Franc BEAC"
        case .XCD: return "East Caribbean Dollar"
        case .XOF: return "CFA Franc BCEAO"
        case .XPF: return "CFP Franc"
        case .YER: return "Yemeni Rial"
        case .ZAR: return "South African Rand"
        case .ZMK: return "Zambian Kwacha (old)"
        case .ZMW: return "Zambian Kwacha"
        }
    }

    var countryFlag: String {
        switch self {
        case .USD: return "🇺🇸"
        case .EUR: return "🇪🇺"
        case .AED: return "🇦🇪"
        case .AFN: return "🇦🇫"
        case .ALL: return "🇦🇱"
        case .AMD: return "🇦🇲"
        case .ANG: return "🇨🇼"
        case .AOA: return "🇦🇴"
        case .ARS: return "🇦🇷"
        case .AUD: return "🇦🇺"
        case .AWG: return "🇦🇼"
        case .AZN: return "🇦🇿"
        case .BAM: return "🇧🇦"
        case .BBD: return "🇧🇧"
        case .BCH: return "₿"
        case .BDT: return "🇧🇩"
        case .BGN: return "🇧🇬"
        case .BHD: return "🇧🇭"
        case .BIF: return "🇧🇮"
        case .BMD: return "🇧🇲"
        case .BND: return "🇧🇳"
        case .BOB: return "🇧🇴"
        case .BRL: return "🇧🇷"
        case .BSD: return "🇧🇸"
        case .BTC: return "₿"
        case .BTN: return "🇧🇹"
        case .BWP: return "🇧🇼"
        case .BYN: return "🇧🇾"
        case .BZD: return "🇧🇿"
        case .CAD: return "🇨🇦"
        case .CDF: return "🇨🇩"
        case .CHF: return "🇨🇭"
        case .CLP: return "🇨🇱"
        case .CNY: return "🇨🇳"
        case .COP: return "🇨🇴"
        case .CRC: return "🇨🇷"
        case .CVE: return "🇨🇻"
        case .CZK: return "🇨🇿"
        case .DJF: return "🇩🇯"
        case .DKK: return "🇩🇰"
        case .DOP: return "🇩🇴"
        case .DZD: return "🇩🇿"
        case .EGP: return "🇪🇬"
        case .ERN: return "🇪🇷"
        case .ETB: return "🇪🇹"
        case .ETC: return "Ξ"
        case .ETH: return "Ξ"
        case .FJD: return "🇫🇯"
        case .FKP: return "🇫🇰"
        case .GBP: return "🇬🇧"
        case .GEL: return "🇬🇪"
        case .GGP: return "🇬🇬"
        case .GHS: return "🇬🇭"
        case .GIP: return "🇬🇮"
        case .GMD: return "🇬🇲"
        case .GNF: return "🇬🇳"
        case .GTQ: return "🇬🇹"
        case .GYD: return "🇬🇾"
        case .HKD: return "🇭🇰"
        case .HNL: return "🇭🇳"
        case .HRK: return "🇭🇷"
        case .HTG: return "🇭🇹"
        case .HUF: return "🇭🇺"
        case .IDR: return "🇮🇩"
        case .ILS: return "🇮🇱"
        case .IMP: return "🇮🇲"
        case .INR: return "🇮🇳"
        case .IQD: return "🇮🇶"
        case .IRR: return "🇮🇷"
        case .ISK: return "🇮🇸"
        case .JEP: return "🇯🇪"
        case .JMD: return "🇯🇲"
        case .JOD: return "🇯🇴"
        case .JPY: return "🇯🇵"
        case .KES: return "🇰🇪"
        case .KGS: return "🇰🇬"
        case .KHR: return "🇰🇭"
        case .KMF: return "🇰🇲"
        case .KRW: return "🇰🇷"
        case .KWD: return "🇰🇼"
        case .KYD: return "🇰🇾"
        case .KZT: return "🇰🇿"
        case .LAK: return "🇱🇦"
        case .LBP: return "🇱🇧"
        case .LKR: return "🇱🇰"
        case .LRD: return "🇱🇷"
        case .LSL: return "🇱🇸"
        case .LTC: return "Ł"
        case .LTL: return "🇱🇹"
        case .LYD: return "🇱🇾"
        case .MAD: return "🇲🇦"
        case .MDL: return "🇲🇩"
        case .MGA: return "🇲🇬"
        case .MKD: return "🇲🇰"
        case .MMK: return "🇲🇲"
        case .MNT: return "🇲🇳"
        case .MOP: return "🇲🇴"
        case .MRO: return "🇲🇷"
        case .MTL: return "🇲🇹"
        case .MUR: return "🇲🇺"
        case .MVR: return "🇲🇻"
        case .MWK: return "🇲🇼"
        case .MXN: return "🇲🇽"
        case .MYR: return "🇲🇾"
        case .MZN: return "🇲🇿"
        case .NAD: return "🇳🇦"
        case .NGN: return "🇳🇬"
        case .NIO: return "🇳🇮"
        case .NOK: return "🇳🇴"
        case .NPR: return "🇳🇵"
        case .NZD: return "🇳🇿"
        case .OMR: return "🇴🇲"
        case .PAB: return "🇵🇦"
        case .PEN: return "🇵🇪"
        case .PGK: return "🇵🇬"
        case .PHP: return "🇵🇭"
        case .PKR: return "🇵🇰"
        case .PLN: return "🇵🇱"
        case .PYG: return "🇵🇾"
        case .QAR: return "🇶🇦"
        case .RON: return "🇷🇴"
        case .RSD: return "🇷🇸"
        case .RUB: return "🇷🇺"
        case .RWF: return "🇷🇼"
        case .SAR: return "🇸🇦"
        case .SBD: return "🇸🇧"
        case .SCR: return "🇸🇨"
        case .SDG: return "🇸🇩"
        case .SEK: return "🇸🇪"
        case .SGD: return "🇸🇬"
        case .SHP: return "🇸🇭"
        case .SOS: return "🇸🇴"
        case .SRD: return "🇸🇷"
        case .SVC: return "🇸🇻"
        case .SZL: return "🇸🇿"
        case .THB: return "🇹🇭"
        case .TJS: return "🇹🇯"
        case .TMT: return "🇹🇲"
        case .TND: return "🇹🇳"
        case .TOP: return "🇹🇴"
        case .TRY: return "🇹🇷"
        case .TTD: return "🇹🇹"
        case .TWD: return "🇹🇼"
        case .TZS: return "🇹🇿"
        case .UAH: return "🇺🇦"
        case .UGX: return "🇺🇬"
        case .UYU: return "🇺🇾"
        case .UZS: return "🇺🇿"
        case .VES: return "🇻🇪"
        case .VND: return "🇻🇳"
        case .VUV: return "🇻🇺"
        case .WST: return "🇼🇸"
        case .XAF: return "🇨🇲"
        case .XCD: return "🇦🇬"
        case .XOF: return "🇸🇳"
        case .XPF: return "🇵🇫"
        case .YER: return "🇾🇪"
        case .ZAR: return "🇿🇦"
        case .ZMK: return "🇿🇲"
        case .ZMW: return "🇿🇲"
        }
    }
}
