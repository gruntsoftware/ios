//
//  StartViewUITests.swift
//
//  Created by Kerry Washington on 08/02/2026.
//  Copyright © 2026 Grunt Software, LTD. All rights reserved.
//

import XCTest

final class StartViewUITests: XCTestCase {
var app: XCUIApplication!

override func setUpWithError() throws {
    try super.setUpWithError()
    continueAfterFailure = false
    
    app = XCUIApplication()
    Task {
        await setupSnapshot(app)
    }
    app.launch()
      
    
    let isStartViewShowing = app.otherElements["Welcome Moji Demo View"].waitForExistence(timeout: 2)
    try XCTSkipUnless(isStartViewShowing, "StartView not showing, skipping these tests")
}

override func tearDownWithError() throws {
    app.terminate()
}

    @MainActor
    func testStartToReadyPath() throws {
        app = XCUIApplication()
        app.activate()
        app/*@START_MENU_TOKEN@*/.buttons["darkModePreference"]/*[[".otherElements",".buttons[\"Brightness Higher\"]",".buttons[\"darkModePreference\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        app/*@START_MENU_TOKEN@*/.buttons["darkModePreference"]/*[[".otherElements",".buttons[\"Clear Night\"]",".buttons[\"darkModePreference\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        app/*@START_MENU_TOKEN@*/.buttons["readyCreateNewBrainwalletButton"]/*[[".otherElements",".buttons[\"Create New Wallet\"]",".buttons[\"readyCreateNewBrainwalletButton\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        app/*@START_MENU_TOKEN@*/.buttons["Setup app passcode"]/*[[".otherElements.buttons[\"Setup app passcode\"]",".buttons[\"Setup app passcode\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        
        let element = app/*@START_MENU_TOKEN@*/.buttons["1"]/*[[".otherElements.buttons[\"1\"]",".buttons[\"1\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch
        element.tap()
        
        let element2 = app/*@START_MENU_TOKEN@*/.buttons["2"]/*[[".otherElements.buttons[\"2\"]",".buttons[\"2\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch
        element2.tap()
        
        let element3 = app/*@START_MENU_TOKEN@*/.buttons["3"]/*[[".otherElements.buttons[\"3\"]",".buttons[\"3\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch
        element3.tap()
        
        let arrowBackwardElementsQuery = app.buttons.matching(identifier: "arrow.backward")
        let element4 = arrowBackwardElementsQuery.element(boundBy: 1)
        element4.doubleTap()
        element4.tap()
        element3.tap()
        
        let element5 = app/*@START_MENU_TOKEN@*/.buttons["4"]/*[[".otherElements.buttons[\"4\"]",".buttons[\"4\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch
        element5.tap()
        
        let element6 = app/*@START_MENU_TOKEN@*/.buttons["5"]/*[[".otherElements.buttons[\"5\"]",".buttons[\"5\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch
        element6.tap()
        
        let element7 = app/*@START_MENU_TOKEN@*/.buttons["6"]/*[[".otherElements.buttons[\"6\"]",".buttons[\"6\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch
        element7.tap()
        
        let element8 = arrowBackwardElementsQuery.element(boundBy: 0)
        element8.tap()
        
        let element9 = app/*@START_MENU_TOKEN@*/.buttons["7"]/*[[".otherElements.buttons[\"7\"]",".buttons[\"7\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch
        element9.tap()
        
        let element10 = app/*@START_MENU_TOKEN@*/.buttons["8"]/*[[".otherElements.buttons[\"8\"]",".buttons[\"8\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch
        element10.tap()
        
        let element11 = app/*@START_MENU_TOKEN@*/.buttons["9"]/*[[".otherElements.buttons[\"9\"]",".buttons[\"9\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch
        element11.tap()
        
        let element12 = app/*@START_MENU_TOKEN@*/.buttons["0"]/*[[".otherElements.buttons[\"0\"]",".buttons[\"0\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch
        element12.tap()
        element8.tap()
        element.doubleTap()
        element.doubleTap()
        element.tap()
        element.tap()
        element2.tap()
        element6.tap()
        element3.tap()
        element5.tap()
        element6.tap()
        element7.tap()
        element9.tap()
        element10.tap()
        element11.tap()
        element12.tap()
        element.tap()
        element.tap()
        element.doubleTap()
    }
    
    @MainActor
    func testStartToRestorePath() throws {
        app = XCUIApplication()
        app.activate()
        app/*@START_MENU_TOKEN@*/.buttons["restoreYourBrainwalletButton"]/*[[".otherElements",".buttons[\"Restore with Seed Phrase\"]",".buttons[\"restoreYourBrainwalletButton\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        app/*@START_MENU_TOKEN@*/.buttons["Restore your Brainwallet"]/*[[".otherElements.buttons[\"Restore your Brainwallet\"]",".buttons[\"Restore your Brainwallet\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch.tap()
        
        let element = app/*@START_MENU_TOKEN@*/.buttons["1"]/*[[".otherElements.buttons[\"1\"]",".buttons[\"1\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch
        element.tap()
        
        let element2 = app/*@START_MENU_TOKEN@*/.buttons["2"]/*[[".otherElements.buttons[\"2\"]",".buttons[\"2\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch
        element2.tap()
        
        let element3 = app/*@START_MENU_TOKEN@*/.buttons["3"]/*[[".otherElements.buttons[\"3\"]",".buttons[\"3\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch
        element3.tap()
        
        let element4 = app/*@START_MENU_TOKEN@*/.buttons["4"]/*[[".otherElements.buttons[\"4\"]",".buttons[\"4\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.firstMatch
        element4.tap()
        element.tap()
        element2.tap()
        element3.tap()
        element4.tap()
     }
}

