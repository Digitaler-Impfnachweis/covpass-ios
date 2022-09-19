//
//  CertificatesOverviewPersonSceneFactory.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import PromiseKit
import UIKit

struct CertificatesOverviewPersonSceneFactory: ResolvableSceneFactory {
    
    // MARK: - Properties
    private let router: CertificatesOverviewPersonRouterProtocol
    private let certificates: [ExtendedCBORWebToken]
    private let vaccinationRepository: VaccinationRepositoryProtocol
    private let boosterLogic: BoosterLogicProtocol

    // MARK: - Lifecycle

    init(router: CertificatesOverviewPersonRouterProtocol,
         certificates: [ExtendedCBORWebToken],
         vaccinationRepository: VaccinationRepositoryProtocol,
         boosterLogic: BoosterLogicProtocol) {
        self.router = router
        self.certificates = certificates
        self.vaccinationRepository = vaccinationRepository
        self.boosterLogic = boosterLogic
    }

    func make(resolvable: Resolver<CertificateDetailSceneResult>) -> UIViewController {
        guard let certificateHolderStatusModel = CertificateHolderStatusModel() else {
            fatalError("Failed to initialize dependency.")
        }
        let viewModel = CertificatesOverviewPersonViewModel(router: router,
                                                            repository: vaccinationRepository,
                                                            boosterLogic: boosterLogic,
                                                            certificateHolderStatusModel: certificateHolderStatusModel,
                                                            certificates: certificates,
                                                            resolver: resolvable)
        let viewController = CertificatesOverviewPersonViewController(viewModel: viewModel)
        let navigationController = UINavigationController(rootViewController: viewController)
        navigationController.modalPresentationStyle = .fullScreen
        return navigationController
    }
}
