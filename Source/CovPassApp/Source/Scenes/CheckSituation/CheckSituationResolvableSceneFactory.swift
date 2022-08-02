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
    private let userDefaults: Persistence
    
    public init(contextType: CheckSituationViewModelContextType,
                userDefaults: Persistence) {
        self.userDefaults = userDefaults
        self.contextType = contextType
    }
    
    // MARK: - Methods
    
    public func make(resolvable: Resolver<Void>) -> UIViewController {
        let viewModel = CheckSituationViewModel(context: contextType,
                                                userDefaults: userDefaults,
                                                router: nil,
                                                resolver: resolvable,
                                                offlineRevocationService: nil,
                                                repository: VaccinationRepository.create(),
                                                certLogic: DCCCertLogic.create())
        let viewController = CheckSituationViewController(viewModel: viewModel)
        return viewController
    }
}
