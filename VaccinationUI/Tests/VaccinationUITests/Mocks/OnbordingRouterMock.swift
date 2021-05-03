//
//  OnbordingRouterMock.swift
//  
//
//  Created by Sebastian Maschinski on 03.05.21.
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
