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

    func showWebview(_ url: URL) {
        sceneCoordinator.present(WebviewSceneFactory(title: "app_information_title_faq".localized, url: url, closeButtonShown: true))
    }
    
    @discardableResult
    func showCertificate(for token: ExtendedCBORWebToken) -> Promise<Void> {
        sceneCoordinator.present(
            CertificateSceneFactory(token: token)
        )
    }
    
    func showReissue(for tokens: [ExtendedCBORWebToken],
                     context: ReissueContext) -> Promise<Void> {
        sceneCoordinator.present(
            ReissueStartSceneFactory(
                router: ReissueStartRouter(sceneCoordinator: sceneCoordinator),
                tokens: tokens,
                context: context
            )
        )
    }
    
}
