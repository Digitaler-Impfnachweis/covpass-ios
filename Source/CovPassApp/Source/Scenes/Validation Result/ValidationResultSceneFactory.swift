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
    let certificate: ExtendedCBORWebToken
    let token: VAASValidaitonResultToken
    let error: Error?
    let userDefaults: Persistence
    
    // MARK: - Lifecycle
    
    init(router: ValidationResultRouterProtocol,
         certificate: ExtendedCBORWebToken,
         error: Error?,
         token: VAASValidaitonResultToken,
         userDefaults: Persistence) {
        self.router = router
        self.certificate = certificate
        self.token = token
        self.error = error
        self.userDefaults = userDefaults
    }
    
    func make(resolvable: Resolver<ExtendedCBORWebToken>) -> UIViewController {
        let viewModel = ValidationResultFactory.createViewModel(resolvable: resolvable,
                                                                router: router,
                                                                repository: VaccinationRepository.create(),
                                                                certificate: certificate,
                                                                error: error,
                                                                token: token,
                                                                userDefaults: userDefaults)
        let viewController = ValidationResultViewController(viewModel: viewModel)
        return viewController
    }
}
