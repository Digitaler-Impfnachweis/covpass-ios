//
//  OnbordingRouterMock.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

@testable import VaccinationUI
import Foundation

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
