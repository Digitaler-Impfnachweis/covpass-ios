//
//  CertificateItemDetailRouter.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import PromiseKit
import UIKit

class CertificateItemDetailRouter: CertificateItemDetailRouterProtocol, DialogRouterProtocol {
    // MARK: - Properties

    let sceneCoordinator: SceneCoordinator

    // MARK: - Lifecycle

    init(sceneCoordinator: SceneCoordinator) {
        self.sceneCoordinator = sceneCoordinator
    }

    // MARK: - Methods

    func showCertificate(for token: ExtendedCBORWebToken) -> Promise<Void> {
        sceneCoordinator.present(
            CertificateSceneFactory(token: token)
        )
    }
}
