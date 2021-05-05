//
//  CertificateSceneFactory.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit
import PromiseKit
import VaccinationUI
import VaccinationCommon

struct CertificateSceneFactory: SceneFactory {
    // MARK: - Properties

    let router: CertificateRouterProtocol

    // MARK: - Lifecylce

    init(router: CertificateRouterProtocol) {
        self.router = router
    }

    func make() -> UIViewController {
        let viewController = CertificateViewController.createFromStoryboard(bundle: Bundle.module)
        let viewModel = DefaultCertificateViewModel(
            router: router,
            parser: QRCoder()
        )
        viewController.viewModel = viewModel
        viewModel.delegate = viewController

        let navigationController = UINavigationController(rootViewController: viewController)
        return navigationController
    }
}
