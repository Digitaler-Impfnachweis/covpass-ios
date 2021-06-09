//
//  CertificateDetailRouter.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import PromiseKit
import UIKit

class CertificateDetailRouter: CertificateDetailRouterProtocol, DialogRouterProtocol {
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

    func showCertificate(for token: ExtendedCBORWebToken) -> Promise<Void> {
        sceneCoordinator.present(
            CertificateSceneFactory(token: token)
        )
    }

    func showDetail(for certificate: ExtendedCBORWebToken) -> Promise<CertificateDetailSceneResult> {
        sceneCoordinator.push(
            CertificateItemDetailSceneFactory(
                router: CertificateItemDetailRouter(sceneCoordinator: sceneCoordinator),
                certificate: certificate
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
