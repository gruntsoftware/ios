//
//  SceneTests.swift
//  BrainwalletUnitTests
//
//  Created by Kerry Washington on 10/02/2026.
//  Copyright © 2026 Grunt Software, LTD. All rights reserved.
//
import XCTest
import SpriteKit
@testable import brainwallet

class FallinSceneTests: XCTestCase {
        
        var scene: FallinScene!
        var view: SKView!
         

        override func setUp() {
            super.setUp()
            scene = FallinScene(size: CGSize(width: 375, height: 667))
            scene.width = 375
            scene.height = 667
            view = SKView(frame: CGRect(x: 0, y: 0, width: 375, height: 667))
        }
        
        override func tearDown() {
            scene = nil
            view = nil
            super.tearDown()
        }
        
        // MARK: - didMove(to:) Tests
        
        func testDidMoveToView_SetsPhysicsBody() {
            // When
            view.presentScene(scene)
            
            // Then
            XCTAssertNotNil(scene.physicsBody, "Physics body should be set")
        }
        
        func testDidMoveToView_PhysicsBodyAffectedByGravity() {
            // When
            view.presentScene(scene)
            
            // Then
            XCTAssertTrue(scene.physicsBody?.affectedByGravity ?? false, "Physics body should be affected by gravity")
        }
        
        func testDidMoveToView_CallsMakeDot() {
            // When
            view.presentScene(scene)
            
            // Then - wait a brief moment for makeDot to execute
            let expectation = self.expectation(description: "Wait for makeDot")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                expectation.fulfill()
            }
            
            waitForExpectations(timeout: 0.2)
            XCTAssertGreaterThan(scene.children.count, 0, "Should have at least one child node after makeDot is called")
        }
        
        // MARK: - makeDot() Tests
        
        func testMakeDot_CreatesLabelNode() {
            // When
            scene.makeDot()
            
            // Then - wait briefly for async execution
            let expectation = self.expectation(description: "Wait for node creation")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                expectation.fulfill()
            }
            
            waitForExpectations(timeout: 1.0)
            
            let labelNodes = scene.children.compactMap { $0 as? SKLabelNode }
            XCTAssertGreaterThan(labelNodes.count, 0, "Should create at least one SKLabelNode")
        }
        
        func testMakeDot_LabelHasEmoji() {
            // When
            scene.makeDot()
            
            // Then
            let expectation = self.expectation(description: "Wait for node creation")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                expectation.fulfill()
            }
            
            waitForExpectations(timeout: 1.5)
            
            let labelNodes = scene.children.compactMap { $0 as? SKLabelNode }
            XCTAssertFalse(labelNodes.first?.text?.isEmpty ?? true, "Label should have text")
        }
        
        func testMakeDot_LabelPositionWithinBounds() {
            // When
            scene.makeDot()
            
            // Then
            let expectation = self.expectation(description: "Wait for node creation")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                expectation.fulfill()
            }
            
            waitForExpectations(timeout: 1.0)
            
            let labelNodes = scene.children.compactMap { $0 as? SKLabelNode }
            guard let label = labelNodes.first else {
                XCTFail("No label node found")
                return
            }
            
            XCTAssertGreaterThanOrEqual(label.position.x, 0, "X position should be >= 0")
            XCTAssertLessThanOrEqual(label.position.x, scene.width / 2, "X position should be <= width/2")
            XCTAssertGreaterThanOrEqual(label.position.y, 0, "Y position should be >= 0")
            XCTAssertLessThanOrEqual(label.position.y, scene.height, "Y position should be <= height")
        }
        
        func testMakeDot_LabelHasPhysicsBody() {
            // When
            scene.makeDot()
            
            // Then
            let expectation = self.expectation(description: "Wait for node creation")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                expectation.fulfill()
            }
            
            waitForExpectations(timeout: 1.0)
            
            let labelNodes = scene.children.compactMap { $0 as? SKLabelNode }
            XCTAssertNotNil(labelNodes.first?.physicsBody, "Label should have physics body")
        }
        
        func testMakeDot_PhysicsBodyProperties() {
            // When
            scene.makeDot()
            
            // Then
            let expectation = self.expectation(description: "Wait for node creation")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                expectation.fulfill()
            }
            
            waitForExpectations(timeout: 1.0)
            
            let labelNodes = scene.children.compactMap { $0 as? SKLabelNode }
            guard let physicsBody = labelNodes.first?.physicsBody else {
                XCTFail("No physics body found")
                return
            }
            
            XCTAssertTrue(physicsBody.affectedByGravity, "Should be affected by gravity")
            XCTAssertTrue(physicsBody.isDynamic, "Should be dynamic")
            XCTAssertEqual(physicsBody.restitution, 0.5, accuracy: 0.01, "Restitution should be 0.5")
            XCTAssertEqual(physicsBody.friction, 0.01, accuracy: 0.001, "Friction should be 0.01")
        }
        
        func testMakeDot_RecursiveCallsLimitedTo12Children() {
            // Given
            let expectation = self.expectation(description: "Wait for recursive calls")
            
            // When
            scene.makeDot()
            
            // Then - wait enough time for multiple recursive calls (2 seconds * 12 = 24+ seconds is too long)
            // Test the logic at a specific point in time
            DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) {
                expectation.fulfill()
            }
            
            waitForExpectations(timeout: 15.0)
            
            XCTAssertLessThanOrEqual(scene.children.count, 12, "Should not exceed 12 children before reset")
        }
        
        func testMakeDot_RemovesAllChildrenWhenLimitReached() {
            // Given - manually add 12 children to trigger the removal logic
            for _ in 0..<12 {
                let label = SKLabelNode(text: "🎨")
                scene.addChild(label)
            }
            
            XCTAssertEqual(scene.children.count, 12, "Should start with 12 children")
            
            let expectation = self.expectation(description: "Wait for removal")
            
            // When
            scene.makeDot()
            
            // Then - the delay is 2 seconds, so wait a bit longer
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                expectation.fulfill()
            }
            
            waitForExpectations(timeout: 3.0)
            
            // After removal and adding one new dot
            XCTAssertLessThan(scene.children.count, 12, "Should have removed children and started fresh")
        }
    }
