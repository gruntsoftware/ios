//
//  MockAuthenticationChallengeSender.swift
//  brainwallet
//
//  Created by Kerry Washington on 8/17/26.
//  Copyright © 2026 Grunt Software, LTD. All rights reserved.
//
import BRCore
@testable import brainwallet
import XCTest

class MockAuthenticationChallengeSender: NSObject, URLAuthenticationChallengeSender {
    func use(_ credential: URLCredential, for challenge: URLAuthenticationChallenge) {}
    func continueWithoutCredential(for challenge: URLAuthenticationChallenge) {}
    func cancel(_ challenge: URLAuthenticationChallenge) {}
}
