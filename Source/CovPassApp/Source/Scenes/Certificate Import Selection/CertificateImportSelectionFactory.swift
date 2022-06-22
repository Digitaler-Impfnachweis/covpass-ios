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
    private let vaccinationRepository: VaccinationRepositoryProtocol

    init(importTokens: [ExtendedCBORWebToken], vaccinationRepository: VaccinationRepositoryProtocol) {
        self.importTokens = importTokens
        self.vaccinationRepository = vaccinationRepository
    }

    func make(resolvable: Resolver<Void>) -> UIViewController {
        let viewModel = CertificateImportSelectionViewModel(
            tokens: importTokens,
            vaccinationRepository: vaccinationRepository,
            resolver: resolvable
        )
        let viewController = CertificateImportSelectionViewController(
            viewModel: viewModel
        )

        return viewController
    }
}
