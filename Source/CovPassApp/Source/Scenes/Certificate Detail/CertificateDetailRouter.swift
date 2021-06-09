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

    func showDetail(for certificate: ExtendedCBORWebToken) -> Promise<CertificateDetailSceneResult> {
        sceneCoordinator.push(
            CertificateItemDetailSceneFactory(
                router: CertificateItemDetailRouter(sceneCoordinator: sceneCoordinator),
                certificate: certificate
            )
        )
    }
}
