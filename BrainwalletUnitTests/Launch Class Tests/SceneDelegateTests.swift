//
//  SceneDelegateTests.swift
//  brainwallet
//
//  Exercises SceneDelegate against the scene the test host app is running in.
//

@testable import brainwallet
import UIKit
import XCTest

final class SceneDelegateTests: XCTestCase {

    private var sceneDelegate: SceneDelegate!

    override func setUp() {
        super.setUp()
        sceneDelegate = SceneDelegate()
    }

    override func tearDown() {
        sceneDelegate = nil
        super.tearDown()
    }

    private func hostScene() throws -> UIWindowScene {
        try XCTUnwrap(UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first,
                      "Test host has no connected UIWindowScene")
    }

    // MARK: - Lifecycle forwarding

    func testSceneDidBecomeActiveClearsBadgeCount() throws {
        UserDefaults.pendingNotificationBadgeCount = 7
        sceneDelegate.sceneDidBecomeActive(try hostScene())
        XCTAssertEqual(UserDefaults.pendingNotificationBadgeCount, 0)
    }

    func testSceneWillEnterForegroundDoesNotCrashWithoutWallet() throws {
        // No wallet manager yet in the test host -> willEnterForeground early-returns
        sceneDelegate.sceneWillEnterForeground(try hostScene())
    }

    func testSceneDidEnterBackgroundDoesNotCrash() throws {
        sceneDelegate.sceneDidEnterBackground(try hostScene())
    }

    // Note: scene(_:willConnectTo:) and AppDelegate.configurationForConnecting cannot be unit tested,
    // as UIScene.ConnectionOptions has no public initializer. Their wiring is covered by
    // SceneLifecycleTests.testInfoPlistDeclaresSceneManifest.

    // MARK: - URL handling

    func testOpenURLContextsWithEmptySetIsIgnored() throws {
        sceneDelegate.scene(try hostScene(), openURLContexts: [])
    }
}
