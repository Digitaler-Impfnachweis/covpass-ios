//
//  TrustedListDetailsRouter.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import PromiseKit
import Scanner
import UIKit

class TrustedListDetailsRouter: TrustedListDetailsRouterProtocol {

    // MARK: - Properties

    let sceneCoordinator: SceneCoordinator

    // MARK: - Lifecycle

    init(sceneCoordinator: SceneCoordinator) {
        self.sceneCoordinator = sceneCoordinator
    }

    // MARK: - Methods

    func showError(error: Error) {
        sceneCoordinator.present(
            TrustedListDetailsSceneFactory(sceneCoordinator: sceneCoordinator)
        )
    }
}
