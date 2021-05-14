//
//  CertificateSceneFactory.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import PromiseKit
import UIKit
import CovPassCommon
import CovPassUI

struct CertificatesOverviewSceneFactory: SceneFactory {
    // MARK: - Properties

    let router: CertificatesOverviewRouterProtocol

    // MARK: - Lifecycle

    init(router: CertificatesOverviewRouterProtocol) {
        self.router = router
    }

    func make() -> UIViewController {
        let repository = VaccinationRepository(service: APIService.create(), parser: QRCoder())
        let viewModel = CertificatesOverviewViewModel(
            router: router,
            repository: repository
        )
        let viewController = CertificatesOverviewViewController(viewModel: viewModel)
        let navigationController = UINavigationController(rootViewController: viewController)
        return navigationController
    }
}
