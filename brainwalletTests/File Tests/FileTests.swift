//
//  FileTests.swift
//  loafwalletTests
//
//  Created by Kerry Washington on 5/6/21.
//
import Firebase
@testable import brainwallet
import XCTest

class FileTests: XCTestCase {
	func testGoogleServicesFileExists() throws {
		let filePath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist")

		XCTAssertNotNil(FirebaseOptions(contentsOfFile: filePath!))
	}
}
