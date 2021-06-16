//
//  ValidatorOverviewRouter.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import PromiseKit
import Scanner
import UIKit

class ValidatorOverviewRouter: ValidatorOverviewRouterProtocol {
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
            AppInformationSceneFactory(
                router: AppInformationRouter(sceneCoordinator: sceneCoordinator)
            )
        )
    }
}
