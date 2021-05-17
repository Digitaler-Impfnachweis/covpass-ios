//
//  OnbordingRouterMock.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
@testable import CovPassUI

class OnboardingRouterMock: OnboardingRouterProtocol {
    let sceneCoordinator: SceneCoordinator

    init(sceneCoordinator: SceneCoordinator) {
        self.sceneCoordinator = sceneCoordinator
    }

    func showNextScene() {
        // ..
    }

    func showPreviousScene() {
        // ..
    }
}
