import StoreKit

// Inspired by https://stackoverflow.com/questions/63953891/requestreview-was-deprecated-in-ios-14-0
// For iOS 16+ and higher. place in anyview
// @Environment(\.requestReview) private var requestReview
// requestReview()

// Seam so callers (e.g. ApplicationController) can inject a spy in unit tests
// instead of invoking the real StoreKit prompt.
protocol AppStoreReviewRequesting {
	static func requestReviewInCurrentScene()
}

public extension SKStoreReviewController {
	static func requestReviewInCurrentScene() {
		if let scene = UIApplication.shared
			.connectedScenes
			.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
			DispatchQueue.main.async {
				requestReview(in: scene)
			}
		}
	}
}

extension SKStoreReviewController: AppStoreReviewRequesting {}
