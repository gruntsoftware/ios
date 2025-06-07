import Foundation

extension BWAPIClient {
	func feePerKb(_ handler: @escaping (_ fees: Fees, _ error: String?) -> Void) {
        
        guard let url = URL(string: APIServer.baseUrl + "v1/fee-per-kb") else {
            assertionFailure("APIServer call for fee-per-kb failed")
            return
        }
        var request = URLRequest(url: url)
        #if targetEnvironment(simulator)
            request.assumesHTTP3Capable = false
        #endif
		let task = dataTaskWithRequest(request) { _, _, _ in
			let staticFees = Fees.usingDefaultValues
			handler(staticFees, nil)
		}
		task.resume()
	}

	func exchangeRates( _ handler: @escaping (_ rates: [Rate], _ error: String?) -> Void) {
        
        guard let url = URL(string: APIServer.baseUrl + "v1/rates") else {
            let properties = ["error_message": "rates_url_failed"]
            LWAnalytics.logEventWithParameters(itemName: ._20200112_ERR, properties: properties)
            debugPrint("::: ERROR: rates_url_failed")
            return
        }
        
        var request = URLRequest(url: url)
        #if targetEnvironment(simulator)
            request.assumesHTTP3Capable = false
        #endif
		dataTaskWithRequest(request) { data, _, error in
			if error == nil, let data = data,
			   let parsedData = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
			{
                guard let array = parsedData as? [Any] else {
                    let properties = ["error_message": "rates_parsed_data_fail"]
                    LWAnalytics.logEventWithParameters(itemName: ._20200112_ERR, properties: properties)
                    debugPrint("::: ERROR: rates_parsed_data_fail")
                    return handler([], "/rates didn't return an array")
                }
                handler(array.compactMap { Rate(data: $0) }, nil)
			}
            else {
                let properties = ["error_message": "rates_parsed_data_fail"]
                LWAnalytics.logEventWithParameters(itemName: ._20200112_ERR, properties: properties)
                debugPrint("::: ERROR: else rates_parsed_data_fail")
                return handler([], "/rates didn't return an array")
			}
		}.resume()
	}
}
