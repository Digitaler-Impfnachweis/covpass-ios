//
//  ValidationServiceFactory.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import PromiseKit
import UIKit

struct ValidationServiceFactory: SceneFactory {
    // MARK: - Properties

    let initialisationData: ValidationServiceInitialisation
    let router: ValidationServiceRouter

    // MARK: - Lifecycle

    init(router: ValidationServiceRouter, initialisationData: ValidationServiceInitialisation) {
        self.router = router
        self.initialisationData = initialisationData
    }

    func make() -> UIViewController {
        let viewModel = ValidationServiceViewModel(router: router, initialisationData: initialisationData)
        let viewController = ValidationServiceViewController(viewModel: viewModel)
        let navigationController = UINavigationController(rootViewController: viewController)
        return navigationController
    }
}
