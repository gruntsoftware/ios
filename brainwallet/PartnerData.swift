import Foundation
import UIKit

enum PartnerName {
	case walletOps
	case walletStart
    case agentPubKey
	case prodAF
}

struct Partner {
	let logo: UIImage
	let headerTitle: String
	let details: String

	/// Fills partner data
	/// - Returns: Array of Partner Data
	static func partnerDataArray() -> [Partner] {
		let moonpay = Partner(logo: UIImage(named: "moonpay-logo")!, headerTitle: "S.BuyCenter.Cells.moonpayTitle" , details: "S.BuyCenter.Cells.moonpayFinancialDetails")

		return [moonpay]
	}

	/// Returns Partner Key
	/// - Parameter name: Enum for the different partners
	/// - Returns: Key string
	static func partnerKeyPath(name: PartnerName) -> String {
		/// Switch the config file based on the environment
		var filePath: String

		// Loads the release Partner Keys config file.
		guard let releasePath = Bundle.main.path(forResource: "service-data",
		                                         ofType: "plist")
		else {
			let errorDescription = "service_data_missing"
			BWAnalytics.logEventWithParameters(itemName: ._20200112_ERR, properties: ["error": errorDescription])
			return "error: FILE-NOT-FOUND"
		}
		filePath = releasePath

		switch name {
		case .walletOps:
			if let dictionary = NSDictionary(contentsOfFile: filePath) as? [String: AnyObject],
			   let opsArray = dictionary["wallet-ops"] as? [String] {
				let randomInt = Int.random(in: 0 ..< opsArray.count)
				let key = opsArray[randomInt]
				return key
			} else {
				let errorDescription = "error_wallet_opskey"
				BWAnalytics.logEventWithParameters(itemName: ._20200112_ERR, properties: ["error": errorDescription])
				return errorDescription
			}

		case .walletStart:

			if let dictionary = NSDictionary(contentsOfFile: filePath) as? [String: AnyObject],
			   let key = dictionary["start-date"] as? String {
				return key
			} else {
				let errorDescription = "error_brainwallet_start_key"
				BWAnalytics.logEventWithParameters(itemName: ._20200112_ERR, properties: ["error": errorDescription])
				return errorDescription
			}
            
        case .agentPubKey:

            if let dictionary = NSDictionary(contentsOfFile: filePath) as? [String: AnyObject],
               let key = dictionary["agent-base64-pubkey"] as? String
            {
                return key
            } else {
                let errorDescription = "error_agent-base64-pubkey"
                LWAnalytics.logEventWithParameters(itemName: ._20200112_ERR, properties: ["error": errorDescription])
                return errorDescription
            }
            
		case .prodAF:

			if let dictionary = NSDictionary(contentsOfFile: filePath) as? [String: AnyObject],
			   let key = dictionary["af-prod-id"] as? String {
				return key
			} else {
				let errorDescription = "error_afprod_id_key"
				BWAnalytics.logEventWithParameters(itemName: ._20200112_ERR, properties: ["error": errorDescription])
				return errorDescription
			}
		}
	}

	static func walletOpsSet() -> Set<String> {
		// Loads the Partner Keys config file.
		var setOfAddresses = Set<String>()
		guard let releasePath = Bundle.main.path(forResource: "service-data",
		                                         ofType: "plist")

		else {
			let errorDescription = "service_data_missing"
			BWAnalytics.logEventWithParameters(itemName: ._20200112_ERR, properties: ["error": errorDescription])

			return [""]
		}

		if let dictionary = NSDictionary(contentsOfFile: releasePath) as? [String: AnyObject],
		   let opsArray = dictionary["wallet-ops"] as? [String] {
			setOfAddresses = Set(opsArray)
		}

		return setOfAddresses
	}
}
