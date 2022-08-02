//
//  CheckSituationSceneFactory.swift
//  
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import PromiseKit
import UIKit
import CovPassCommon
import CovPassUI

public struct CheckSituationResolvableSceneFactory: ResolvableSceneFactory {
    
    // MARK: - Lifecycle
    private let contextType: CheckSituationViewModelContextType
    private let router: CheckSituationRouterProtocol
    private let userDefaults: Persistence
    
    public init(contextType: CheckSituationViewModelContextType,
                router: CheckSituationRouterProtocol,
                userDefaults: Persistence) {
        self.userDefaults = userDefaults
        self.contextType = contextType
        self.router = router
    }
    
    // MARK: - Methods
    
    public func make(resolvable: Resolver<Void>) -> UIViewController {
        guard let offlineRevocationService = CertificateRevocationOfflineService.shared else {
            fatalError("CertificateRevocationOfflineService must not be nil.")
        }
        let viewModel = CheckSituationViewModel(context: contextType,
                                                userDefaults: userDefaults,
                                                router: router,
                                                resolver: resolvable,
                                                offlineRevocationService: offlineRevocationService,
                                                repository: VaccinationRepository.create(),
                                                certLogic: DCCCertLogic.create())
        let viewController = CheckSituationViewController(viewModel: viewModel)
        return viewController
    }
}
