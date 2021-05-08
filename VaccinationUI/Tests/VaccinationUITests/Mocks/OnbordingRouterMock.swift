//
//  OnbordingRouterMock.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation
@testable import VaccinationUI

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
