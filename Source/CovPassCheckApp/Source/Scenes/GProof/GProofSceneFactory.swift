//
//  GProofSceneFactory.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import UIKit
import CovPassCommon
import PromiseKit

struct GProofSceneFactory: ResolvableSceneFactory {
    
    // MARK: - Properties
    
    let initialToken: CBORWebToken
    let repository: VaccinationRepositoryProtocol
    let certLogic: DCCCertLogicProtocol
    let router: GProofRouterProtocol
    
    // MARK: - Lifecycle
    
    init(initialToken: CBORWebToken,
         router: GProofRouterProtocol,
         repository: VaccinationRepositoryProtocol,
         certLogic: DCCCertLogicProtocol) {
        self.initialToken = initialToken
        self.router = router
        self.repository = repository
        self.certLogic = certLogic
    }

    func make(resolvable: Resolver<GProofResult>) -> UIViewController {
        let viewModel = GProofViewModel(initialToken: initialToken,
                                        router: router,
                                        repository: repository,
                                        certLogic: certLogic)
        let viewController = GProofViewController(viewModel: viewModel)
        return viewController
    }
}
