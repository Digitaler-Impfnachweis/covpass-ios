//
//  AcousticFeedbackSettingsViewModel.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon

private enum Constants {
    static let header = "app_information_beep_when_checking_title".localized
    static let description = "app_information_beep_when_checking_message".localized
    static let switchLabel = "app_information_beep_when_checking_title".localized
}

final class AcousticFeedbackSettingsViewModel: AcousticFeedbackSettingsViewModelProtocol {
    let header = Constants.header
    let description = Constants.description
    let switchLabel = Constants.switchLabel
    var enableAcousticFeedback: Bool {
        get {
            persistence.enableAcousticFeedback
        }
        set {
            persistence.enableAcousticFeedback = newValue
            giveAcousticFeedbackIfEnabled()
        }
    }

    private let audioPlayer: AudioPlayerProtocol
    private var persistence: Persistence
    private let router: AcousticFeedbackSettingsRouterProtocol

    init(audioPlayer: AudioPlayerProtocol,
         persistence: Persistence,
         router: AcousticFeedbackSettingsRouterProtocol) {
        self.audioPlayer = audioPlayer
        self.persistence = persistence
        self.router = router
    }

    private func giveAcousticFeedbackIfEnabled() {
        guard persistence.enableAcousticFeedback else {
            return
        }
        _ = audioPlayer.playCovPassCheckAudioFeedbackActivated()
    }
}
