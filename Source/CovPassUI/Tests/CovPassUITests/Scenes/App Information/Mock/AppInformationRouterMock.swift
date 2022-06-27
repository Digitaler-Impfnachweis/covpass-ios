//
//  AppInformationRouterMock.swift
//  
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import XCTest

struct AppInformationRouterMock: AppInformationRouterProtocol {
    var sceneCoordinator: SceneCoordinator = SceneCoordinatorMock()
    let showSceneExpectation = XCTestExpectation()

    func showScene(_ scene: SceneFactory) {
        showSceneExpectation.fulfill()
    }
}
