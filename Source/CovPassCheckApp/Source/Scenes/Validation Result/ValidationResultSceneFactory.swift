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
    let error: Error?
    let buttonHidden: Bool
    
    // MARK: - Lifecycle
    
    init(router: ValidationResultRouterProtocol,
         certificate: CBORWebToken?,
         error: Error?,
         buttonHidden: Bool = false) {
        self.router = router
        self.certificate = certificate
        self.error = error
        self.buttonHidden = buttonHidden
    }
    
    func make() -> UIViewController {
        var viewModel = ValidationResultFactory.createViewModel(
            router: router,
            repository: VaccinationRepository.create(),
            certificate: certificate,
            error: error,
            certLogic: DCCCertLogic.create()
        )
        viewModel.buttonHidden = buttonHidden
        let viewController = ValidationResultViewController(viewModel: viewModel)
        return viewController
    }
}
