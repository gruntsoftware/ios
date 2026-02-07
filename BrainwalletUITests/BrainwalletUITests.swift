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
        sleep(1)  // Allow animation to complete
        snapshot("01WelcomeScreen")
        
        darkModeButton.tap()
        sleep(1)
        snapshot("02WelcomeScreen")
        
        app.buttons["restoreYourBrainwalletButton"].tap()
        XCTAssert(app.buttons["backButtonToStartRestore"].waitForExistence(timeout: 5))
        snapshot("03RestoreScreen")
        
        app.buttons["backButtonToStartRestore"].tap()
        XCTAssert(app.buttons["restoreYourBrainwalletButton"].waitForExistence(timeout: 5))
        
        app.buttons["readyCreateNewBrainwalletButton"].tap()
        XCTAssert(app.buttons["backButtonToStartReady"].waitForExistence(timeout: 5))
        snapshot("04ReadyScreen")
        
        app.buttons["backButtonToStartReady"].tap()
        XCTAssert(darkModeButton.waitForExistence(timeout: 5))
        
        XCTAssertTrue(app.buttons["darkModePreference"].exists)
        XCTAssertTrue(app.buttons["restoreYourBrainwalletButton"].exists)
        XCTAssertTrue(app.buttons["readyCreateNewBrainwalletButton"].exists)
    }
    
}
