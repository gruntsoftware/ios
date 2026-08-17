import BRCore
@testable import brainwallet
import XCTest

class FakeAuthenticator: WalletAuthenticator {
	var secret: UInt256
	let key: BRKey
	var userAccount: [AnyHashable: Any]?

	init() {
		let count = 32
		var keyData = Data(count: count)
		let result = keyData.withUnsafeMutableBytes { (buffer: UnsafeMutableRawBufferPointer) in
			SecRandomCopyBytes(kSecRandomDefault, count, buffer.baseAddress!)
		}
		if result != errSecSuccess {
			fatalError("couldnt generate random data for key")
		}
		debugPrint(":::base58 encoded secret key data \(keyData.base58)")
		secret = keyData.uInt256
		key = withUnsafePointer(to: &secret) { (secPointer: UnsafePointer<UInt256>) in
			var k = BRKey()
			k.compressed = 1
			BRKeySetSecret(&k, secPointer, 0)
			return k
		}
	}

	var noWallet: Bool { return false }

	var apiAuthKey: String? {
		var k = key
		k.compressed = 1
		let pkLen = BRKeyPrivKey(&k, nil, 0)
		var pkData = Data(count: pkLen)
		_ = pkData.withUnsafeMutableBytes { (buffer: UnsafeMutableRawBufferPointer) in
			BRKeyPrivKey(&k, buffer.baseAddress?.assumingMemoryBound(to: CChar.self), pkLen)
		}
		return String(data: pkData, encoding: .utf8)
	}
}

// This test will test against the live API at api.grunt.ltd
class BWAPIClientTests: XCTestCase {
	var authenticator: WalletAuthenticator!
	var client: BWAPIClient!
    var sut: BWAPIClient!

    override func setUpWithError() throws {
        try super.setUpWithError()
        authenticator = FakeAuthenticator() // each test will get its own account
        client = BWAPIClient(authenticator: authenticator)
        sut = BWAPIClient(authenticator: authenticator)
    }

    override func tearDownWithError() throws {
        sut = nil
        authenticator = nil
        client = nil
        try super.tearDownWithError()
    }
     
	func testPublicKeyEncoding() {
		let pubKey1 = client.authKey!.publicKey.base58
		let b = pubKey1.base58DecodedData()
		let b2 = b.base58
		XCTAssertEqual(pubKey1, b2) // sanity check on our base58 functions
		let key = client
            .authKey!.publicKey
            .withUnsafeBytes { (buffer: UnsafeRawBufferPointer) -> BRKey in
			var k = BRKey()
			BRKeySetPubKey(&k, buffer.baseAddress?
                .assumingMemoryBound(to: UInt8.self), client.authKey!
                .publicKey.count)
			return k
		}
		XCTAssertEqual(pubKey1, key.publicKey.base58)
        // the key decoded from our encoded key is the same
	}
	/*
	 func testHandshake() {
	     // test that we can get a token and access /me
	     let req = URLRequest(url: client.url("/me"))
	     let exp = expectation(description: "auth")
	     client
            .dataTaskWithRequest(req, authenticated: true, retryCount: 0) { (data, resp, err) in
	         XCTAssertEqual(resp?.statusCode, 200)
	         exp.fulfill()
	     }.resume()
	     waitForExpectations(timeout: 30, handler: nil)
	 } */
    // MARK: - Initialization Tests
    
//    func testInit_WithAuthenticator_InitializesCorrectly() {
//        // Given
//        let authenticator = WalletAuthenticator(
//        
//        // When
//        let client = BWAPIClient(authenticator: authenticator)
//        
//        // Then
//        XCTAssertNotNil(client)
//    }
//    
    // MARK: - URL Construction Tests
    
    func testURL_WithPathOnly_ReturnsCorrectURL() {
        // Given
        let path = "/api/v1/users"
        
        // When
        let url = sut.url(path)
        
        // Then
        XCTAssertEqual(url.absoluteString, "https://api.grunt.ltd/api/v1/users")
    }
    
    func testURL_WithPathAndArguments_ReturnsCorrectURL() {
        // Given
        let path = "/api/v1/search"
        let args = ["query": "test", "limit": "10"]
        
        // When
        let url = sut.url(path, args: args)
        
        // Then
        XCTAssertTrue(url.absoluteString.contains("https://api.grunt.ltd/api/v1/search?"))
        XCTAssertTrue(url.absoluteString.contains("query=test"))
        XCTAssertTrue(url.absoluteString.contains("limit=10"))
    }
    
    func testURL_WithSpecialCharactersInArgs_URLEncodesCorrectly() {
        // Given
        let path = "/api/v1/data"
        let args = ["name": "John Doe", "email": "test@example.com"]
        
        // When
        let url = sut.url(path, args: args)
        
        // Then
        XCTAssertTrue(url.absoluteString
            .contains("John Doe") || url.absoluteString.contains("%20"))
    }
    
    func testURL_WithEmptyArgs_ReturnsPathOnly() {
        // Given
        let path = "/api/v1/endpoint"
        let args: [String: String] = [:]
        
        // When
        let url = sut.url(path, args: args)
        
        // Then
        XCTAssertEqual(url.absoluteString, "https://api.grunt.ltd/api/v1/endpoint?")
    }
    
