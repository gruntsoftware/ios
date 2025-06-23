import BRCore
import Foundation

let BWAPIClientErrorDomain = "BRApiClientErrorDomain"

// these flags map to api feature flag name values
// eg "buy-bitcoin-with-cash" is a persistent name in the /me/features list
@objc public enum BRFeatureFlags: Int, CustomStringConvertible {
	case buyLitecoin

	public var description: String {
		switch self {
		case .buyLitecoin: return "buy-litecoin"
		}
	}
}

public typealias URLSessionTaskHandler = (Data?, HTTPURLResponse?, NSError?) -> Void
public typealias URLSessionChallengeHandler = (URLSession.AuthChallengeDisposition, URLCredential?) -> Void

// an object which implements BWAPIAdaptor can execute API Requests on the current wallet's behalf
public protocol BWAPIAdaptor {
	// execute an API request against the current wallet
	func dataTaskWithRequest(
		_ request: URLRequest, authenticated: Bool, retryCount: Int,
		handler: @escaping URLSessionTaskHandler
	) -> URLSessionDataTask

	func url(_ path: String, args: [String: String]?) -> URL
}

open class BWAPIClient: NSObject, URLSessionDelegate, URLSessionTaskDelegate, BWAPIAdaptor {
	private var authenticator: WalletAuthenticator

	// whether or not to emit log messages from this instance of the client
	private var logEnabled = true

	// proto is the transport protocol to use for talking to the API (either http or https)
	var proto = "https"

	// host is the server(s) on which the API is hosted
	var host = "api.grunt.ltd"

	// isFetchingAuth is set to true when a request is currently trying to renew authentication (the token)
	// it is useful because fetching auth is not idempotent and not reentrant, so at most one auth attempt
	// can take place at any one time
	private var isFetchingAuth = false

	// used when requests are waiting for authentication to be fetched
	private var authFetchGroup = DispatchGroup()

    private let configuration: URLSessionConfiguration = {
        #if targetEnvironment(simulator)
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 90 // Longer timeout for simulator
        configuration.timeoutIntervalForResource = 180
        configuration.waitsForConnectivity = true
        #else
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        configuration.timeoutIntervalForResource = 60
        configuration.waitsForConnectivity = true
        configuration.allowsCellularAccess = true
        configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
        #endif

        return configuration
    }()

	// the NSURLSession on which all NSURLSessionTasks are executed
	private
    lazy var session: URLSession = .init(configuration: configuration,
                                         delegate: self, delegateQueue: self.queue)

	// the queue on which the NSURLSession operates
	private var queue = OperationQueue()

	// convenience getter for the API endpoint
	private var baseUrl: String {
		return "\(proto)://\(host)"
	}

	init(authenticator: WalletAuthenticator) {
		self.authenticator = authenticator
	}

	// prints whatever you give it if logEnabled is true
	func log(_ string: String) {
		if !logEnabled {
			return
		}
	}

	var deviceId: String {
		return UserDefaults.standard.deviceID
	}

	var authKey: BRKey? {
		if authenticator.noWallet { return nil }
		guard let keyStr = authenticator.apiAuthKey else { return nil }
		var key = BRKey()
		key.compressed = 1
		if BRKeySetPrivKey(&key, keyStr) == 0 {
			// DEV: Comment out to get tBTC
			/// #if DEBUG
			///    fatalError("Unable to decode private key")
			/// #endif
		}
		return key
	}

	// MARK: Networking functions

	// Constructs a full NSURL for a given path and url parameters
	public func url(_ path: String, args: [String: String]? = nil) -> URL {
		func joinPath(_ k: String...) -> URL {
			return URL(string: ([baseUrl] + k).joined(separator: ""))!
		}

		if let args = args {
			return joinPath(path + "?" + args.map {
				"\($0.0.urlEscapedString)=\($0.1.urlEscapedString)"
			}.joined(separator: "&"))
		} else {
			return joinPath(path)
		}
	}

	private func signRequest(_ request: URLRequest) -> URLRequest {
		var mutableRequest = request
		let dateHeader = mutableRequest.allHTTPHeaderFields?.get(lowercasedKey: "date")
		if dateHeader == nil {
			// add Date header if necessary
			mutableRequest.setValue(Date().RFC1123String(), forHTTPHeaderField: "Date")
		}
		if let tokenData = authenticator.userAccount,
		   let token = tokenData["token"] as? String,
		   let authKey = authKey,
		   let signingData = mutableRequest.signingString.data(using: .utf8) {
			let sig = signingData.sha256_2.compactSign(key: authKey)
			let hval = "Brainwallet \(token):\(sig.base58)"
			mutableRequest.setValue(hval, forHTTPHeaderField: "Authorization")
		}
		return mutableRequest
	}

