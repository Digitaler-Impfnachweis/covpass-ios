//
//  SceneCoordinatorMock.swift
//  
//
//  Created by Sebastian Maschinski on 03.05.21.
//

@testable import VaccinationUI
import UIKit
import PromiseKit

class SceneCoordinatorMock: SceneCoordinator {
    func asRoot(_ factory: SceneFactory) {
        // ..
    }

    func push(_ factory: SceneFactory, animated: Bool) {
        // ..
    }

    func present(_ factory: SceneFactory, animated: Bool) {
        // ..
    }

    func present<Scene: ResolvableSceneFactory>(_ factory: Scene, animated: Bool) -> Promise<Scene.Result> {
        .init(error: ScenePresentationError.notPresentable)
    }
}
