//
//  ValidatorOverviewSceneFactory.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import PromiseKit
import UIKit

struct ValidatorOverviewSceneFactory: SceneFactory {
    // MARK: - Properties

    let router: ValidatorOverviewRouterProtocol

    // MARK: - Lifecycle

    init(router: ValidatorOverviewRouterProtocol) {
        self.router = router
    }

    func make() -> UIViewController {
        let repository = VaccinationRepository.create()
        let viewModel = ValidatorOverviewViewModel(router: router,
                                                   repository: repository,
                                                   certLogic: DCCCertLogic.create(),
                                                   userDefaults: UserDefaultsPersistence())
        let viewController = ValidatorOverviewViewController(viewModel: viewModel)
        let navigationController = UINavigationController(rootViewController: viewController)
        return navigationController
    }
}
