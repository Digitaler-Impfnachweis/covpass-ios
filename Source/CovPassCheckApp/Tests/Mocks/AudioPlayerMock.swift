//
//  AudioPlayerMock.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCommon
import Foundation
import XCTest

struct AudioPlayerMock: AudioPlayerProtocol {
    let playCovPassCheckAudioFeedbackActivatedExpectation = XCTestExpectation(
        description: "playCovPassCheckAudioFeedbackActivatedExpectation"
    )

    let playCovPassCheckCertificateScannedIfEnabledExpectation = XCTestExpectation(
        description: "playCovPassCheckCertificateScannedIfEnabledExpectation"
    )

    func playCovPassCheckAudioFeedbackActivated() -> Bool {
        playCovPassCheckAudioFeedbackActivatedExpectation.fulfill()
        return true
    }

    func playCovPassCheckCertificateScannedIfEnabled() -> Bool {
        playCovPassCheckCertificateScannedIfEnabledExpectation.fulfill()
        return true
    }
}

