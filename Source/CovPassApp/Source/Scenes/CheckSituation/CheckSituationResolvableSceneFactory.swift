//
//  CheckSituationSceneFactory.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import PromiseKit
import UIKit

public struct CheckSituationResolvableSceneFactory: ResolvableSceneFactory {
    // MARK: - Lifecycle

    private let userDefaults: Persistence

    public init(userDefaults: Persistence) {
        self.userDefaults = userDefaults
    }

    // MARK: - Methods

    public func make(resolvable: Resolver<Void>) -> UIViewController {
        let viewModel = CheckSituationViewModel(userDefaults: userDefaults,
                                                router: nil,
                                                resolver: resolvable,
                                                offlineRevocationService: nil,
                                                repository: VaccinationRepository.create())
        let viewController = CheckSituationViewController(viewModel: viewModel)
        return viewController
    }
}
