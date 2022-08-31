//
//  AudioPlayer.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import AVFoundation
import Foundation

public final class AudioPlayer: AudioPlayerProtocol {
    private let persistence: Persistence
    private let covPassCheckAudioFeedbackActivatedURL: URL
    private let covPassCheckCertificateScannedURL: URL
    private let session: AVAudioSession
    private var player: AVAudioPlayer!

    public init(
        covPassCheckAudioFeedbackActivatedURL: URL,
        covPassCheckCertificateScannedURL: URL,
        persistence: Persistence,
        session: AVAudioSession
    ) {
        self.persistence = persistence
        self.covPassCheckAudioFeedbackActivatedURL = covPassCheckAudioFeedbackActivatedURL
        self.covPassCheckCertificateScannedURL = covPassCheckCertificateScannedURL
        self.session = session
    }

    public func playCovPassCheckAudioFeedbackActivated() -> Bool {
        play(covPassCheckAudioFeedbackActivatedURL)
    }

    private func play(_ url: URL) -> Bool {
        do {
            player = try AVAudioPlayer(
                contentsOf: url
            )
            try session.setActive(true)
            return player.play()
        } catch {
            print("Error playing audio file \(url): \(error)")
            return false
        }
    }

    public func playCovPassCheckCertificateScannedIfEnabled() -> Bool {
        persistence.enableAcousticFeedback ?
            play(covPassCheckCertificateScannedURL) :
            false
    }
}
