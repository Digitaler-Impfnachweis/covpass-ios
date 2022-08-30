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

    // MARK: - Lifecycle

    init(router: AppInformationRouterProtocol) {
        self.router = router
    }

    func make() -> UIViewController {
        let persistence = UserDefaultsPersistence()
        let viewModel = Locale.current.isGerman() ?
            GermanAppInformationViewModel(router: router, persistence: persistence) :
            EnglishAppInformationViewModel(router: router, persistence: persistence)
        let viewController = AppInformationViewController(viewModel: viewModel)
        return viewController
    }
}
