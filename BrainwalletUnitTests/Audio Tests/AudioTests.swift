//
//  AudioTests.swift
//  BrainwalletUnitTests
//
//  Created by Kerry Washington on 12/02/2026.
//  Copyright © 2026 Grunt Software, LTD. All rights reserved.
//

import Testing
import SwiftUI
import AudioToolbox

@testable import brainwallet


class MockAudioServices: AudioServicesProtocol {

    var createCalled = false
    var addCompletionCalled = false
    var playCalled = false

    func createSystemSoundID(url: CFURL, id: inout SystemSoundID) {
        createCalled = true
        id = 123
    }

    func addCompletion(id: SystemSoundID) {
        addCompletionCalled = true
    }

    func play(id: SystemSoundID) {
        playCalled = true
    }

    func dispose(id: SystemSoundID) {}
}
