//
//  BrainwalletUITests.swift
//  BrainwalletUITests
//
//  Created by Kerry Washington on 25/07/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

import XCTest

final class BrainwalletUITests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws { }

    @MainActor
    func testStartView() throws {
        let app = XCUIApplication()
        setupSnapshot(app)
        app.launch()
        let darkModeButton = app.buttons["darkModePreference"]
        XCTAssert(darkModeButton.waitForExistence(timeout: 10))
        darkModeButton.tap()
        snapshot("01WelcomeScreen")
        darkModeButton.tap()
        snapshot("02WelcomeScreen")
        app.buttons["restoreYourBrainwalletButton"].tap()
        snapshot("03RestoreScreen")
        app.buttons["backButtonToStartRestore"].tap()
        app.buttons["readyCreateNewBrainwalletButton"].tap()
        snapshot("04ReadyScreen")
        app.buttons["backButtonToStartReady"].tap()
        
        XCTAssertTrue(app.buttons["darkModePreference"].exists, "Verified darkModePreference")
        XCTAssertTrue(app.buttons["restoreYourBrainwalletButton"].exists, "Verified restoreButton")
        XCTAssertTrue(app.buttons["readyCreateNewBrainwalletButton"].exists, "Verified readyButton")
     }
}
