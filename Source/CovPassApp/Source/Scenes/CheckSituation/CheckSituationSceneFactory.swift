//
//  CheckSituationSceneFactory.swift
//  
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassUI
import PromiseKit
import UIKit
import CovPassCommon

public struct CheckSituationSceneFactory: SceneFactory {
    
    // MARK: - Lifecycle
    private let contextType: CheckSituationViewModelContextType
    private let userDefaults: Persistence

    public init(contextType: CheckSituationViewModelContextType,
                userDefaults: Persistence) {
        self.userDefaults = userDefaults
        self.contextType = contextType
    }

    // MARK: - Methods

    public func make() -> UIViewController {
        let viewModel = CheckSituationViewModel(
            context: contextType,
            userDefaults: userDefaults,
            resolver: nil,
            offlineRevocationService: nil
        )
        let viewController = CheckSituationViewController(viewModel: viewModel)
        return viewController
    }
}
