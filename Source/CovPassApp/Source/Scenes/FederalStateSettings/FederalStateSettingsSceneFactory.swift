//
//  FederalStateSettingsSceneFactory.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import CovPassCommon
import UIKit

struct FederalStateSettingsSceneFactory: SceneFactory {
    // MARK: - Properties

    private let sceneCoordinator: SceneCoordinator

    // MARK: - Lifecycle

    init(sceneCoordinator: SceneCoordinator) {
        self.sceneCoordinator = sceneCoordinator
    }

    func make() -> UIViewController {
        FederalStateSettingsViewController(
            viewModel: FederalStateSettingsViewModel(
                router: FederalStateSettingsRouter(
                    sceneCoordinator: sceneCoordinator
                ),
                userDefaults: UserDefaultsPersistence()
            )
        )
    }
}
