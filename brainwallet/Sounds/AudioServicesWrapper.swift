//
//  AudioServicesWrapper.swift
//  brainwallet
//
//  Created by Kerry Washington on 12/02/2026.
//  Copyright © 2026 Grunt Software, LTD. All rights reserved.
//

import AudioToolbox

protocol AudioServicesProtocol {
    func createSystemSoundID(url: CFURL, id: inout SystemSoundID)
    func addCompletion(id: SystemSoundID)
    func play(id: SystemSoundID)
    func dispose(id: SystemSoundID)
}

class AudioServicesWrapper: AudioServicesProtocol {

    func createSystemSoundID(url: CFURL, id: inout SystemSoundID) {
        AudioServicesCreateSystemSoundID(url, &id)
    }

    func addCompletion(id: SystemSoundID) {
        AudioServicesAddSystemSoundCompletion(id, nil, nil, { soundId, _ in
            AudioServicesDisposeSystemSoundID(soundId)
        }, nil)
    }

    func play(id: SystemSoundID) {
        AudioServicesPlaySystemSound(id)
    }

    func dispose(id: SystemSoundID) {
        AudioServicesDisposeSystemSoundID(id)
    }
}
