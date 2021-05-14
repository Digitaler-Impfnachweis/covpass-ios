//
//  CertificateDetailSceneFactory.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import PromiseKit
import UIKit
import VaccinationCommon
import VaccinationUI

struct VaccinationDetailSceneFactory: SceneFactory {
    // MARK: - Properties

    let router: VaccinationDetailRouterProtocol
    let repository: VaccinationRepositoryProtocol
    let certificates: [ExtendedCBORWebToken]
    weak var delegate: CertificateDetailDelegate?

    // MARK: - Lifecycle

    init(
        router: VaccinationDetailRouterProtocol,
        repository: VaccinationRepositoryProtocol,
        certificates: [ExtendedCBORWebToken],
        delegate: CertificateDetailDelegate?
    ) {
        self.router = router
        self.repository = repository
        self.certificates = certificates
        self.delegate = delegate
    }

    func make() -> UIViewController {
        let viewModel = VaccinationDetailViewModel(
            router: router,
            repository: repository,
            certificates: certificates,
            detailDelegate: delegate
        )
        let viewController = VaccinationDetailViewController(viewModel: viewModel)
        return viewController
    }
}
