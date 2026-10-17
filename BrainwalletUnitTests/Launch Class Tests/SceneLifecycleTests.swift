//
//  SceneLifecycleTests.swift
//  brainwallet
//
//  Guards the UIScene lifecycle adoption required by iOS 27
//  (v3.10.1 crashed at launch with "NoSceneLifecycleAdoption").
//

@testable import brainwallet
import XCTest

final class SceneLifecycleTests: XCTestCase {

    /// The Info.plist must declare a scene manifest pointing at SceneDelegate and
    /// must not use the storyboard-created window.
    func testInfoPlistDeclaresSceneManifest() throws {
        let info = try XCTUnwrap(Bundle(for: AppDelegate.self).infoDictionary)
        XCTAssertNil(info["UIMainStoryboardFile"], "Main storyboard window conflicts with scene lifecycle")

        let manifest = try XCTUnwrap(info["UIApplicationSceneManifest"] as? [String: Any])
        let configs = try XCTUnwrap(manifest["UISceneConfigurations"] as? [String: Any])
        let appRole = try XCTUnwrap(configs["UIWindowSceneSessionRoleApplication"] as? [[String: Any]])
        let first = try XCTUnwrap(appRole.first)

        XCTAssertEqual(first["UISceneConfigurationName"] as? String, "Default Configuration")
        let delegateName = try XCTUnwrap(first["UISceneDelegateClassName"] as? String)
        XCTAssertTrue(delegateName.hasSuffix("SceneDelegate"))
        XCTAssertNotNil(NSClassFromString(delegateName), "SceneDelegate class name must resolve at runtime")
    }

    func testAppDelegateNoLongerOwnsWindow() {
        let appDelegate = AppDelegate()
        XCTAssertFalse(appDelegate.responds(to: NSSelectorFromString("window")))
    }

    func testClearNotificationBadgeResetsPendingCount() {
        UserDefaults.pendingNotificationBadgeCount = 5
        AppDelegate().clearNotificationBadge()
        XCTAssertEqual(UserDefaults.pendingNotificationBadgeCount, 0)
    }

    /// A URL that arrives before the wallet UI has launched is queued, not handled.
    func testOpenURLBeforeLaunchIsQueued() throws {
        let controller = ApplicationController()
        let url = try XCTUnwrap(URL(string: "litecoin:LTC_ADDRESS"))
        XCTAssertFalse(controller.open(url: url))
    }

    func testSceneDelegateStartsWithoutWindow() {
        XCTAssertNil(SceneDelegate().window)
    }
}