	private func decorateRequest(_ request: URLRequest) -> URLRequest {
		var actualRequest = request
        actualRequest.setValue("Brainwallet-iOS-\(AppVersion.string)".urlEscapedString, forHTTPHeaderField: "Mobile-Client")
		actualRequest.setValue(Locale.current.identifier, forHTTPHeaderField: "Accept-Language")
		return actualRequest
	}

	public func dataTaskWithRequest(_ request: URLRequest, authenticated: Bool = false,
	                                retryCount: Int = 0, handler: @escaping URLSessionTaskHandler) -> URLSessionDataTask {
		let start = Date()
		var logLine = ""
		if let meth = request.httpMethod, let u = request.url {
			logLine = "\(meth) \(u) auth=\(authenticated) retry=\(retryCount)"
		}

		// copy the request and authenticate it. retain the original request for retries
		var actualRequest = decorateRequest(request)
		if authenticated {
			actualRequest = signRequest(actualRequest)
		}
		return session.dataTask(with: actualRequest, completionHandler: { data, resp, err in
			DispatchQueue.main.async {
				let end = Date()
				let dur = Int(end.timeIntervalSince(start) * 1000)
				if let httpResp = resp as? HTTPURLResponse {
					var errStr = ""
					if httpResp.statusCode >= 400 {
						if let data = data, let s = String(data: data, encoding: .utf8) {
							errStr = s
						}
					}

					self.log("\(logLine) -> status=\(httpResp.statusCode) duration=\(dur)ms errStr=\(errStr)")
                    handler(data, httpResp, err as NSError?)

				} else {
					self.log("\(logLine) encountered connection error \(String(describing: err))")
					handler(data, nil, err as NSError?)
				}
			}
		})
	}

	// MARK: URLSession Delegate

	public func urlSession(_: URLSession, task _: URLSessionTask, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
		if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
			if challenge.protectionSpace.host == host, challenge.protectionSpace.serverTrust != nil {
				log("URLSession challenge accepted!")
				completionHandler(.useCredential,
				                  URLCredential(trust: challenge.protectionSpace.serverTrust!))
			} else {
				log("URLSession challenge rejected")
				completionHandler(.rejectProtectionSpace, nil)
			}
		}
	}

	public func urlSession(_: URLSession, task: URLSessionTask, willPerformHTTPRedirection _: HTTPURLResponse, newRequest request: URLRequest, completionHandler: @escaping (URLRequest?) -> Void) {
		var actualRequest = request
		if let currentReq = task.currentRequest, var curHost = currentReq.url?.host, let curScheme = currentReq.url?.scheme {
			if let curPort = currentReq.url?.port, curPort != 443, curPort != 80 {
				curHost = "\(curHost):\(curPort)"
			}
			if curHost == host, curScheme == proto {
				// follow the redirect if we're interacting with our API
				actualRequest = decorateRequest(request)
				log("redirecting \(String(describing: currentReq.url)) to \(String(describing: request.url))")
				if let curAuth = currentReq.allHTTPHeaderFields?["Authorization"], curAuth.hasPrefix("Brainwallet") {
					// add authentication because the previous request was authenticated
					log("adding authentication to redirected request")
					actualRequest = signRequest(actualRequest)
				}
				return completionHandler(actualRequest)
			}
		}
		completionHandler(nil)
	}
}

extension Dictionary where Key == String, Value == String {
	func get(lowercasedKey k: String) -> String? {
		let lcKey = k.lowercased()
		if let v = self[lcKey] {
			return v
		}
		for (lk, v) in self {
			if lk.lowercased() == lcKey {
				return v
			}
		}
		return nil
	}
}

private extension URLRequest {
	var signingString: String {
		var parts = [
			httpMethod ?? "",
			"",
			allHTTPHeaderFields?.get(lowercasedKey: "content-type") ?? "",
			allHTTPHeaderFields?.get(lowercasedKey: "date") ?? "",
			url?.resourceString ?? ""
		]
		if let meth = httpMethod {
			switch meth {
			case "POST", "PUT", "PATCH":
				if let d = httpBody, !d.isEmpty {
					parts[1] = d.sha256.base58
				}
			default: break
			}
		}
		return parts.joined(separator: "\n")
	}
}

private extension HTTPURLResponse {
	var isBreadChallenge: Bool {
		if let headers = allHeaderFields as? [String: String],
		   let challenge = headers.get(lowercasedKey: "www-authenticate") {
			if challenge.lowercased().hasPrefix("Brainwallet") {
				return true
			}
		}
		return false
	}
}

private extension URL {
	var resourceString: String {
		var urlStr = "\(path)"
		if let query = query {
			if query.lengthOfBytes(using: String.Encoding.utf8) > 0 {
				urlStr = "\(urlStr)?\(query)"
			}
		}
		return urlStr
	}
}
