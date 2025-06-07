import AppsFlyerLib
import Firebase
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
		requestResourceWith(tag: ["initial-resources", "speakTag"]) { [self] in

			// Language
            Bundle.setLanguage(UserDefaults.selectedLanguage)
            
            // Locale and fetch access
            // DEV: Break here to test Locale/Matrix
            let countryRussia = MoonpayCountryData(alphaCode2Char: "RU",
                                                   alphaCode3Char: "RUS",
                                                   isBuyAllowed: false,
                                                   isSellAllowed: false,
                                                   countryName: "Russia",
                                                   isAllowedInCountry: false)

            let currentLocaleID = Locale.current.region?.identifier ?? countryRussia.alphaCode2Char
            debugPrint(":::::: Current Locale ID: \(currentLocaleID)")
            _ = NetworkHelper.init().fetchCurrenciesCountries(completion:  { countryData  in
                
                let currentMoonPayCountry = countryData.filter { $0.alphaCode2Char == currentLocaleID }.first ?? countryRussia
                
                let isBuyAllowed = currentMoonPayCountry.isBuyAllowed
                if isBuyAllowed {
                    UserDefaults.standard.set(isBuyAllowed, forKey: userCurrentLocaleMPApprovedKey)
                    debugPrint(":::::: buyIsAllowed: \(isBuyAllowed)")
                } else {
                    UserDefaults.standard.set(false, forKey: userCurrentLocaleMPApprovedKey)
                }
                
                UserDefaults.standard.synchronize()
            })

			// Ops
			let startDate = Partner.partnerKeyPath(name: .walletStart)
			if startDate == "error-brainwallet-start-key" {
				let errorDescription = "partnerkey_data_missing"
				LWAnalytics.logEventWithParameters(itemName: ._20200112_ERR, properties: ["error": errorDescription])
			}
			// Firebase
			self.setFirebaseConfiguration()

			// AF
			AppsFlyerLib.shared().appsFlyerDevKey = Partner.partnerKeyPath(name: .prodAF)
			AppsFlyerLib.shared().appleAppID = "6444157498"

			// Remote Config
			self.remoteConfigurationHelper = RemoteConfigHelper.sharedInstance

			let current = UNUserNotificationCenter.current()

			current.getNotificationSettings(completionHandler: { settings in

				debugPrint(settings.debugDescription)
				if settings.authorizationStatus == .denied {
				}
			})

		} onFailure: { error in

			let properties: [String: String] = ["error_type": "on_demand_resources_not_found",
			                                    "error_description": "\(error.debugDescription)"]
			LWAnalytics.logEventWithParameters(itemName: ._20200112_ERR,
			                                   properties: properties)
		}
        
		guard let thisWindow = window else { return false }
        // Set global themse
		thisWindow.tintColor = BrainwalletUIColor.surface
        thisWindow.overrideUserInterfaceStyle = UserDefaults.standard.bool(forKey: userDidPreferDarkModeKey) ? .dark: .light
        
        UIView.appearance(whenContainedInInstancesOf: [UIAlertController.self]).tintColor = BrainwalletUIColor.content
            
		UIView.swizzleSetFrame()

		applicationController.launch(application: application, window: thisWindow)

		LWAnalytics.logEventWithParameters(itemName: ._20191105_AL)

		return true
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
		LWAnalytics.logEventWithParameters(itemName: ._20231225_UAP, properties: acceptanceDict)
	}

	func application(_: UIApplication, didReceiveRemoteNotification _: [AnyHashable: Any],
	                 fetchCompletionHandler _: @escaping (UIBackgroundFetchResult) -> Void) {}

	/// Sets the correct Google Services  plist file
	private func setFirebaseConfiguration() {

		guard let filePath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist") else {
			let properties = ["error_message": "gs_info_file_missing"]
			LWAnalytics.logEventWithParameters(itemName: ._20200112_ERR,
			                                   properties: properties)
			assertionFailure("Couldn't load google services file")
			return
		}

		if let fboptions = FirebaseOptions(contentsOfFile: filePath) {
			FirebaseApp.configure(options: fboptions)
		} else {
			let properties = ["error_message": "firebase_config_failed"]
			LWAnalytics.logEventWithParameters(itemName: ._20200112_ERR,
			                                   properties: properties)
			assertionFailure("Couldn't load Firebase config file")
		}
	}
    
    /// Update Theme
    func updatePreferredTheme() {
        guard let window = window else { return }
        // Set global theme
        window.overrideUserInterfaceStyle = UserDefaults.standard.bool(forKey: userDidPreferDarkModeKey) ? .dark: .light
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
							LWAnalytics.logEventWithParameters(itemName: ._20200112_ERR,
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
