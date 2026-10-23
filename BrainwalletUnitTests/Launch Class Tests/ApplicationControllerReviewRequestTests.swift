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
        try? UserDefaults.wipeGameScoresKeychain()
    }

    override func tearDown() {
        controller = nil
        UserDefaults.standard.removeObject(forKey: numberOfBrainwalletLaunches)
        try? UserDefaults.wipeGameScoresKeychain()
        super.tearDown()
    }

    private func appendGameScores(_ count: Int) {
        for index in 0..<count {
            UserDefaults.appendGameScore(GameScoreRecord(totalScore: index * 10, timestamp: index))
        }
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

    // MARK: - requestReviewIfEnoughGamesPlayed()

    func testDoesNotRequestReviewWithNoGameScores() {
        XCTAssertFalse(controller.requestReviewIfEnoughGamesPlayed())
    }

    func testDoesNotRequestReviewAfterOneGame() {
        appendGameScores(1)

        XCTAssertFalse(controller.requestReviewIfEnoughGamesPlayed())
    }

    func testRequestsReviewAfterTwoGames() {
        appendGameScores(2)

        XCTAssertTrue(controller.requestReviewIfEnoughGamesPlayed())
    }

    func testRequestsReviewAfterMoreThanTwoGames() {
        appendGameScores(5)

        XCTAssertTrue(controller.requestReviewIfEnoughGamesPlayed())
    }

    func testRequestReviewAfterTwoGamesInvokesReviewRequesterAfterDelay() {
        let expectation = expectation(description: "review requested after second game")
        appendGameScores(2)

        controller.requestReviewIfEnoughGamesPlayed()

        XCTAssertEqual(ReviewRequestingSpy.requestReviewCallCount, 0, "should not fire immediately")

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.2) {
            XCTAssertEqual(ReviewRequestingSpy.requestReviewCallCount, 1)
            expectation.fulfill()
        }

        waitForExpectations(timeout: 4.0)
    }

    // MARK: - UserDefaults.gameScores

    func testGameScoresIsEmptyByDefault() {
        XCTAssertEqual(UserDefaults.gameScores, [])
    }

    func testAppendGameScoreStoresRecordsInOrder() {
        let first = GameScoreRecord(totalScore: 120, timestamp: 1_792_780_800_000)
        let second = GameScoreRecord(totalScore: 340, timestamp: 1_792_780_900_000)

        UserDefaults.appendGameScore(first)
        UserDefaults.appendGameScore(second)

        XCTAssertEqual(UserDefaults.gameScores, [first, second])
    }

    func testGameScoreRecordEncodesSnakeCaseKeys() throws {
        let data = try JSONEncoder().encode([GameScoreRecord(totalScore: 42, timestamp: 7)])
        let json = try XCTUnwrap(JSONSerialization.jsonObject(with: data) as? [[String: Int]])

        XCTAssertEqual(json, [["total_score": 42, "timestamp": 7]])
    }

    func testWipeGameScoresKeychainClearsScores() throws {
        appendGameScores(3)

        try UserDefaults.wipeGameScoresKeychain()

        XCTAssertEqual(UserDefaults.gameScores, [])
    }
}
