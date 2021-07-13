//
//  ErrorResultViewModel.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import PromiseKit
import UIKit

class ErrorResultViewModel: ValidationResultViewModel {
    // MARK: - Properties

    weak var delegate: ResultViewModelDelegate?
    var router: ValidationResultRouterProtocol
    var repository: VaccinationRepositoryProtocol
    var certificate: CBORWebToken?

    var icon: UIImage? {
        .resultError
    }

    var resultTitle: String {
        "validation_check_popup_unsuccessful_certificate_title".localized
    }

    var resultBody: String {
        "validation_check_popup_unsuccessful_certificate_message".localized
    }

    var paragraphs: [Paragraph] {
        [
            Paragraph(icon: .timeHui, title: "validation_check_popup_unsuccessful_certificate_not_valid_title".localized, subtitle: "validation_check_popup_unsuccessful_certificate_not_valid_message".localized),
            Paragraph(icon: .technicalError, title: "validation_check_popup_unsuccessful_certificate_technical_problems_title".localized, subtitle: "validation_check_popup_unsuccessful_certificate_technical_problems_message".localized)
        ]
    }

    var info: String? {
        nil
    }

    // MARK: - Lifecycle

    init(
        router: ValidationResultRouterProtocol,
        repository: VaccinationRepositoryProtocol,
        certificate: CBORWebToken? = nil
    ) {
        self.router = router
        self.repository = repository
        self.certificate = certificate
    }
}
