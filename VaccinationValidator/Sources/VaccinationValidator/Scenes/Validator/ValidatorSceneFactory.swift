//
//  ValidatorSceneFactory.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import PromiseKit
import UIKit
import VaccinationCommon
import VaccinationUI

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
