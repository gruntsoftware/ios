//
//  SceneLifecycleTests.swift
//  brainwallet
//
//  Guards the UIScene lifecycle adoption required by iOS 27
//  (v3.10.1 crashed at launch with "NoSceneLifecycleAdoption").
//

@testable import brainwallet
import UIKit
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

    /// libGDX sets `UIApplicationDelegate.window` to its game window. AppDelegate must accept it,
    /// keep the host window, and attach the game window to the host's scene so it can be shown.
    func testAppDelegateAdoptsGameWindowIntoHostScene() throws {
        let scene = try XCTUnwrap(UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }.first)
        let appDelegate = AppDelegate()
        XCTAssertTrue(appDelegate.responds(to: NSSelectorFromString("setWindow:")))

        let hostWindow = UIWindow(windowScene: scene)
        appDelegate.applicationController.launch(window: hostWindow)

        let gameWindow = UIWindow(frame: UIScreen.main.bounds)
        appDelegate.window = gameWindow

        XCTAssertTrue(appDelegate.window === hostWindow)
        XCTAssertTrue(gameWindow.windowScene === scene)
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
