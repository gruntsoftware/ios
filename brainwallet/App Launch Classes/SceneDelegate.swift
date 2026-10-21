import UIKit

/// Owns the app window and forwards scene lifecycle events to ApplicationController.
/// Required since iOS 27: UIKit traps at launch if the app has not adopted the UIScene lifecycle.
class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    private var applicationController: ApplicationController? {
        (UIApplication.shared.delegate as? AppDelegate)?.applicationController
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

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(restartAfterWipedWallet),
                                               name: .didDeleteWalletDBNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateUserThemePreference),
                                               name: .changedThemePreferenceNotification,
                                               object: nil)

        applicationController?.launch(window: thisWindow)

        // URL used to cold-launch the app
        if let url = connectionOptions.urlContexts.first?.url {
            _ = applicationController?.open(url: url)
        }
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        guard let url = URLContexts.first?.url else { return }
        _ = applicationController?.open(url: url)
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        (UIApplication.shared.delegate as? AppDelegate)?.clearNotificationBadge()
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        applicationController?.willEnterForeground()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        applicationController?.didEnterBackground()
    }

    @objc
    private func restartAfterWipedWallet() {
        debugPrint(":::: Restarting after wiping wallet")
        DispatchQueue.main.async {
            guard let window = self.applicationController?.window else { return }
            window.rootViewController?.dismiss(animated: false, completion: nil)
            // Clear the root view controller
            window.rootViewController = nil
            /// TBD to restart the app
        }
    }

    @objc
    private func updateUserThemePreference() {
        DispatchQueue.main.async {
            self.applicationController?.window?.overrideUserInterfaceStyle = UserDefaults.userPreferredDarkTheme ? .dark : .light
        }
    }
}
