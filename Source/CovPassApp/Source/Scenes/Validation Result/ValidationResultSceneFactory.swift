//
//  ValidationResultSceneFactory.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import PromiseKit
import UIKit

struct ValidationResultSceneFactory: SceneFactory {
    // MARK: - Properties

    let router: ValidationResultRouterProtocol
    let certificate: ExtendedCBORWebToken
    let token: VAASValidaitonResultToken
    let error: Error?

    // MARK: - Lifecycle

    init(
        router: ValidationResultRouterProtocol,
        certificate: ExtendedCBORWebToken,
        error: Error?,
        token: VAASValidaitonResultToken
    ) {
        self.router = router
        self.certificate = certificate
        self.token = token
        self.error = error
    }

    func make() -> UIViewController {
        let viewModel = ValidationResultFactory.createViewModel(
            router: router,
            repository: VaccinationRepository.create(),
            certificate: certificate.vaccinationCertificate,
            error: error,
            token: token
        )
        let viewController = ValidationResultViewController(viewModel: viewModel)
        return viewController
    }
}
