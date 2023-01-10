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

    func showPDFExport(for token: ExtendedCBORWebToken) -> Promise<Void> {
        sceneCoordinator.present(
            PDFExportSceneFactory(token: token)
        )
    }

    func showReissue(for tokens: [ExtendedCBORWebToken],
                     context: ReissueContext) -> Promise<Void> {
        if tokens.isEmpty {
            // Do not start the reissue process when we don't have any tokens
            return .value
        }
        let router = ReissueConsentRouter(sceneCoordinator: sceneCoordinator)
        let sceneFactory = ReissueConsentResolvableSceneFactory(router: router,
                                                                tokens: tokens,
                                                                context: context)
        return sceneCoordinator.present(sceneFactory, animated: true)
    }
}
