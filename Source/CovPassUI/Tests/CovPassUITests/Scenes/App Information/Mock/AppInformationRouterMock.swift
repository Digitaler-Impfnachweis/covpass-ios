//
//  AppInformationRouterMock.swift
//  
//
//  Created by Thomas Kuleßa on 09.02.22.
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
