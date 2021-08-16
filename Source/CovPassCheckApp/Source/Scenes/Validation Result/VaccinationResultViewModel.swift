//
//  VaccinationResultViewModel.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import PromiseKit
import UIKit

class VaccinationResultViewModel: ValidationResultViewModel {
    // MARK: - Properties

    weak var delegate: ResultViewModelDelegate?
    var router: ValidationResultRouterProtocol
    var repository: VaccinationRepositoryProtocol
    var certificate: CBORWebToken?

    var icon: UIImage? {
        .resultSuccess
    }

    var resultTitle: String {
        "validation_check_popup_valid_vaccination_recovery_title".localized
    }

    var resultBody: String {
        "validation_check_popup_valid_vaccination_recovery_message".localized
    }

    var paragraphs: [Paragraph] {
        guard let dgc = certificate?.hcert.dgc else {
            return []
        }
        return [
            Paragraph(
                icon: .data,
                title: dgc.nam.fullName,
                subtitle: "\(dgc.nam.fullNameTransliterated)\n\(String(format: "validation_check_popup_valid_vaccination_date_of_birth".localized, DateUtils.displayDateOfBirth(dgc)))"
            )
        ]
    }

    var info: String? {
        "validation_check_popup_valid_vaccination_recovery_note".localized
    }

    // MARK: - Lifecycle

    init(
        router: ValidationResultRouterProtocol,
        repository: VaccinationRepositoryProtocol,
        certificate: CBORWebToken?
    ) {
        self.router = router
        self.repository = repository
        self.certificate = certificate
    }
}
