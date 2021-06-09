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

    // MARK: - Lifecycle

    init(
        router: CertificateItemDetailRouterProtocol,
        certificate: ExtendedCBORWebToken
    ) {
        self.router = router
        self.certificate = certificate
    }

    func make(resolvable: Resolver<CertificateDetailSceneResult>) -> UIViewController {
        let repository = VaccinationRepository.create()
        let viewModel = CertificateItemDetailViewModel(
            router: router,
            repository: repository,
            certificate: certificate,
            resolvable: resolvable
        )
        let viewController = CertificateItemDetailViewController(viewModel: viewModel)
        return viewController
    }
}
