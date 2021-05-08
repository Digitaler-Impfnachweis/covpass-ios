//
//  CertificateRouter.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import PromiseKit
import UIKit
import VaccinationUI

class VaccinationDetailRouter: VaccinationDetailRouterProtocol, DialogRouterProtocol {
    // MARK: - Properties

    let sceneCoordinator: SceneCoordinator

    // MARK: - Lifecycle

    init(sceneCoordinator: SceneCoordinator) {
        self.sceneCoordinator = sceneCoordinator
    }

    // MARK: - Methods

    func showHowToScan() -> Promise<Void> {
        sceneCoordinator.present(
            HowToScanSceneFactory(
                router: HowToScanRouter(sceneCoordinator: sceneCoordinator)
            )
        )
    }

    func showScanner() -> Promise<ScanResult> {
        sceneCoordinator.present(
            ScanSceneFactory(
                cameraAccessProvider: CameraAccessProvider(
                    router: DialogRouter(sceneCoordinator: sceneCoordinator)
                )
            )
        )
    }

    func showCertificateOverview() -> Promise<Void> {
        .init { seal in
            sceneCoordinator.pop()
            seal.fulfill_()
        }
    }
}
