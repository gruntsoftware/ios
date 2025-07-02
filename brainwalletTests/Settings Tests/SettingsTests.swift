//
// SettingsTests
//  brainwallet
//
//  Created by Kerry Washington on 01/06/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.

import XCTest
import SwiftUI
@testable import brainwallet

class SettingsHelpersTests: XCTestCase {
    
    // MARK: - Constants Tests
    
    func testClosedRowHeight() {
        XCTAssertEqual(closedRowHeight, 65.0, "closedRowHeight should be 65.0")
    }
    
    func testToggleRowHeight() {
        XCTAssertEqual(toggleRowHeight, 50.0, "toggleRowHeight should be 50.0")
    }
    
    func testUpdatePINRowHeight() {
        XCTAssertEqual(updatePINRowHeight, 100.0, "updatePINRowHeight should be 100.0")
    }
    
    func testExpandedRowHeight() {
        XCTAssertEqual(expandedRowHeight, 240.0, "expandedRowHeight should be 240.0")
    }
    
    func testRowLeadingPad() {
        XCTAssertEqual(rowLeadingPad, 32.0, "rowLeadingPad should be 32.0")
    }
    
    func testLeadRowPad() {
        XCTAssertEqual(leadRowPad, 40.0, "leadRowPad should be 40.0")
    }
    
    func testTrailRowPad() {
        XCTAssertEqual(trailRowPad, 16.0, "trailRowPad should be 16.0")
    }
    
    func testExpandArrowSize() {
        XCTAssertEqual(expandArrowSize, 20.0, "expandArrowSize should be 20.0")
    }
    
    func testPickerViewHeight() {
        XCTAssertEqual(pickerViewHeight, 160.0, "pickerViewHeight should be 160.0")
    }
    
    // MARK: - SettingsAction Enum Tests
    
    func testSettingsActionCaseIterable() {
        let allCases = SettingsAction.allCases
        XCTAssertEqual(allCases.count, 5, "SettingsAction should have 5 cases")
        XCTAssertTrue(allCases.contains(.preferDarkMode), "Should contain preferDarkMode case")
        XCTAssertTrue(allCases.contains(.wipeData), "Should contain wipeData case")
        XCTAssertTrue(allCases.contains(.lock), "Should contain lock case")
        XCTAssertTrue(allCases.contains(.toggle), "Should contain toggle case")
    }
    
    // MARK: - isOnSystemImage Tests
    
    func testPreferDarkModeIsOnSystemImage() {
        XCTAssertEqual(SettingsAction.preferDarkMode.isOnSystemImage, "moon.circle",
                      "preferDarkMode isOnSystemImage should be 'moon.circle'")
    }
    
    func testWipeDataIsOnSystemImage() {
        XCTAssertEqual(SettingsAction.wipeData.isOnSystemImage, "trash",
                      "wipeData isOnSystemImage should be 'trash'")
    }
    
    func testLockIsOnSystemImage() {
        XCTAssertEqual(SettingsAction.lock.isOnSystemImage, "lock",
                      "lock isOnSystemImage should be 'lock'")
    }
    
    func testToggleIsOnSystemImage() {
        XCTAssertEqual(SettingsAction.toggle.isOnSystemImage, "lightswitch.on",
                      "toggle isOnSystemImage should be 'lightswitch.on'")
    }
    
    // MARK: - isOffSystemImage Tests
    
    func testPreferDarkModeIsOffSystemImage() {
        XCTAssertEqual(SettingsAction.preferDarkMode.isOffSystemImage, "sun.max.circle",
                      "preferDarkMode isOffSystemImage should be 'sun.max.circle'")
    }
    
    func testWipeDataIsOffSystemImage() {
        XCTAssertEqual(SettingsAction.wipeData.isOffSystemImage, "trash",
                      "wipeData isOffSystemImage should be 'trash'")
    }
    
    func testLockIsOffSystemImage() {
        XCTAssertEqual(SettingsAction.lock.isOffSystemImage, "lock.open",
                      "lock isOffSystemImage should be 'lock.open'")
    }
    
    func testToggleIsOffSystemImage() {
        XCTAssertEqual(SettingsAction.toggle.isOffSystemImage, "lightswitch.off",
                      "toggle isOffSystemImage should be 'lightswitch.off'")
    }
    
    // MARK: - Comprehensive System Image Tests
    
    func testAllSettingsActionsHaveValidSystemImages() {
        for action in SettingsAction.allCases {
            XCTAssertFalse(action.isOnSystemImage.isEmpty,
                          "\(action) isOnSystemImage should not be empty")
            XCTAssertFalse(action.isOffSystemImage.isEmpty,
                          "\(action) isOffSystemImage should not be empty")
        }
    }
    
    func testSystemImageConsistency() {
        // Test that wipeData has the same image for both on and off states
        XCTAssertEqual(SettingsAction.wipeData.isOnSystemImage,
                      SettingsAction.wipeData.isOffSystemImage,
                      "wipeData should have the same system image for both on and off states")
    }
    
    func testSystemImageDifferences() {
        // Test that other actions have different images for on/off states
        XCTAssertNotEqual(SettingsAction.preferDarkMode.isOnSystemImage,
                         SettingsAction.preferDarkMode.isOffSystemImage,
                         "preferDarkMode should have different system images for on and off states")
        
        XCTAssertNotEqual(SettingsAction.lock.isOnSystemImage,
                         SettingsAction.lock.isOffSystemImage,
                         "lock should have different system images for on and off states")
        
        XCTAssertNotEqual(SettingsAction.toggle.isOnSystemImage,
                         SettingsAction.toggle.isOffSystemImage,
                         "toggle should have different system images for on and off states")
    }
    
    // MARK: - Edge Case Tests
    
    func testConstantsArePositive() {
        XCTAssertGreaterThan(closedRowHeight, 0, "closedRowHeight should be positive")
        XCTAssertGreaterThan(toggleRowHeight, 0, "toggleRowHeight should be positive")
        XCTAssertGreaterThan(updatePINRowHeight, 0, "updatePINRowHeight should be positive")
        XCTAssertGreaterThan(expandedRowHeight, 0, "expandedRowHeight should be positive")
        XCTAssertGreaterThan(rowLeadingPad, 0, "rowLeadingPad should be positive")
        XCTAssertGreaterThan(leadRowPad, 0, "leadRowPad should be positive")
        XCTAssertGreaterThan(trailRowPad, 0, "trailRowPad should be positive")
        XCTAssertGreaterThan(expandArrowSize, 0, "expandArrowSize should be positive")
        XCTAssertGreaterThan(pickerViewHeight, 0, "pickerViewHeight should be positive")
    }
    
    func testRowHeightRelationships() {
        // Test logical relationships between row heights
        XCTAssertGreaterThan(expandedRowHeight, closedRowHeight,
                            "expandedRowHeight should be greater than closedRowHeight")
        XCTAssertGreaterThan(updatePINRowHeight, toggleRowHeight,
                            "updatePINRowHeight should be greater than toggleRowHeight")
        XCTAssertGreaterThan(expandedRowHeight, updatePINRowHeight,
                            "expandedRowHeight should be greater than updatePINRowHeight")
    }
    
    func testPaddingRelationships() {
        // Test logical relationships between padding values
        XCTAssertGreaterThan(leadRowPad, rowLeadingPad,
                            "leadRowPad should be greater than rowLeadingPad")
        XCTAssertGreaterThan(rowLeadingPad, trailRowPad,
                            "rowLeadingPad should be greater than trailRowPad")
    }
}
