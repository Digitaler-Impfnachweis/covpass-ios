//
//  CertificateDetailSceneFactory.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import PromiseKit
import UIKit

struct CertificateDetailSceneFactory: ResolvableSceneFactory {
    // MARK: - Properties

    let router: CertificateDetailRouterProtocol
    var certificates: [ExtendedCBORWebToken]

    // MARK: - Lifecycle

    init(
        router: CertificateDetailRouterProtocol,
        certificates: [ExtendedCBORWebToken]
    ) {
        self.router = router
        self.certificates = certificates
    }

    func make(resolvable: Resolver<CertificateDetailSceneResult>) -> UIViewController {
        let repository = VaccinationRepository.create()
        let viewModel = CertificateDetailViewModel(
            router: router,
            repository: repository,
            certificates: certificates,
            resolvable: resolvable
        )
        let viewController = CertificateDetailViewController(viewModel: viewModel)
        return viewController
    }
}
