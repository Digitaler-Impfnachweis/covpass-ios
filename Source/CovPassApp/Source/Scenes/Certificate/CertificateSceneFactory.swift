//
//  CertificateSceneFactory.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import PromiseKit
import UIKit
import VaccinationCommon
import CovPassUI

struct CertificateSceneFactory: SceneFactory {
    // MARK: - Properties

    let router: CertificateRouterProtocol

    // MARK: - Lifecycle

    init(router: CertificateRouterProtocol) {
        self.router = router
    }

    func make() -> UIViewController {
        let repository = VaccinationRepository(service: APIService.create(), parser: QRCoder())
        let viewModel = DefaultCertificateViewModel(
            router: router,
            repository: repository
        )
        let viewController = CertificateViewController(viewModel: viewModel)
        let navigationController = UINavigationController(rootViewController: viewController)
        return navigationController
    }
}
