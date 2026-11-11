//
//  Application Controller Tests.swift
//  brainwallet
//
//  Created by Kerry Washington on 30/06/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

import XCTest
@testable import brainwallet

final class ApplicationControllerTests: XCTestCase {

    var controller: ApplicationController!
    var testWindow: UIWindow!

    override func setUp() {
        super.setUp()
        controller = ApplicationController()
        testWindow = UIWindow()
    }

    override func tearDown() {
        controller = nil
        testWindow = nil
        super.tearDown()
    }

    func testShouldRequireLoginReturnsTrueWhenPastTimeout() {
        let now = Date().timeIntervalSince1970
        UserDefaults.standard.set(now - 120, forKey: timeSinceLastExitKey)
        UserDefaults.standard.set(60.0, forKey: shouldRequireLoginTimeoutKey)

        XCTAssertTrue(controller.shouldRequireLogin())
    }

    func testShouldRequireLoginReturnsFalseWhenWithinTimeout() {
        let now = Date().timeIntervalSince1970
        UserDefaults.standard.set(now - 30, forKey: timeSinceLastExitKey)
        UserDefaults.standard.set(60.0, forKey: shouldRequireLoginTimeoutKey)

        XCTAssertFalse(controller.shouldRequireLogin())
    }

    func testLaunchAssignsWindow() {
        controller.launch(window: testWindow)
        XCTAssertTrue(controller.window === testWindow)
    }
}
