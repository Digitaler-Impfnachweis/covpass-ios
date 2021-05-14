//
//  ValidatorSceneFactory.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import PromiseKit
import UIKit
import CovPassCommon
import CovPassUI

struct ValidatorSceneFactory: SceneFactory {
    // MARK: - Properties

    let router: ValidatorRouterProtocol

    // MARK: - Lifecycle

    init(router: ValidatorRouterProtocol) {
        self.router = router
    }

    func make() -> UIViewController {
        let repository = VaccinationRepository(service: APIService.create(), parser: QRCoder())
        let viewModel = ValidatorViewModel(router: router, repository: repository)
        let viewController = ValidatorViewController(viewModel: viewModel)
        let navigationController = UINavigationController(rootViewController: viewController)
        return navigationController
    }
}
