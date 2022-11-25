//
//  RevocationSettingsMocks.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCheckApp
import CovPassUI
import Foundation

class RevocationSettingsRouterMock: RevocationSettingsRouterProtocol {
    var sceneCoordinator: SceneCoordinator = SceneCoordinatorMock()
}
