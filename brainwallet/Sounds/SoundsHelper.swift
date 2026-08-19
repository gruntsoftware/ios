//
//  SoundsHelper.swift
//  brainwallet
//
//  Created by Kerry Washington on 20/06/2025.
//  Copyright © 2025 Grunt Software, LTD. All rights reserved.
//
import Foundation
import AudioToolbox

class SoundsHelper {

    private let audioService: AudioServicesProtocol
    private let bundle: Bundle

    init(audioService: AudioServicesProtocol = AudioServicesWrapper(),
         bundle: Bundle = .main) {
        self.audioService = audioService
        self.bundle = bundle
    }

    func play(filename: String, type: String = "mp3") {
        guard let url = bundle.url(forResource: filename, withExtension: type) else {
            debugPrint("::: ERROR: NO AUDIO FILE FOUND")
            return
        }

        var id: SystemSoundID = 0
        audioService.createSystemSoundID(url: url as CFURL, id: &id)
        audioService.addCompletion(id: id)
        audioService.play(id: id)
    }
}
