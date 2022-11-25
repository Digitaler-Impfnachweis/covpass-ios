//
//  AVAudioSession+CovPassCheckTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import AVFoundation
@testable import CovPassCheckApp
import XCTest

class AVAudioSession_CovPassCheckTests: XCTestCase {
    func testCovPassCheck() {
        // When
        let sut = AVAudioSession.covPassCheck

        // Then
        XCTAssertNotNil(sut)
        XCTAssertEqual(sut?.category, .playback)
    }
}
