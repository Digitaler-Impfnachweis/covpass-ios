//
//  CertificateSceneFactory.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

import PromiseKit
import UIKit
import VaccinationCommon
import VaccinationUI

struct CertificateSceneFactory: SceneFactory {
    // MARK: - Properties

    let router: CertificateRouterProtocol

    // MARK: - Lifecycle

    init(router: CertificateRouterProtocol) {
        self.router = router
    }

    func make() -> UIViewController {
        let repository = VaccinationRepository(service: APIService(), parser: QRCoder())
        let viewModel = DefaultCertificateViewModel(
            router: router,
            repository: repository
        )
        let viewController = CertificateViewController(viewModel: viewModel)
        let navigationController = UINavigationController(rootViewController: viewController)
        return navigationController
    }
}
