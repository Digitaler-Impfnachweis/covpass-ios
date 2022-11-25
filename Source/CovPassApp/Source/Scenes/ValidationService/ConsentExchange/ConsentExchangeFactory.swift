//
//  ConsentExchangeFactory.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import PromiseKit
import UIKit

struct ConsentExchangeFactory: SceneFactory {
    // MARK: - Properties

    let initialisationData: ValidationServiceInitialisation
    let router: ValidationServiceRoutable
    let certificate: ExtendedCBORWebToken
    let vaasRepository: VAASRepositoryProtocol

    // MARK: - Lifecycle

    init(router: ValidationServiceRoutable, vaasRepository: VAASRepositoryProtocol, initialisationData: ValidationServiceInitialisation, certificate: ExtendedCBORWebToken) {
        self.router = router
        self.initialisationData = initialisationData
        self.certificate = certificate
        self.vaasRepository = vaasRepository
    }

    func make() -> UIViewController {
        let viewModel = ConsentExchangeViewModel(router: router,
                                                 vaasRepository: vaasRepository,
                                                 initialisationData: initialisationData,
                                                 certificate: certificate)
        let viewController = ConsentExchangeViewController(viewModel: viewModel)
        return viewController
    }
}
