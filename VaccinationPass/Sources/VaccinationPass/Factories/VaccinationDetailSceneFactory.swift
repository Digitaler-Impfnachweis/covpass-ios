//
//  CertificateDetailSceneFactory.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import UIKit
import PromiseKit
import VaccinationUI
import VaccinationCommon

struct VaccinationDetailSceneFactory: SceneFactory {
    // MARK: - Properties

    let router: VaccinationDetailRouterProtocol
    let certificates: [ExtendedVaccinationCertificate]

    // MARK: - Lifecylce

    init(
        router: VaccinationDetailRouterProtocol,
        certificates: [ExtendedVaccinationCertificate]) {

        self.router = router
        self.certificates = certificates
    }

    func make() -> UIViewController {
        let viewModel = VaccinationDetailViewModel(
            router: router,
            certificates: certificates
        )
        let viewController = VaccinationDetailViewController.createFromStoryboard()
        viewController.viewModel = viewModel
        return viewController
    }
}
