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

struct ValidationResultSceneFactory: ResolvableSceneFactory {
    // MARK: - Properties
    
    let router: ValidationResultRouterProtocol
    let certificate: ExtendedCBORWebToken?
    let error: Error?
    let buttonHidden: Bool
    let _2GContext: Bool
    let userDefaults: Persistence

    // MARK: - Lifecycle
    
    init(router: ValidationResultRouterProtocol,
         certificate: ExtendedCBORWebToken?,
         error: Error?,
         buttonHidden: Bool = false,
         _2GContext: Bool,
         userDefaults: Persistence) {
        self.router = router
        self.certificate = certificate
        self.error = error
        self.buttonHidden = buttonHidden
        self._2GContext = _2GContext
        self.userDefaults = userDefaults
    }
    
    func make(resolvable: Resolver<ExtendedCBORWebToken>) -> UIViewController {
        var viewModel = ValidationResultFactory.createViewModel(
            resolvable: resolvable,
            router: router,
            repository: VaccinationRepository.create(),
            certificate: certificate,
            error: error,
            type: userDefaults.selectedLogicType,
            certLogic: DCCCertLogic.create(),
            _2GContext: _2GContext,
            userDefaults: userDefaults
        )
        viewModel.buttonHidden = buttonHidden
        let viewController = ValidationResultViewController(viewModel: viewModel)
        return viewController
    }
}
