import UIKit

/// Owns the app window and forwards scene lifecycle events to ApplicationController.
/// Required since iOS 27: UIKit traps at launch if the app has not adopted the UIScene lifecycle.
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    private var appDelegate: AppDelegate? {
        UIApplication.shared.delegate as? AppDelegate
    }

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = scene as? UIWindowScene else { return }
        // Unit tests host the app without launching the wallet UI
        if ProcessInfo.processInfo.environment["IS_RUNNING_UNIT_TESTS"] == "1" { return }

        let thisWindow = UIWindow(windowScene: windowScene)
        window = thisWindow
        thisWindow.overrideUserInterfaceStyle = UserDefaults.userPreferredDarkTheme ? .dark : .light

        UIView.appearance(whenContainedInInstancesOf:
            [UIAlertController.self])
                .tintColor = BrainwalletUIColor.content

        appDelegate?.applicationController.launch(application: UIApplication.shared, window: thisWindow)

        // URL used to cold-launch the app
        if let url = connectionOptions.urlContexts.first?.url {
            _ = appDelegate?.applicationController.open(url: url)
        }
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        _ = appDelegate?.applicationController.open(url: url)
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        appDelegate?.clearNotificationBadge()
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        appDelegate?.applicationController.willEnterForeground()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        appDelegate?.applicationController.didEnterBackground()
    }
}
