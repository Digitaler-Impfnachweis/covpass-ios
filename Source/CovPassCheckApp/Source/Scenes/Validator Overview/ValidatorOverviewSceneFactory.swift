//
//  ValidatorOverviewSceneFactory.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import PromiseKit
import UIKit
import CovPassCommon
import CovPassUI

struct ValidatorOverviewSceneFactory: SceneFactory {
    // MARK: - Properties

    let router: ValidatorOverviewRouterProtocol

    // MARK: - Lifecycle

    init(router: ValidatorOverviewRouterProtocol) {
        self.router = router
    }

    func make() -> UIViewController {
        let repository = VaccinationRepository(service: APIService.create(), parser: QRCoder())
        let viewModel = ValidatorOverviewViewModel(router: router, repository: repository)
        let viewController = ValidatorOverviewViewController(viewModel: viewModel)
        let navigationController = UINavigationController(rootViewController: viewController)
        return navigationController
    }
}
