//
//  ScanResultRouter.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation
import PromiseKit
import Scanner
import VaccinationUI

struct ValidationResultRouter: ValidationResultRouterProtocol {
    // MARK: - Properties

    let sceneCoordinator: SceneCoordinator

    // MARK: - Lifecycle

    init(sceneCoordinator: SceneCoordinator) {
        self.sceneCoordinator = sceneCoordinator
    }

    // MARK: - Methods

    func showStart() {
        sceneCoordinator.dimiss()
    }

    func scanQRCode() -> Promise<ScanResult> {
        sceneCoordinator.present(
            ScanSceneFactory()
        )
    }
}
