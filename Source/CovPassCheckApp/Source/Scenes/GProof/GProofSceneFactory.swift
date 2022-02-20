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
    private let userDefaults: Persistence
    private let boosterAsTest: Bool
    
    // MARK: - Lifecycle
    
    init(initialToken: CBORWebToken,
         router: GProofRouterProtocol,
         repository: VaccinationRepositoryProtocol,
         certLogic: DCCCertLogicProtocol,
         userDefaults: Persistence,
         boosterAsTest: Bool) {
        self.initialToken = initialToken
        self.router = router
        self.repository = repository
        self.certLogic = certLogic
        self.userDefaults = userDefaults
        self.boosterAsTest = boosterAsTest
    }

    func make(resolvable: Resolver<CBORWebToken>) -> UIViewController {
        let viewModel = GProofViewModel(resolvable: resolvable,
                                        initialToken: initialToken,
                                        router: router,
                                        repository: repository,
                                        certLogic: certLogic,
                                        userDefaults: userDefaults,
                                        boosterAsTest: boosterAsTest)
        let viewController = GProofViewController(viewModel: viewModel)
        return viewController
    }
}
