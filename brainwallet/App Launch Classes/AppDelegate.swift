import FirebaseMessaging
import Firebase
import FirebaseCore
import FirebaseAnalytics
import FirebasePerformance
import LocalAuthentication
import SwiftUI
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate {
	var window: UIWindow?
	var applicationController = ApplicationController()
	var remoteConfigurationHelper: RemoteConfigHelper?
	var resourceRequest: NSBundleResourceRequest?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        if ProcessInfo.processInfo.environment["IS_RUNNING_UNIT_TESTS"] == "1" {
            return true
        }
        
        UNUserNotificationCenter.current().setBadgeCount(0) { _ in }
        
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

            let currentMoonPayCountry = countryData
                .filter { $0.alphaCode2Char == regionCode2Char }
                .first ?? countryRussia
            UserDefaults.userCanBuyInCurrentLocale = currentMoonPayCountry.isBuyAllowed
        })

        // Ops
        _ = Partner.partnerKeyPath(name: .walletStart)
        
        // AF
        /// Activating for  future use
        /// AppsFlyerLib.shared().appsFlyerDevKey = Partner.partnerKeyPath(name: .prodAF)
        /// AppsFlyerLib.shared().appleAppID = BrainwalletAppStore.adamIDString

        // Firebase
        if FirebaseApp.app() == nil {
            self.setFirebaseConfiguration()
        }
        
        // Firebase Remote Config
        self.remoteConfigurationHelper = RemoteConfigHelper.sharedInstance
        

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

        guard let thisWindow = window else { return false }

        // Set global themes
        thisWindow.overrideUserInterfaceStyle = UserDefaults.userPreferredDarkTheme ? .dark: .light

        UIView.appearance(whenContainedInInstancesOf:
            [UIAlertController.self])
                .tintColor = BrainwalletUIColor.content

        UIView.swizzleSetFrame()
        self.applicationController.launch(application: UIApplication.shared, window: thisWindow)
         
        return true
	}
     
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        // Receved FCM Token
        let dataDict: [String: String] = ["token" : fcmToken ?? ""]
        NotificationCenter.default.post(name: Notification.Name("FCMToken"), object: nil, userInfo: dataDict)
        // Messaging topic clear all subscriptions
        Messaging.messaging().unsubscribe(fromTopic: "/topics/*") { error in
            if error != nil {
                debugPrint("Error unsubscribing from topics: \(String(describing: error))")
            }
        }
        // Messaging topic subscription
        if let localeIdentifier = Locale.current.identifier as String?,
        (fcmToken != nil) {
           let localePrefix: String = localeIdentifier.components(separatedBy: "_").first ?? "en"
           let initialTopic: String = "initial_\(localePrefix)"
           let promoTopic: String = "promo_\(localePrefix)"
           let newsTopic: String = "news_\(localePrefix)"
           let warnTopic: String = "warn_\(localePrefix)"

           let topicsArray: [String] = [initialTopic, promoTopic, newsTopic, warnTopic]
           debugPrint("::: fcmToken: \(String(describing: fcmToken))")
           topicsArray.forEach { topic in
               Messaging.messaging().subscribe(toTopic: topic) { error in
                   if error != nil {
                       debugPrint("Error subscribing from topics: \(String(describing: error))")
                   }
               }
           }
        }
    }

	func applicationDidBecomeActive(_: UIApplication) {
		UNUserNotificationCenter.current().setBadgeCount(0) { error in
            if let error = error {
                debugPrint("Failed to set badge count: \(error.localizedDescription)")
            }
        }
		/// Activating for  future use
        /// AppsFlyerLib.shared().start()
	}

	func applicationWillEnterForeground(_: UIApplication) {
		applicationController.willEnterForeground()
	}

	func applicationDidEnterBackground(_: UIApplication) {
		applicationController.didEnterBackground()
	}

	func application(_: UIApplication,
                     shouldAllowExtensionPointIdentifier _: UIApplication.ExtensionPointIdentifier) -> Bool {
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

    func application(_: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
          Messaging.messaging().apnsToken = deviceToken
    }

	func application(_: UIApplication, didReceiveRemoteNotification remoteNotificationDictionary: [AnyHashable: Any],
	                 fetchCompletionHandler _: @escaping (UIBackgroundFetchResult) -> Void) {
        debugPrint(":::: did receive rn \(remoteNotificationDictionary.debugDescription)")
    }

    @objc
    private func restartAfterWipedWallet() {
        // Change State
        debugPrint(":::: Restarting after wiping wallet")

        DispatchQueue.main.async {
            guard let thisWindow = self.window else { return }

            thisWindow.rootViewController?.dismiss(animated: false, completion: nil)

            // Clear the root view controller
            thisWindow.rootViewController = nil
            /// TBD to restart the app
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
    func setFirebaseConfiguration() {
        guard FirebaseApp.app() == nil else { return }

        if let filePath = Bundle.main.path(forResource: "GoogleService-Info", ofType: "plist"),
           let options = FirebaseOptions(contentsOfFile: filePath) {
            // Production path — real plist present
            FirebaseApp.configure(options: options)
        } else {
            let options = FirebaseOptions(
                googleAppID: "1:000000000000:ios:0000000000000000000000",
                gcmSenderID: "000000000000"
            )
            options.projectID = "test-project"
            options.storageBucket = "test-project.firebasestorage.app"
            options.apiKey = "AIzaSy00000000000000000000000000000000"
            options.bundleID = Bundle.main.bundleIdentifier ?? "co.brainwallet.test"
            FirebaseApp.configure(options: options)
            
            // Stub config — disable everything that uses GoogleDataTransport upload,
            // or GDT fails to create its path and crashes on the fake project.
            Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(false)
            Analytics.setAnalyticsCollectionEnabled(false)
            // Performance monitoring off (it also feeds GDT):
            Performance.sharedInstance().isDataCollectionEnabled = false
            Performance.sharedInstance().isInstrumentationEnabled = false
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

extension AppDelegate: UNUserNotificationCenterDelegate {

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                               willPresent notification: UNNotification,
                               withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

        let userInfo = notification.request.content.userInfo
        debugPrint("Foreground notification received: \(userInfo)")
        completionHandler([.banner, .sound, .list])
    }
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                               didReceive response: UNNotificationResponse,
                               withCompletionHandler completionHandler: @escaping () -> Void) {

        let userInfo = response.notification.request.content.userInfo
        NotificationCenter.default
            .post(name: Notification.Name("didReceiveRemoteNotification"),
                  object: nil, userInfo: userInfo)
        debugPrint("User tapped notification: \(userInfo)")
        completionHandler()
    }

    func launchFCMessaging(completion: @escaping (Bool) -> Void) {
        Messaging.messaging().delegate = self
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                DispatchQueue.main.async {
                    UIApplication.shared.registerForRemoteNotifications()
                    completion(true)
                }
            }
            completion(false)
            if error != nil {
                debugPrint("Error messaging registration from topics: \(String(describing: error))") 
            }
        }
    }
}
