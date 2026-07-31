//
//  ApplicationControllerReviewRequestTests.swift
//  brainwallet
//
//  Copyright © 2026 Grunt Software, LTD. All rights reserved.
//

import XCTest
@testable import brainwallet

/// Spy standing in for SKStoreReviewController so tests never trigger the real StoreKit prompt.
final class ReviewRequestingSpy: AppStoreReviewRequesting {
    static var requestReviewCallCount = 0

    static func requestReviewInCurrentScene() {
        requestReviewCallCount += 1
    }

    static func reset() {
        requestReviewCallCount = 0
    }
}

final class ApplicationControllerReviewRequestTests: XCTestCase {

    var controller: ApplicationController!

    override func setUp() {
        super.setUp()
        controller = ApplicationController()
        controller.reviewRequester = ReviewRequestingSpy.self
        ReviewRequestingSpy.reset()
        UserDefaults.standard.removeObject(forKey: numberOfBrainwalletLaunches)
    }

    override func tearDown() {
        controller = nil
        UserDefaults.standard.removeObject(forKey: numberOfBrainwalletLaunches)
        super.tearDown()
    }

    // MARK: - countLaunches()

    func testCountLaunchesDoesNotRequestReviewBeforeThirdLaunch() {
        controller.countLaunches() // 1
        controller.countLaunches() // 2

        XCTAssertEqual(ReviewRequestingSpy.requestReviewCallCount, 0)
    }

    func testCountLaunchesRequestsReviewOnThirdLaunch() {
        controller.countLaunches() // 1
        controller.countLaunches() // 2
        controller.countLaunches() // 3

        XCTAssertEqual(ReviewRequestingSpy.requestReviewCallCount, 1)
    }

    func testCountLaunchesDoesNotRequestReviewAgainAfterThirdLaunch() {
        for _ in 1...5 {
            controller.countLaunches()
        }

        XCTAssertEqual(ReviewRequestingSpy.requestReviewCallCount, 1)
    }

    // MARK: - requestReviewAfterGameFinished()

    func testRequestReviewAfterGameFinishedInvokesReviewRequesterAfterDelay() {
        let expectation = expectation(description: "review requested after game finished")

        controller.requestReviewAfterGameFinished()

        XCTAssertEqual(ReviewRequestingSpy.requestReviewCallCount, 0, "should not fire immediately")

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.2) {
            XCTAssertEqual(ReviewRequestingSpy.requestReviewCallCount, 1)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 4.0)
    }
}
