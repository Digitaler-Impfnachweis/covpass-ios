//
//  CertificateDetailSceneFactory.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import PromiseKit
import UIKit
import CovPassCommon
import CovPassUI

struct VaccinationDetailSceneFactory: ResolvableSceneFactory {
    // MARK: - Properties

    let router: VaccinationDetailRouterProtocol
    var certificates: [ExtendedCBORWebToken]

    // MARK: - Lifecycle

    init(
        router: VaccinationDetailRouterProtocol,
        certificates: [ExtendedCBORWebToken]
    ) {
        self.router = router
        self.certificates = certificates
    }

    func make(resolvable: Resolver<VaccinationDetailSceneResult>) -> UIViewController {
        let repository = VaccinationRepository(
            service: APIService.create(),
            parser: QRCoder()
        )
        let viewModel = VaccinationDetailViewModel(
            router: router,
            repository: repository,
            certificates: certificates,
            resolvable: resolvable
        )
        let viewController = VaccinationDetailViewController(viewModel: viewModel)
        return viewController
    }
}
