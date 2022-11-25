//
//  SelectStateOnboardingSceneFactory.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import PromiseKit
import UIKit

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
                userDefaults: UserDefaultsPersistence(),
                certificateHolderStatus: CertificateHolderStatusModel(dccCertLogic: DCCCertLogic.create())
            )
        )
    }
}
