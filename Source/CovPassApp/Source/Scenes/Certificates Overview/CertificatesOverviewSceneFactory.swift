//
//  CertificatesOverviewSceneFactory.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import PromiseKit
import UIKit

struct CertificatesOverviewSceneFactory: SceneFactory {
    // MARK: - Properties

    let router: CertificatesOverviewRouterProtocol

    // MARK: - Lifecycle

    init(router: CertificatesOverviewRouterProtocol) {
        self.router = router
    }

    func make() -> UIViewController {
        let viewModel = CertificatesOverviewViewModel(
            router: router,
            repository: VaccinationRepository.create()
        )
        let viewController = CertificatesOverviewViewController(viewModel: viewModel)
        let navigationController = UINavigationController(rootViewController: viewController)
        return navigationController
    }
}
