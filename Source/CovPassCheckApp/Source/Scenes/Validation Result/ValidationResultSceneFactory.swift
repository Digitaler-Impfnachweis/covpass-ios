//
//  ValidationResultSceneFactory.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import PromiseKit
import UIKit
import CovPassCommon
import CovPassUI

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
        let repository = VaccinationRepository(service: APIService.create(), parser: QRCoder())
        let viewModel = ValidationResultViewModel(
            router: router,
            repository: repository,
            certificate: certificate
        )
        let viewController = ValidationResultViewController(viewModel: viewModel)
        return viewController
    }
}
