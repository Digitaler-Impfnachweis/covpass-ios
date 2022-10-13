//
//  FederalStateSettingsRouterMock.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import PromiseKit

class FederalStateSettingsRouterMock: FederalStateSettingsRouterProtocol {
    var sceneCoordinator: SceneCoordinator = SceneCoordinatorMock()

    func showFederalStateSelection() -> Promise<Void> {
        .value
    }
}