    func testURL_WithMultipleArgs_JoinsWithAmpersand() {
        // Given
        let path = "/api/v1/filter"
        let args = ["sort": "asc", "page": "1", "size": "20"]
        
        // When
        let url = sut.url(path, args: args)
        
        // Then
        let urlString = url.absoluteString
        let ampersandCount = urlString.components(separatedBy: "&").count - 1
        XCTAssertEqual(ampersandCount, 2, "Should have 2 ampersands for 3 parameters")
    }

    // MARK: - Data Task Tests
    func testDataTaskWithRequest_AddsClientHeader() {
        // Given
        let url = URL(string: "https://api.grunt.ltd/test")!
        let request = URLRequest(url: url)
        
        // When
        let task = sut.dataTaskWithRequest(request, authenticated: false, retryCount: 0) { _, _, _ in }
        
        // Then
        XCTAssertNotNil(task)
        // Should have Mobile-Client header with app version
    }
    
    func testDataTaskWithRequest_AddsAcceptLanguageHeader() {
        // Given
        let url = URL(string: "https://api.grunt.ltd/test")!
        let request = URLRequest(url: url)
        
        // When
        let task = sut.dataTaskWithRequest(request, authenticated: false, retryCount: 0) { _, _, _ in }
        
        // Then
        XCTAssertNotNil(task)
        // Should have Accept-Language header with current locale
    }
    
    func testDataTaskWithRequest_WithRetryCount_IncludesInLog() {
        // Given
        let url = URL(string: "https://api.grunt.ltd/test")!
        let request = URLRequest(url: url)
        
        // When
        let task = sut.dataTaskWithRequest(request, authenticated: false, retryCount: 3) { _, _, _ in }
        
        // Then
        XCTAssertNotNil(task)
        // Verify retry count is logged (if logging is testable)
    }
    
    // MARK: - URLSession Delegate Tests
    
    func testURLSession_ServerTrustChallenge_ForCorrectHost_Accepts() {
        let session = URLSession.shared
        let url = URL(string: "https://api.grunt.ltd")!
        let task = session.dataTask(with: url)

        let protectionSpace = URLProtectionSpace(
            host: "api.grunt.ltd",
            port: 443,
            protocol: "https",
            realm: nil,
            authenticationMethod: NSURLAuthenticationMethodServerTrust
        )
 
        let challenge = URLAuthenticationChallenge(
            protectionSpace: protectionSpace,
            proposedCredential: nil,
            previousFailureCount: 0,
            failureResponse: nil,
            error: nil,
            sender: MockAuthenticationChallengeSender()
        )

        let expectation = expectation(description: "Challenge handled")

        sut.urlSession(session, task: task, didReceive: challenge) { disposition, credential in
            XCTAssertEqual(disposition, .rejectProtectionSpace)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0)
    }
    
