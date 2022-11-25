//
//  CertificatesOverviewPersonRouter.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import PromiseKit

class CertificatesOverviewPersonRouter: CertificatesOverviewPersonRouterProtocol, DialogRouterProtocol {
    // MARK: - Properties

    let sceneCoordinator: SceneCoordinator

    // MARK: - Lifecycle

    init(sceneCoordinator: SceneCoordinator) {
        self.sceneCoordinator = sceneCoordinator
    }

    // MARK: - Methods

    func showCertificatesDetail(certificates: [ExtendedCBORWebToken]) -> Promise<CertificateDetailSceneResult> {
        sceneCoordinator.push(
            CertificateDetailSceneFactory(
                router: CertificateDetailRouter(sceneCoordinator: sceneCoordinator),
                certificates: certificates
            )
        )
    }
}
