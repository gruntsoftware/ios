import Foundation
import SwiftUI

class ForgotAlertViewModel: ObservableObject {
	// MARK: - Combine Variables

	@Published
	var emailString: String = ""

	@Published
	var detailMessage: String = ""

	init() {}

	func resetPassword(completion _: @escaping () -> Void) {}

	func shouldDismissView(completion: @escaping () -> Void) {
		completion()
	}
}
