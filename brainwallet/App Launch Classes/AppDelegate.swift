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
	var applicationController = ApplicationController()
	var remoteConfigurationHelper: RemoteConfigHelper?

    /// The window lives in SceneDelegate. libGDX still sets `UIApplicationDelegate.window` to its game window
    /// (crashed with "unrecognized selector setWindow:"), so hand that to ApplicationController to attach to the scene.
    var window: UIWindow? {
        get { applicationController.window }
        set { applicationController.adoptGameWindow(newValue) }
    }

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        if ProcessInfo.processInfo.environment["IS_RUNNING_UNIT_TESTS"] == "1" {
            return true
        }

        clearNotificationBadge()

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

        // Window, theme and wipe handling live in SceneDelegate
        return true
	}

    func application(_ application: UIApplication,
                     configurationForConnecting connectingSceneSession: UISceneSession,
                     options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        let config = UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
        config.delegateClass = SceneDelegate.self
        return config
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

	/// Called at launch and from SceneDelegate.sceneDidBecomeActive
	func clearNotificationBadge() {
		UserDefaults.pendingNotificationBadgeCount = 0
		UNUserNotificationCenter.current().setBadgeCount(0) { error in
            if let error = error {
                debugPrint("Failed to set badge count: \(error.localizedDescription)")
            }
        }
		/// Activating for  future use
        /// AppsFlyerLib.shared().start()
	}

	func application(_: UIApplication,
                     shouldAllowExtensionPointIdentifier _: UIApplication.ExtensionPointIdentifier) -> Bool {
		return false // disable extensions such as custom keyboards for security purposes
	}

    func application(_: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
          Messaging.messaging().apnsToken = deviceToken
    }

	func application(_: UIApplication, didReceiveRemoteNotification remoteNotificationDictionary: [AnyHashable: Any],
	                 fetchCompletionHandler _: @escaping (UIBackgroundFetchResult) -> Void) {
        debugPrint(":::: did receive rn \(remoteNotificationDictionary.debugDescription)")
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
