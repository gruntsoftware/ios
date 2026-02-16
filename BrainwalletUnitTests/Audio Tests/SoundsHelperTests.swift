//
//  SoundsHelperTests.swift
//  BrainwalletUnitTests
//
//  Created by Kerry Washington on 12/02/2026.
//  Copyright © 2026 Grunt Software, LTD. All rights reserved.
//
import XCTest
import Testing
import SwiftUI
import AudioToolbox

@testable import brainwallet

class SoundsHelperTests: XCTestCase {

    var mockAudio: MockAudioServices!
    var sut: SoundsHelper!

    override func setUp() {
        super.setUp()
        mockAudio = MockAudioServices()
        sut = SoundsHelper(audioService: mockAudio,
                           bundle: Bundle(for: Self.self))
    }

    func test_play_whenFileExists_callsAudioServices() {
        // Given
        let bundle = Bundle(for: Self.self)
        sut = SoundsHelper(audioService: mockAudio, bundle: bundle)

        // When
        sut.play(filename: "errorsound", type: "mp3")

        // Then
        XCTAssertTrue(mockAudio.createCalled)
        XCTAssertTrue(mockAudio.addCompletionCalled)
        XCTAssertTrue(mockAudio.playCalled)
    }

    func test_play_whenFileDoesNotExist_doesNotCallAudioServices() {
        // Given
        let emptyBundle = Bundle()
        sut = SoundsHelper(audioService: mockAudio, bundle: emptyBundle)

        // When
        sut.play(filename: "non_existing_file")

        // Then
        XCTAssertFalse(mockAudio.createCalled)
        XCTAssertFalse(mockAudio.addCompletionCalled)
        XCTAssertFalse(mockAudio.playCalled)
    }
}
