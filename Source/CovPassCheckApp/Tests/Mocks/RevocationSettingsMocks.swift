//
//  RevocationSettingsMocks.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
@testable import CovPassCheckApp
import CovPassUI

class RevocationSettingsRouterMock: RevocationSettingsRouterProtocol {
    var sceneCoordinator: SceneCoordinator = SceneCoordinatorMock()
}
