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
    let certificate: ExtendedCBORWebToken
    let vaasResult: VAASValidaitonResultToken?
    let certificates: [ExtendedCBORWebToken]

    // MARK: - Lifecycle

    init(
        router: CertificateItemDetailRouterProtocol,
        certificate: ExtendedCBORWebToken,
        certificates: [ExtendedCBORWebToken],
        vaasResult: VAASValidaitonResultToken? = nil
    ) {
        self.router = router
        self.certificate = certificate
        self.certificates = certificates
        self.vaasResult = vaasResult
    }

    func make(resolvable: Resolver<CertificateDetailSceneResult>) -> UIViewController {
        let repository = VaccinationRepository.create()
        let viewModel = CertificateItemDetailViewModel(
            router: router,
            repository: repository,
            certificate: certificate,
            certificates: certificates,
            resolvable: resolvable,
            vaasResultToken: vaasResult
        )
        let viewController = CertificateItemDetailViewController(viewModel: viewModel)
        return viewController
    }
}
