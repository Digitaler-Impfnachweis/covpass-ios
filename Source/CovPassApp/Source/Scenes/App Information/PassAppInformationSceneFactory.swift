//
//  PassAppInformationSceneFactory.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit
import VaccinationUI

struct PassAppInformationSceneFactory: SceneFactory {
    // MARK: - Properties

    private let router: AppInformationRouterProtocol

    // MARK: - Lifecycle

    init(router: AppInformationRouterProtocol) {
        self.router = router
    }

    func make() -> UIViewController {
        let viewModel = PassAppInformationViewModel(router: router)
        let viewController = AppInformationViewController(viewModel: viewModel)
        return viewController
    }
}
