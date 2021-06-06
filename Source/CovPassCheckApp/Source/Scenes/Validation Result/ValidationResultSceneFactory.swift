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
    let certificate: CBORWebToken?

    // MARK: - Lifecycle

    init(
        router: ValidationResultRouterProtocol,
        certificate: CBORWebToken?
    ) {
        self.router = router
        self.certificate = certificate
    }

    func make() -> UIViewController {
        let viewModel = ValidationResultFactory.createViewModel(
            router: router,
            repository: VaccinationRepository.create(),
            certificate: certificate
        )
        let viewController = ValidationResultViewController(viewModel: viewModel)
        return viewController
    }
}
