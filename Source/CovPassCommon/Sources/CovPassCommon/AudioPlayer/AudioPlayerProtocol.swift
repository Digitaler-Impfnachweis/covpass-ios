//
//  AudioPlayerProtocol.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

public protocol AudioPlayerProtocol {
    /// Asynchronously plays the sound for activation of acoustic feedback.
    /// - Returns: `true`, if sound is played, or `false` in case of error.
    func playCovPassCheckAudioFeedbackActivated() -> Bool

    /// Asynchronously plays the sound for the the scan of a certificate, if the acoustic feedback feature
    /// is enabled.
    /// - Returns: `true`, if sound is played, or `false` in case of error or if the feature is disabled.
    func playCovPassCheckCertificateScannedIfEnabled() -> Bool
}
