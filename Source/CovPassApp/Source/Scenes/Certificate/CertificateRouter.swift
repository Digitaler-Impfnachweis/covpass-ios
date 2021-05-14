//
//  CertificateRouter.swift
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

class CertificateRouter: CertificateRouterProtocol, DialogRouterProtocol {
    // MARK: - Properties

    let sceneCoordinator: SceneCoordinator
    weak var delegate: CertificateDetailDelegate?

    // MARK: - Lifecycle

    init(sceneCoordinator: SceneCoordinator) {
        self.sceneCoordinator = sceneCoordinator
    }

    // MARK: - Methods

    func showCertificates(_ certificates: [ExtendedCBORWebToken]) {
        sceneCoordinator.push(
            VaccinationDetailSceneFactory(
                router: VaccinationDetailRouter(sceneCoordinator: sceneCoordinator),
                repository: VaccinationRepository(service: APIService.create(), parser: QRCoder()),
                certificates: certificates,
                delegate: delegate
            )
        )
    }

    func showHowToScan() -> Promise<Void> {
        sceneCoordinator.present(
            HowToScanSceneFactory(
                router: HowToScanRouter(sceneCoordinator: sceneCoordinator)
            )
        )
    }

    func scanQRCode() -> Promise<ScanResult> {
        sceneCoordinator.present(
            ScanSceneFactory(
                cameraAccessProvider: CameraAccessProvider(
                    router: DialogRouter(sceneCoordinator: sceneCoordinator)
                )
            )
        )
    }

    func showAppInformation() {
        sceneCoordinator.push(
            PassAppInformationSceneFactory(
                router: AppInformationRouter(sceneCoordinator: sceneCoordinator)
            )
        )
    }
}
