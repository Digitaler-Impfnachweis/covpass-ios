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
    
    private let initialToken: CBORWebToken
    private let repository: VaccinationRepositoryProtocol
    private let certLogic: DCCCertLogicProtocol
    private let router: GProofRouterProtocol
    private let boosterAsTest: Bool
    // MARK: - Lifecycle
    
    init(initialToken: CBORWebToken,
         router: GProofRouterProtocol,
         repository: VaccinationRepositoryProtocol,
         certLogic: DCCCertLogicProtocol,
         boosterAsTest: Bool) {
        self.initialToken = initialToken
        self.router = router
        self.repository = repository
        self.certLogic = certLogic
        self.boosterAsTest = boosterAsTest
    }

    func make(resolvable: Resolver<GProofResult>) -> UIViewController {
        let viewModel = GProofViewModel(initialToken: initialToken,
                                        router: router,
                                        repository: repository,
                                        certLogic: certLogic,
                                        boosterAsTest: boosterAsTest)
        let viewController = GProofViewController(viewModel: viewModel)
        return viewController
    }
}
