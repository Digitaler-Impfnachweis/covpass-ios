//
//  AcousticFeedbackSettingsSceneFactory.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import UIKit

struct AcousticFeedbackSettingsSceneFactory: SceneFactory {
    private let router: AcousticFeedbackSettingsRouterProtocol

    init(router: AcousticFeedbackSettingsRouterProtocol) {
        self.router = router
    }

    func make() -> UIViewController {
        guard let audioPlayer = AudioPlayer() else {
            fatalError("Failed to instantiate audio player.")
        }
        let persistence = UserDefaultsPersistence()
        let viewModel = AcousticFeedbackSettingsViewModel(
            audioPlayer: audioPlayer,
            persistence: persistence,
            router: router
        )
        let viewController = AcousticFeedbackSettingsViewController(
            viewModel: viewModel
        )
        
        return viewController
    }
}
