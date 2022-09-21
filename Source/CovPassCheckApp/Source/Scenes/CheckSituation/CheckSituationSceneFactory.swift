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

public struct CheckSituationSceneFactory: SceneFactory {
    
    // MARK: - Lifecycle
    private let router: CheckSituationRouterProtocol
    private let userDefaults: Persistence

    public init(router: CheckSituationRouterProtocol,
                userDefaults: Persistence) {
        self.userDefaults = userDefaults
        self.router = router
    }
    
    // MARK: - Methods
    
    public func make() -> UIViewController {
        guard let offlineRevocationService = CertificateRevocationOfflineService.shared else {
            fatalError("CertificateRevocationOfflineService must not be nil.")
        }
        let context: CheckSituationViewModelContextType = .settings
        let viewModel = CheckSituationViewModel(context: context,
                                                userDefaults: userDefaults,
                                                router: router,
                                                resolver: nil,
                                                offlineRevocationService: offlineRevocationService,
                                                repository: VaccinationRepository.create(),
                                                certLogic: DCCCertLogic.create())
        let viewController = CheckSituationViewController(viewModel: viewModel)
        return viewController
    }
}
