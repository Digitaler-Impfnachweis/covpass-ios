//
//  ValidatorAppInformationSceneFactory.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit
import VaccinationUI

struct ValidatorAppInformationSceneFactory: SceneFactory {
    // MARK: - Properties

    private let router: AppInformationRouterProtocol

    // MARK: - Lifecycle

    init(router: AppInformationRouterProtocol) {
        self.router = router
    }

    func make() -> UIViewController {
        let viewModel = ValidatorAppInformationViewModel(router: router)
        let viewController = AppInformationViewController(viewModel: viewModel)
        return viewController
    }
}
