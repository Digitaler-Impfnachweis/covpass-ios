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
        guard let revocationRepository = CertificateRevocationRepository(),
              let pdfExtractor = PDFCBORExtractor(),
              let certificateHolderStatusModel = CertificateHolderStatusModel()
        else {
            fatalError("Dependencies can´t be initialized.")
        }
        let viewModel = CertificatesOverviewViewModel(
            router: router,
            repository: VaccinationRepository.create(),
            revocationRepository: revocationRepository,
            certLogic: DCCCertLogic.create(),
            boosterLogic: BoosterLogic.create(),
            userDefaults: UserDefaultsPersistence(),
            locale: .current,
            pdfExtractor: pdfExtractor,
            certificateHolderStatusModel: certificateHolderStatusModel
        )
        let viewController = CertificatesOverviewViewController(viewModel: viewModel)
        let navigationController = UINavigationController(rootViewController: viewController)
        return navigationController
    }
}
