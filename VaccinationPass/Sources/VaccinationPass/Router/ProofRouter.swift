//
//  File.swift
//  
//
//  Created by Sebastian Maschinski on 03.05.21.
//

import UIKit
import PromiseKit
import VaccinationUI
import VaccinationCommon

class ProofRouter: ProofRouterProtocol {
    // MARK: - Properties

    let sceneCoordinator: SceneCoordinator

    // MARK: - Lifecycle

    init(sceneCoordinator: SceneCoordinator) {
        self.sceneCoordinator = sceneCoordinator
    }

    // MARK: - Methods

    func showMoreInformation() {
        // TBD
    }
}
