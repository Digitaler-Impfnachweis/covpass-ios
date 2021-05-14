//
//  ValidatorRouter.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import PromiseKit
import Scanner
import UIKit
import CovPassCommon
import CovPassUI

class ValidatorRouter: ValidatorRouterProtocol {
    // MARK: - Properties

    let sceneCoordinator: SceneCoordinator

    // MARK: - Lifecycle

    init(sceneCoordinator: SceneCoordinator) {
        self.sceneCoordinator = sceneCoordinator
    }

    // MARK: - Methods

    func scanQRCode() -> Promise<ScanResult> {
        sceneCoordinator.present(
            ScanSceneFactory(
                cameraAccessProvider: CameraAccessProvider(
                    router: DialogRouter(sceneCoordinator: sceneCoordinator)
                )
            )
        )
    }

    func showCertificate(_ certificate: CBORWebToken?) {
        sceneCoordinator.present(
            ValidationResultSceneFactory(
                router: ValidationResultRouter(sceneCoordinator: sceneCoordinator),
                certificate: certificate
            )
        )
    }

    func showAppInformation() {
        sceneCoordinator.push(
            ValidatorAppInformationSceneFactory(
                router: AppInformationRouter(sceneCoordinator: sceneCoordinator)
            )
        )
    }
}
