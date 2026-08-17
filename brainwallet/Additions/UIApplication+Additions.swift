import UIKit

extension UIApplication {
    /// The active scene's key window, replacing the deprecated
    /// `UIApplication.shared.windows.filter { $0.isKeyWindow }.first`.
    var currentKeyWindow: UIWindow? {
        connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .first
    }
}
