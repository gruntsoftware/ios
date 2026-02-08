//
//  LockScreenViewUITests.swift
//  BrainwalletUITests
//
//  Created by Kerry Washington on 08/02/2026.
//  Copyright © 2026 Grunt Software, LTD. All rights reserved.
//

import XCTest

final class LockScreenViewUITests: XCTestCase {
    
    var app: XCUIApplication!
   
    override func setUpWithError() throws {
        try super.setUpWithError()
        continueAfterFailure = false
         
        app = XCUIApplication()
        Task {
            await setupSnapshot(app)
        }
        app.launch()
           
        let isLockScreenViewShowing = app.otherElements["Lock Screen Footer View"].waitForExistence(timeout: 2)
        try XCTSkipUnless(isLockScreenViewShowing, "Lock Screen Footer View not showing, skipping these tests")
    }

    override func tearDownWithError() throws {
        app.terminate()
    }

    @MainActor
    func testLockScreenView() throws {
        
        XCTAssertTrue(app.staticTexts["Lock Screen Footer View"].exists)

        app.activate()
        app/*@START_MENU_TOKEN@*/.buttons["moon.stars"]/*[[".otherElements",".buttons[\"Clear Night\"]",".buttons[\"moon.stars\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        app/*@START_MENU_TOKEN@*/.buttons["sun.max"]/*[[".otherElements",".buttons[\"Brightness Higher\"]",".buttons[\"sun.max\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        app/*@START_MENU_TOKEN@*/.buttons["qrcode"]/*[[".otherElements",".buttons[\"Qr Code\"]",".buttons[\"qrcode\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        
        let element = app/*@START_MENU_TOKEN@*/.buttons["8"]/*[[".otherElements.buttons[\"8\"]",".buttons[\"8\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch
        element.swipeDown()
        app/*@START_MENU_TOKEN@*/.buttons["trash"]/*[[".otherElements",".buttons[\"Trash\"]",".buttons[\"trash\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        app/*@START_MENU_TOKEN@*/.buttons["Cancel"]/*[[".otherElements.buttons[\"Cancel\"]",".buttons[\"Cancel\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        app/*@START_MENU_TOKEN@*/.buttons["1"]/*[[".otherElements.buttons[\"1\"]",".buttons[\"1\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        app/*@START_MENU_TOKEN@*/.buttons["2"]/*[[".otherElements.buttons[\"2\"]",".buttons[\"2\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        app/*@START_MENU_TOKEN@*/.buttons["3"]/*[[".otherElements.buttons[\"3\"]",".buttons[\"3\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        
        let element2 = app/*@START_MENU_TOKEN@*/.buttons["4"]/*[[".otherElements.buttons[\"4\"]",".buttons[\"4\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch
        element2.tap()
        
        let element3 = app/*@START_MENU_TOKEN@*/.buttons["arrow.backward"]/*[[".otherElements.buttons[\"arrow.backward\"]",".buttons[\"arrow.backward\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch
        element3.doubleTap()
        element3.tap()
        element2.tap()
        app/*@START_MENU_TOKEN@*/.buttons["5"]/*[[".otherElements.buttons[\"5\"]",".buttons[\"5\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        app/*@START_MENU_TOKEN@*/.buttons["6"]/*[[".otherElements.buttons[\"6\"]",".buttons[\"6\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        app/*@START_MENU_TOKEN@*/.buttons["7"]/*[[".otherElements.buttons[\"7\"]",".buttons[\"7\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        element.tap()
        app/*@START_MENU_TOKEN@*/.buttons["9"]/*[[".otherElements.buttons[\"9\"]",".buttons[\"9\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        app/*@START_MENU_TOKEN@*/.buttons["0"]/*[[".otherElements.buttons[\"0\"]",".buttons[\"0\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        element3.tap()
        element3.doubleTap()
     }
}
