//
//  AudioPlayer+Factory.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import Foundation
import AVFAudio

private enum Constants {
    static let audioFeedbackActivatedResource = "CovpassCheck-Activated.wav"
    static let certificateScannedResource = "CovpassCheck-Certificate-scanned.wav"
}

extension AudioPlayer {
    convenience init?() {
        let persistence = UserDefaultsPersistence()
        let bundle = Bundle.main
        guard let audioFeedbackActivatedURL: URL = bundle.url(forResource: Constants.audioFeedbackActivatedResource, withExtension: nil),
              let certificateScannedURL: URL = bundle.url(forResource: Constants.certificateScannedResource, withExtension: nil),
              let session = AVAudioSession.covPassCheck
        else {
            return nil
        }

        self.init(
            covPassCheckAudioFeedbackActivatedURL: audioFeedbackActivatedURL,
            covPassCheckCertificateScannedURL: certificateScannedURL,
            persistence: persistence,
            session: session
        )
    }
}
