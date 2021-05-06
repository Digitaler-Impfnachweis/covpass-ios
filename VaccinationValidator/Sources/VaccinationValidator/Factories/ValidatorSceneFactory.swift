//
//  ValidatorSceneFactory.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit
import PromiseKit
import VaccinationUI
import VaccinationCommon

struct ValidatorSceneFactory: SceneFactory {
    // MARK: - Properties

    let router: ValidatorRouterProtocol

    // MARK: - Lifecycle

    init(router: ValidatorRouterProtocol) {
        self.router = router
    }

    func make() -> UIViewController {
        let viewController = ValidatorViewController.createFromStoryboard(bundle: Bundle.module)
        let repository = VaccinationRepository(service: APIService(), parser: QRCoder())
        let viewModel = ValidatorViewModel(router: router, repository: repository)
        viewController.viewModel = viewModel
//        viewModel.delegate = viewController

        let navigationController = UINavigationController(rootViewController: viewController)
        return navigationController
    }
}
