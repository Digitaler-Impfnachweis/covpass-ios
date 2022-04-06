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
    
    private let repository: VaccinationRepositoryProtocol
    private let revocationRepository: CertificateRevocationRepositoryProtocol
    private let certLogic: DCCCertLogicProtocol
    private let router: GProofRouterProtocol
    private let userDefaults: Persistence
    private let boosterAsTest: Bool
    
    // MARK: - Lifecycle
    
    init(router: GProofRouterProtocol,
         repository: VaccinationRepositoryProtocol,
         revocationRepository: CertificateRevocationRepositoryProtocol,
         certLogic: DCCCertLogicProtocol,
         userDefaults: Persistence,
         boosterAsTest: Bool) {
        self.router = router
        self.repository = repository
        self.revocationRepository = revocationRepository
        self.certLogic = certLogic
        self.userDefaults = userDefaults
        self.boosterAsTest = boosterAsTest
    }

    func make(resolvable: Resolver<ExtendedCBORWebToken>) -> UIViewController {
        let viewModel = GProofViewModel(resolvable: resolvable,
                                        router: router,
                                        repository: repository,
                                        revocationRepository: revocationRepository,
                                        certLogic: certLogic,
                                        userDefaults: userDefaults,
                                        boosterAsTest: boosterAsTest)
        let viewController = GProofViewController(viewModel: viewModel)
        return viewController
    }
}
