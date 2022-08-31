//
//  AcousticFeedbackSettingsViewModelTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCheckApp
import XCTest

class AcousticFeedbackSettingsViewModelTests: XCTestCase {
    private var audioPlayer: AudioPlayerMock!
    private var persistence: MockPersistence!
    private var sut: AcousticFeedbackSettingsViewModel!

    override func setUpWithError() throws {
        audioPlayer = .init()
        persistence = .init()
        sut = .init(
            audioPlayer: audioPlayer,
            persistence: persistence,
            router: AcousticFeedbackSettingsRouterMock()
        )
    }

    override func tearDownWithError() throws {
        audioPlayer = nil
        persistence = nil
        sut = nil
    }

    func testEnableAcousticFeedback_persistenc_false() {
        // When
        let isEnabled = sut.enableAcousticFeedback

        // Then
        XCTAssertFalse(isEnabled)
    }

    func testEnableAcousticFeedback_persistence_true() {
        // Given
        persistence.enableAcousticFeedback = true

        // When
        let isEnabled = sut.enableAcousticFeedback

        // Then
        XCTAssertTrue(isEnabled)
    }

    func testEnableAcousticFeedback_set_true() {
        // When
        sut.enableAcousticFeedback = true

        // Then
        wait(for: [audioPlayer.playCovPassCheckAudioFeedbackActivatedExpectation], timeout: 1)
        XCTAssertTrue(persistence.enableAcousticFeedback)
    }

    func testEnableAcousticFeedback_set_false() {
        // Give
        audioPlayer.playCovPassCheckAudioFeedbackActivatedExpectation.isInverted = true
        // When
        sut.enableAcousticFeedback = false

        // Then
        wait(for: [audioPlayer.playCovPassCheckAudioFeedbackActivatedExpectation], timeout: 1)
        XCTAssertFalse(persistence.enableAcousticFeedback)
    }
}
