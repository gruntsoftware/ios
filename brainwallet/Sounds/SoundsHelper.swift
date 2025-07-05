//
//  SoundsHelper.swift
//  brainwallet
//
//  Created by Kerry Washington on 20/06/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//
import Foundation
import AudioToolbox

class SoundsHelper : NSObject {

    override init() {

    }

   func play(filename: String, type: String = "mp3") {
        if let url = Bundle.main.url(forResource: filename, withExtension: type) {
            var id: SystemSoundID = 0
            AudioServicesCreateSystemSoundID(url as CFURL, &id)
            AudioServicesAddSystemSoundCompletion(id, nil, nil, { soundId, _ in
                AudioServicesDisposeSystemSoundID(soundId)
            }, nil)
            AudioServicesPlaySystemSound(id)
        } else {
            debugPrint("::: ERROR: NO AUDIO FILE FOUND")
        }
    }
}
