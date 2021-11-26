//
//  CertificateItemDetailSceneFactory.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import PromiseKit
import UIKit

struct CertificateItemDetailSceneFactory: ResolvableSceneFactory {
    // MARK: - Properties

    let router: CertificateItemDetailRouterProtocol
    var certificate: ExtendedCBORWebToken
    let vaasResult: VAASValidaitonResultToken?

    // MARK: - Lifecycle

    init(
        router: CertificateItemDetailRouterProtocol,
        certificate: ExtendedCBORWebToken,
        vaasResult: VAASValidaitonResultToken? = nil
    ) {
        self.router = router
        self.certificate = certificate
        self.vaasResult = vaasResult
    }

    func make(resolvable: Resolver<CertificateDetailSceneResult>) -> UIViewController {
        let repository = VaccinationRepository.create()
        let viewModel = CertificateItemDetailViewModel(
            router: router,
            repository: repository,
            certificate: certificate,
            resolvable: resolvable,
            vaasResultToken: vaasResult
        )
        let viewController = CertificateItemDetailViewController(viewModel: viewModel)
        return viewController
    }
}
