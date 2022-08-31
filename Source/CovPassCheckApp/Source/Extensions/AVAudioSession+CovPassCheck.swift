//
//  AVAudioSession+CovPassCheck.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import AVFoundation

extension AVAudioSession {
    static let covPassCheck: AVAudioSession? = {
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback, options: .duckOthers)
            return session
        } catch {
            return nil
        }
    }()
}
