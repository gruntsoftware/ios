import AppsFlyerLib
import Firebase
import FirebaseCore
import FirebaseAnalytics
import LocalAuthentication
import SwiftUI
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	var window: UIWindow?
	var applicationController = ApplicationController()
	var remoteConfigurationHelper: RemoteConfigHelper?

	var resourceRequest: NSBundleResourceRequest?

	func application(_ application: UIApplication, didFinishLaunchingWithOptions _: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        preSetupSteps()

        // Wipe restart
        // Register for system notifications
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(restartAfterWipedWallet),
            name: .didDeleteWalletDBNotification,
            object: nil
        )

        // Set User theme preference
        // Register for system notifications
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateUserThemePreference),
            name: .changedThemePreferenceNotification,
            object: nil
        )
		return true
	}

    private func preSetupSteps() {

        // Locale and fetch access
        // DEV: Break here to test Locale/Matrix

        var regionCode2Char: String = "RU"
        let countryRussia = MoonpayCountryData(alphaCode2Char: "RU",
                                       alphaCode3Char: "RUS",
                                       isBuyAllowed: false,
                                       isSellAllowed: false,
                                       countryName: "Russia",
                                       isAllowedInCountry: false)

        if let regionCode = Locale.current.region?.identifier {
            regionCode2Char = regionCode
        }

        NetworkHelper.init().fetchCurrenciesCountries(completion:  { countryData  in

            let currentMoonPayCountry = countryData.filter { $0.alphaCode2Char == regionCode2Char }.first ?? countryRussia

            let isBuyAllowed = currentMoonPayCountry.isBuyAllowed
            if isBuyAllowed {
                UserDefaults.standard.set(isBuyAllowed, forKey: userCurrentLocaleMPApprovedKey)
            } else {
            UserDefaults.standard.set(false, forKey: userCurrentLocaleMPApprovedKey)
            }

            UserDefaults.standard.synchronize()
        })

        // Ops
        let startDate = Partner.partnerKeyPath(name: .walletStart)
            if startDate == "error-brainwallet-start-key" {
                let errorDescription = "partnerkey_data_missing"
                BWAnalytics.logEventWithParameters(itemName: ._20200112_ERR, properties: ["error": errorDescription])
            }

        // Firebase
        if FirebaseApp.app() == nil {
            self.setFirebaseConfiguration()
        }

        // AF
        AppsFlyerLib.shared().appsFlyerDevKey = Partner.partnerKeyPath(name: .prodAF)
        AppsFlyerLib.shared().appleAppID = BrainwalletAppStore.adamIDString

        // Remote Config
        self.remoteConfigurationHelper = RemoteConfigHelper.sharedInstance

        let current = UNUserNotificationCenter.current()
        current.getNotificationSettings(completionHandler: { settings in

            debugPrint(settings.debugDescription)
            if settings.authorizationStatus == .denied {}
        })

        guard let thisWindow = window else { return }

        // Set global themes
        thisWindow.overrideUserInterfaceStyle = UserDefaults.userPreferredDarkTheme ? .dark: .light

        UIView.appearance(whenContainedInInstancesOf:
            [UIAlertController.self])
                .tintColor = BrainwalletUIColor.content

        UIView.swizzleSetFrame()
        self.applicationController.launch(application: UIApplication.shared, window: thisWindow)
    }

	func applicationDidBecomeActive(_: UIApplication) {
		UIApplication.shared.applicationIconBadgeNumber = 0
		AppsFlyerLib.shared().start()
	}

	func applicationWillEnterForeground(_: UIApplication) {
		applicationController.willEnterForeground()
	}

	func applicationDidEnterBackground(_: UIApplication) {
		applicationController.didEnterBackground()
	}

	func application(_: UIApplication, shouldAllowExtensionPointIdentifier _: UIApplication.ExtensionPointIdentifier) -> Bool {
		return false // disable extensions such as custom keyboards for security purposes
	}

	func application(_: UIApplication, open url: URL, options _: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
		return applicationController.open(url: url)
	}

	func application(_: UIApplication, shouldSaveSecureApplicationState _: NSCoder) -> Bool {
		return true
	}

	func application(_: UIApplication, shouldRestoreApplicationState _: NSCoder) -> Bool {
		return true
	}

	func application(_: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken _: Data) {
		let acceptanceDict: [String: String] = ["did_accept": "true",
		                                        "date_accepted": Date().ISO8601Format()]
		BWAnalytics.logEventWithParameters(itemName: ._20231225_UAP, properties: acceptanceDict)
	}

	func application(_: UIApplication, didReceiveRemoteNotification _: [AnyHashable: Any],
	                 fetchCompletionHandler _: @escaping (UIBackgroundFetchResult) -> Void) {}

    @objc
    private func restartAfterWipedWallet() {
        // Change State
        debugPrint(":: Restarting after wiping wallet")

        DispatchQueue.main.async {
            guard let thisWindow = self.window else { return }

            thisWindow.rootViewController?.dismiss(animated: false, completion: nil)

            // Clear the root view controller
            thisWindow.rootViewController = nil
            self.preSetupSteps()
        }
    }

    @objc
    func updateUserThemePreference() {
        DispatchQueue.main.async {
            guard let thisWindow = self.window else { return }
            thisWindow.overrideUserInterfaceStyle = UserDefaults.userPreferredDarkTheme ? .dark : .light
        }
    }

	/// Sets the correct Google Services  plist file
	private func setFirebaseConfiguration() {

		guard let filePath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") else {
			let properties = ["error_message": "gs_info_file_missing"]
			BWAnalytics.logEventWithParameters(itemName: ._20200112_ERR,
			                                   properties: properties)
			assertionFailure("Couldn't load google services file")
			return
		}

		if let fboptions = FirebaseOptions(contentsOfFile: filePath) {
            FirebaseApp.configure(options: fboptions)
            #if DEBUG
            Analytics.setUserProperty("debug", forName: "user_type")
            #endif
		} else {
			let properties = ["error_message": "firebase_config_failed"]
			BWAnalytics.logEventWithParameters(itemName: ._20200112_ERR,
			                                   properties: properties)
			assertionFailure("Couldn't load Firebase config file")
		}
	}

	/// On Demand Resources
	/// Use for another resource heavy view
	/// Inspired by https://www.youtube.com/watch?v=B5RV8p4-9a8&t=178s
	func requestResourceWith(tag: [String],
	                         onSuccess: @escaping () -> Void,
	                         onFailure _: @escaping (NSError) -> Void) {
		resourceRequest = NSBundleResourceRequest(tags: Set(tag))

		guard let request = resourceRequest else { return }

		request.endAccessingResources()
		request.loadingPriority = NSBundleResourceRequestLoadingPriorityUrgent
		request.conditionallyBeginAccessingResources { areResourcesAvailable in

			DispatchQueue.main.async {
				if !areResourcesAvailable {
					request.beginAccessingResources { error in
						guard error != nil else {
							let properties: [String: String] = ["error_type": "on_demand_resources_not_found",
							                                    "error_description": "\(error.debugDescription)"]
							BWAnalytics.logEventWithParameters(itemName: ._20200112_ERR,
							                                   properties: properties)

							return
						}
						onSuccess()
					}
				} else {
					onSuccess()
				}
			}
		}
	}
}
