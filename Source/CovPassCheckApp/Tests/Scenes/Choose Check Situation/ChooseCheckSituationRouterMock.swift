//
//  ChooseCheckSituationRouterMock.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCheckApp
import CovPassUI

class ChooseCheckSituationRouterMock: ChooseCheckSituationRouterProtocol {
    var sceneCoordinator: SceneCoordinator = SceneCoordinatorMock()
}
