import Foundation
import StoreKit

extension ApplicationController {
	func setupDefaults() {
		if UserDefaults.standard.object(forKey: shouldRequireLoginTimeoutKey) == nil {
			UserDefaults.standard.set(60.0 * 3.0, forKey: shouldRequireLoginTimeoutKey) // Default 3 min timeout
		}

        if UserDefaults.standard.object(forKey: userDidPreferDarkModeKey) == nil {
            UserDefaults.standard.set(false, forKey: userDidPreferDarkModeKey)
        }

        if UserDefaults.standard.object(forKey: userCurrentLocaleMPApprovedKey) == nil {
            UserDefaults.standard.set(false, forKey: userCurrentLocaleMPApprovedKey)
        }
	}

	func countLaunches() {
		if var launchNumber = UserDefaults.standard.object(forKey: numberOfBrainwalletLaunches) as? Int {
			launchNumber += 1
			UserDefaults.standard.set(NSNumber(value: launchNumber), forKey: numberOfBrainwalletLaunches)
			if launchNumber == 3 {
				SKStoreReviewController.requestReviewInCurrentScene()
			}
		} else {
			UserDefaults.standard.set(NSNumber(value: 1), forKey: numberOfBrainwalletLaunches)
		}
	}
}