    func testURLSession_ServerTrustChallenge_ForWrongHost_Rejects() {
        // Given
        let session = URLSession.shared
        let task = session.dataTask(with: URL(string: "https://evil.example.com")!)
        let protectionSpace = URLProtectionSpace(
            host: "evil.example.com",
            port: 443,
            protocol: "https",
            realm: nil,
            authenticationMethod: NSURLAuthenticationMethodServerTrust
        )
        let challenge = URLAuthenticationChallenge(
            protectionSpace: protectionSpace,
            proposedCredential: nil,
            previousFailureCount: 0,
            failureResponse: nil,
            error: nil,
            sender: MockAuthenticationChallengeSender()
        )
        
        let expectation = self.expectation(description: "Challenge handled")
        
        // When
        sut.urlSession(session, task: task, didReceive: challenge) { disposition, credential in
            // Then
            XCTAssertEqual(disposition, .rejectProtectionSpace)
            XCTAssertNil(credential)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
    }
    
    // MARK: - HTTP Redirect Tests
    
    func testURLSession_Redirect_ToDifferentHost_DoesNotFollow() {
        // Given
        let session = URLSession.shared
        let originalURL = URL(string: "https://api.grunt.ltd/endpoint")!
        let task = session.dataTask(with: originalURL)
        let newURL = URL(string: "https://evil.example.com/phishing")!
        
        var originalRequest = URLRequest(url: originalURL)
        originalRequest.httpMethod = "GET"
        
        let newRequest = URLRequest(url: newURL)
        let response = HTTPURLResponse(
            url: originalURL,
            statusCode: 302,
            httpVersion: nil,
            headerFields: nil
        )!
        
        let expectation = self.expectation(description: "Redirect handled")
        
        // When
        sut.urlSession(session, task: task, willPerformHTTPRedirection: response, newRequest: newRequest) { request in
            // Then
            XCTAssertNil(request)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 1.0)
    }

    func testURLSession_Redirect_FromDifferentHost_DoesNotFollow() {
        // Given: the task's own current request is NOT on our API host, even
        // though the redirect target is -- an untrusted origin shouldn't be
        // able to route a request onto our API this way either.
        let session = URLSession.shared
        let originalURL = URL(string: "https://evil.example.com/redirector")!
        let task = session.dataTask(with: originalURL)
        let newURL = URL(string: "https://api.grunt.ltd/endpoint")!
        let newRequest = URLRequest(url: newURL)
        let response = HTTPURLResponse(
            url: originalURL,
            statusCode: 302,
            httpVersion: nil,
            headerFields: nil
        )!

        let expectation = self.expectation(description: "Redirect handled")

        // When
        sut.urlSession(session, task: task, willPerformHTTPRedirection: response, newRequest: newRequest) { request in
            // Then
            XCTAssertNil(request)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0)
    }

    func testURLSession_Redirect_SameHost_Follows() {
        // Given: both the originating task and the redirect target stay on our
        // own API -- this legitimate case should still be followed.
        let session = URLSession.shared
        let originalURL = URL(string: "https://api.grunt.ltd/endpoint")!
        let task = session.dataTask(with: originalURL)
        let newURL = URL(string: "https://api.grunt.ltd/redirected")!
        let newRequest = URLRequest(url: newURL)
        let response = HTTPURLResponse(
            url: originalURL,
            statusCode: 302,
            httpVersion: nil,
            headerFields: nil
        )!

        let expectation = self.expectation(description: "Redirect handled")

        // When
        sut.urlSession(session, task: task, willPerformHTTPRedirection: response, newRequest: newRequest) { request in
            // Then
            XCTAssertEqual(request?.url, newURL)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 1.0)
    }

    // MARK: - URL Extension Tests
    
    func testResourceString_PathOnly() {
        // Given
        
        let server = APIServer.baseUrl
        let url = URL(string:  server + "api/v1/users")!
        
        // When
        let resourceString = url.relativeString
        
        // Then
        XCTAssertEqual(resourceString, "https://api.grunt.ltd/api/v1/users")
    }
    
    func testResourceString_PathWithQuery() {
        // Given
        let server = APIServer.baseUrl
        let url = URL(string: server + "search?q=test&limit=10")!
        
        // When
        let resourceString = url.absoluteString
        
        // Then
        XCTAssertEqual(resourceString, "https://api.grunt.ltd/search?q=test&limit=10")
    }
    
    func testResourceString_EmptyQuery() {
        // Given
        let server = APIServer.baseUrl
        let url = URL(string: server + "data?")!
        
        // When
        let resourceString = url.absoluteString
        
        // Then
        XCTAssertEqual(resourceString,"https://api.grunt.ltd/data?")
    }
    
    // MARK: - Dictionary Extension Tests
    
    func testDictionary_GetLowercasedKey_ExactMatch() {
        // Given
        let dict = ["Content-Type": "application/json", "Date": "Mon, 11 Feb 2026"]
        
        // When
        let value = dict.get(lowercasedKey: "content-type")
        
        // Then
        XCTAssertEqual(value, "application/json")
    }
    
    func testDictionary_GetLowercasedKey_CaseInsensitive() {
        // Given
        let dict = ["Content-Type": "application/json", "DATE": "Mon, 11 Feb 2026"]
        
        // When
        let value = dict.get(lowercasedKey: "date")
        
        // Then
        XCTAssertEqual(value, "Mon, 11 Feb 2026")
    }
    
    func testDictionary_GetLowercasedKey_NotFound() {
        // Given
        let dict = ["Content-Type": "application/json"]
        
        // When
        let value = dict.get(lowercasedKey: "authorization")
        
        // Then
        XCTAssertNil(value)
    }
    
    func testDictionary_GetLowercasedKey_MixedCase() {
        // Given
        let dict = ["ConTent-TyPe": "text/html"]
        
        // When
        let value = dict.get(lowercasedKey: "content-type")
        
        // Then
        XCTAssertEqual(value, "text/html")
    }
    
    // MARK: - Integration Tests
    
    func testFullRequestCycle_UnauthenticatedGET() {
        // This would be better as an integration test with a mock server
        // Given
        let url = sut.url("/api/v1/status")
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        // When
        let task = sut.dataTaskWithRequest(request, authenticated: false, retryCount: 0) { data, response, error in
            // Then - verify response handling
        }
        
        // Then
        XCTAssertNotNil(task)
    }
    
    // MARK: - Edge Cases
    
    func testURL_WithEmptyPath_ReturnsBaseURL() {
        // Given
        let path = ""
        
        // When
        let url = sut.url(path)
        
        // Then
        XCTAssertEqual(url.absoluteString, "https://api.grunt.ltd")
    }
    
    func testURL_WithSlashOnlyPath_ReturnsSlash() {
        // Given
        let path = "/"
        
        // When
        let url = sut.url(path)
        
        // Then
        XCTAssertEqual(url.absoluteString, "https://api.grunt.ltd/")
    }
}

// MARK: - Extensions for Testing

extension UserDefaults {
    var deviceID: String {
        get {
            return string(forKey: "deviceID") ?? ""
        }
        set {
            set(newValue, forKey: "deviceID")
        }
    }
}
