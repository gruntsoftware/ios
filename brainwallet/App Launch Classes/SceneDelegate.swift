//
//  SceneDelegate.swift
//  brainwallet
//
//  Created by Kerry Washington on 15/06/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        // Set up your window here
        window = UIWindow(windowScene: windowScene)
        /// Move from AppDelegate atter testing
        // window?.rootViewController = initialViewController
        // Or if setting up programmatically:
        // let rootViewController = YourViewController()
        // window?.rootViewController = rootViewController
        window?.makeKeyAndVisible()
    }
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called when scene is released
    }
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when scene becomes active
    }
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when scene will resign active
    }
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called when scene enters foreground
    }
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called when scene enters background
    }
}
