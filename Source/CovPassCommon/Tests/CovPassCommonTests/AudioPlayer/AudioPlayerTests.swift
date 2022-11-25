//
//  AudioPlayerTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import AVFAudio
@testable import CovPassCommon
import XCTest

class AudioPlayerTests: XCTestCase {
    private var audioSession: AVAudioSession!
    private var persistence: MockPersistence!
    private var sut: AudioPlayer!

    override func setUpWithError() throws {
        let url = try XCTUnwrap(
            Bundle.module.url(forResource: "sample.wav", withExtension: nil)
        )
        audioSession = .sharedInstance()
        try audioSession.setCategory(.playback, options: .duckOthers)
        persistence = .init()
        persistence.enableAcousticFeedback = true
        configureSut(url: url)
    }

    private func configureSut(url: URL) {
        sut = .init(
            covPassCheckAudioFeedbackActivatedURL: url,
            covPassCheckCertificateScannedURL: url,
            persistence: persistence,
            session: audioSession
        )
    }

    override func tearDownWithError() throws {
        audioSession = nil
        persistence = nil
        sut = nil
    }

    func testPlayCovPassCheckCertificateScannedIfEnabled_file_valid() {
        // When
        let played = sut.playCovPassCheckCertificateScannedIfEnabled()

        // Then
        XCTAssertTrue(played)
    }

    func testPlayCovPassCheckCertificateScannedIfEnabled_file_invalid() {
        // Given
        let url = FileManager.default.temporaryDirectory
        configureSut(url: url)

        // When
        let played = sut.playCovPassCheckCertificateScannedIfEnabled()

        // Then
        XCTAssertFalse(played)
    }

    func testPlayCovPassCheckCertificateScannedIfEnabled_not_enabled() {
        // Given
        persistence.enableAcousticFeedback = false

        // When
        let played = sut.playCovPassCheckCertificateScannedIfEnabled()

        // Then
        XCTAssertFalse(played)
    }

    func testPlayCovPassCheckAudioFeedbackActivated_file_valid() {
        // When
        let played = sut.playCovPassCheckAudioFeedbackActivated()

        // Then
        XCTAssertTrue(played)
    }

    func testPlayCovPassCheckAudioFeedbackActivated_file_invalid() {
        // Given
        let url = FileManager.default.temporaryDirectory
        configureSut(url: url)

        // When
        let played = sut.playCovPassCheckAudioFeedbackActivated()

        // Then
        XCTAssertFalse(played)
    }
}
