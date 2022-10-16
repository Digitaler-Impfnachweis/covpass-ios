//
//  SelectStateOnboardingSceneFactory.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit
import CovPassUI
import CovPassCommon
import PromiseKit

struct SelectStateOnboardingSceneFactory: ResolvableSceneFactory {
    // MARK: - Properties
    
    private let sceneCoordinator: SceneCoordinator
    
    // MARK: - Lifecycle
    
    init(sceneCoordinator: SceneCoordinator) {
        self.sceneCoordinator = sceneCoordinator
    }
    
    func make(resolvable: Resolver<Void>) -> UIViewController {
        SelectStateOnboardingViewController(
            viewModel: SelectStateOnboardingViewModel(
                resolver: resolvable,
                router: SelectStateOnboardingViewRouter(
                    sceneCoordinator: sceneCoordinator
                ),
                userDefaults: UserDefaultsPersistence()
            )
        )
    }
}
