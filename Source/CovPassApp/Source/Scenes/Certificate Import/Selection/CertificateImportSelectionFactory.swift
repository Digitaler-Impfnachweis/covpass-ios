//
//  CertificateImportSelectionFactory.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import PromiseKit
import UIKit

struct CertificateImportSelectionFactory: ResolvableSceneFactory {
    private let importTokens: [ExtendedCBORWebToken]
    private let router: CertificateImportSelectionRouterProtocol

    init(importTokens: [ExtendedCBORWebToken],
         router: CertificateImportSelectionRouterProtocol) {
        self.importTokens = importTokens
        self.router = router
    }

    func make(resolvable: Resolver<Void>) -> UIViewController {
        let vaccinationRepository = VaccinationRepository.create()
        let viewModel = CertificateImportSelectionViewModel(
            tokens: importTokens,
            vaccinationRepository: vaccinationRepository,
            resolver: resolvable,
            router: router
        )
        let viewController = CertificateImportSelectionViewController(
            viewModel: viewModel
        )

        return viewController
    }
}
