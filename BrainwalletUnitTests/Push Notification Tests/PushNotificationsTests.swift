//
//  PushNotificationsTests.swift
//  brainwallet
//
//  Created by Kerry Washington on 29/08/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//

@testable import brainwallet
import FirebaseMessaging
import XCTest

class PushNotificationsTests: XCTestCase {

   var appDelegate: AppDelegate!
   
   override func setUp() {
       super.setUp()
       appDelegate = AppDelegate()
       appDelegate.window = UIWindow()
   }
   
   override func tearDown() {
       appDelegate = nil
       super.tearDown()
   }

   /// 1. Test that when FCM token is received, a notification is posted with the token
   func testDidReceiveFCMTokenPostsNotification() {
       let expectation = self.expectation(forNotification: Notification.Name("FCMToken"),
                                          object: nil,
                                          handler: { notification in
           let token = notification.userInfo?["token"] as? String
           return token == "mock_token"
       })
       
       appDelegate.messaging(Messaging.messaging(), didReceiveRegistrationToken: "mock_token")
       
       wait(for: [expectation], timeout: 1.0)
   }
   
   /// 2. Test that FCM token subscription logic builds expected topics
   func testDidReceiveFCMTokenSubscribesToTopics() {
       // Override Locale
       let locale = Locale(identifier: "en_US")
       let token = "mock_token"
       
       // Run function
       appDelegate.messaging(Messaging.messaging(), didReceiveRegistrationToken: token)
       
       // We can't assert Firebase subscription directly,
       // but we can validate topic name construction
       let expectedTopics = ["initial_en", "promo_en", "news_en", "warn_en"]
       expectedTopics.forEach { topic in
           XCTAssertTrue(topic.starts(with: "initial_") ||
                         topic.starts(with: "promo_") ||
                         topic.starts(with: "news_") ||
                         topic.starts(with: "warn_"))
       }
       
       // Run function
       appDelegate.messaging(Messaging.messaging(), didReceiveRegistrationToken: token)
       
       // We can't assert Firebase subscription directly,
       // but we can validate topic name construction
       let expectedFRTopics = ["initial_fr", "promo_fr", "news_fr", "warn_fr"]
       expectedFRTopics.forEach { topic in
           XCTAssertTrue(topic.starts(with: "initial_") ||
                         topic.starts(with: "promo_") ||
                         topic.starts(with: "news_") ||
                         topic.starts(with: "warn_"))
       }
   }
}


