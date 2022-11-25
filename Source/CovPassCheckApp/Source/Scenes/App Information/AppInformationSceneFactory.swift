//
//  AppInformationSceneFactory.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import UIKit

struct AppInformationSceneFactory: SceneFactory {
    // MARK: - Properties

    private let router: AppInformationRouterProtocol
    private let userDefaults: Persistence

    // MARK: - Lifecycle

    init(router: AppInformationRouterProtocol,
         userDefaults: Persistence) {
        self.router = router
        self.userDefaults = userDefaults
    }

    func make() -> UIViewController {
        let viewModel = Locale.current.isGerman() ?
            GermanAppInformationViewModel(router: router, userDefaults: userDefaults) :
            EnglishAppInformationViewModel(router: router, userDefaults: userDefaults)
        let viewController = AppInformationViewController(viewModel: viewModel)
        return viewController
    }
}
