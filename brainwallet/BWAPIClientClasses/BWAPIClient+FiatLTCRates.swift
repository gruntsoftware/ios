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
        
        guard let urlObject = URL(string: APIServer.baseUrl + "v1/rates") else {
            let properties = ["error_message": "rates_url_failed"]
            BWAnalytics.logEventWithParameters(itemName: ._20200112_ERR, properties: properties)
            debugPrint("::: ERROR: rates_url_failed")
            return
        }
        
        var request = URLRequest(url: urlObject)
        #if targetEnvironment(simulator)
            request.assumesHTTP3Capable = false
        #endif
        debugPrint(request.debugDescription)
        
		dataTaskWithRequest(request) { data, response, error in
            
            if let error = error as NSError? {
                if error.domain == NSURLErrorDomain {
                    switch error.code {
                    case NSURLErrorNetworkConnectionLost:
                        debugPrint("::: ERROR: Network connection lost - retry logic needed")
                        handler(self.performRequestWithRetry(urlObject: urlObject, maxRetries: 3) ?? [], nil)
                    case NSURLErrorNotConnectedToInternet:
                        debugPrint("::: ERROR: No internet connection")
                    case NSURLErrorTimedOut:
                        debugPrint("::: ERROR: Request timed out")
                    default:
                        debugPrint("::: ERROR: Network error: \(error.localizedDescription)")
                    }
                }
            } else if let data = data,
                let parsedData = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) {
                guard let array = parsedData as? [Any] else {
                    let properties = ["error_message": "rates_parsed_data_fail"]
                    BWAnalytics.logEventWithParameters(itemName: ._20200112_ERR, properties: properties)
                    debugPrint("::: ERROR: rates_parsed_data_fail")
                    return handler([], "/rates didn't return an array")
                }
                handler(array.compactMap { Rate(data: $0) }, nil)
			} else if let response = response {
                debugPrint("::: RESPONSE: \(String(describing: response))")
            } else {
                let properties = ["error_message": "rates_parsed_data_fail"]
            BWAnalytics.logEventWithParameters(itemName: ._20200112_ERR, properties: properties)
                debugPrint("::: ERROR: else rates_parsed_data_fail")
                return handler([], "/rates didn't return an array")
			}
		}.resume()
	}
    
    func performRequestWithRetry(urlObject: URL, maxRetries: Int = 3) -> [Rate]? {
        var retryCount = 0
        var rates: [Rate]?
        func attemptRequest() {
            URLSession.shared.dataTask(with: urlObject) { data, _, error in
                if let error = error as NSError?,
                   error.code == NSURLErrorNetworkConnectionLost,
                   retryCount < maxRetries {
                    retryCount += 1
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        attemptRequest()
                    }
                    return
                }
                if let data = data,
                   let parsedData = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) {
                    guard let array = parsedData as? [Any] else {
                        let properties = ["error_message": "rates_parsed_data_fail"]
                        BWAnalytics.logEventWithParameters(itemName: ._20200112_ERR, properties: properties)
                        debugPrint("::: ERROR: rates_parsed_data_fail")
                        return
                    }
                    rates = array.compactMap { Rate(data: $0) }
                }
            }.resume()
            attemptRequest()
        }
        return rates
    }
}
