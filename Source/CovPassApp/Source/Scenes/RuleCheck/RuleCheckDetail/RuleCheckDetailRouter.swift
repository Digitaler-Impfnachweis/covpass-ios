//
//  RuleCheckDetailRouter.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import PromiseKit
import UIKit

protocol RuleCheckDetailRouterProtocol: DialogRouterProtocol {
    func showCertificate(for token: ExtendedCBORWebToken) -> Promise<Void>
}

class RuleCheckDetailRouter: RuleCheckDetailRouterProtocol {
    // MARK: - Properties

    let sceneCoordinator: SceneCoordinator

    // MARK: - Lifecycle

    init(sceneCoordinator: SceneCoordinator) {
        self.sceneCoordinator = sceneCoordinator
    }

    func showCertificate(for token: ExtendedCBORWebToken) -> Promise<Void> {
        sceneCoordinator.present(
            CertificateSceneFactory(token: token)
        )
    }
}
