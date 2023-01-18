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

    func showDetail(for certificate: ExtendedCBORWebToken,
                    certificates: [ExtendedCBORWebToken]) -> Promise<CertificateDetailSceneResult> {
        sceneCoordinator.push(
            CertificateItemDetailSceneFactory(
                router: CertificateItemDetailRouter(sceneCoordinator: sceneCoordinator),
                certificate: certificate, certificates: certificates
            )
        )
    }

    func showWebview(_ url: URL) {
        let title = "app_information_title_faq".localized
        let faqTitleOpen = "accessibility_app_information_title_faq_announce".localized
        let faqTitleClose = "accessibility_app_information_title_faq_announce_closing".localized
        let factory = WebviewSceneFactory(title: title,
                                          url: url,
                                          closeButtonShown: true,
                                          openingAnnounce: faqTitleOpen,
                                          closingAnnounce: faqTitleClose)
        sceneCoordinator.present(factory)
    }

    @discardableResult
    func showCertificate(for token: ExtendedCBORWebToken) -> Promise<Void> {
        sceneCoordinator.present(
            CertificateSceneFactory(token: token)
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

    func showStateSelection() -> Promise<Void> {
        sceneCoordinator.present(
            StateSelectionSceneFactory()
        )
    }
}
