import Foundation

extension BRAPIClient {
	func feePerKb(_ handler: @escaping (_ fees: Fees, _ error: String?) -> Void) {
        
        guard let url = URL(string: APIServer.baseUrl + "v1/fee-per-kb") else {
            return
        }
        let request = URLRequest(url: url)
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
            return
        }
        
        let request = URLRequest(url: url)
         
		dataTaskWithRequest(request) { data, _, error in
			if error == nil, let data = data,
			   let parsedData = try? JSONSerialization.jsonObject(with: data, options: .allowFragments)
			{
                guard let array = parsedData as? [Any] else {
                    let properties = ["error_message": "rates_parsed_data_fail"]
                    LWAnalytics.logEventWithParameters(itemName: ._20200112_ERR, properties: properties)
                    return handler([], "/rates didn't return an array")
                }
                handler(array.compactMap { Rate(data: $0) }, nil)
			}
            else {
                let properties = ["error_message": "rates_parsed_data_fail"]
                LWAnalytics.logEventWithParameters(itemName: ._20200112_ERR, properties: properties)
                return handler([], "/rates didn't return an array")
			}
		}.resume()
	}
}
