//
//  TestResultViewModel.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import PromiseKit
import UIKit

class TestResultViewModel: ValidationResultViewModel {
    // MARK: - Properties

    weak var delegate: ResultViewModelDelegate?
    var router: ValidationResultRouterProtocol
    var repository: VaccinationRepositoryProtocol
    var certificate: CBORWebToken?

    var icon: UIImage? {
        .group
    }

    var resultTitle: String {
        guard let testCert = certificate?.hcert.dgc.t?.first else {
            return ""
        }
        // negative pcr
        if testCert.isPCR {
            let diffComponents = Calendar.current.dateComponents([.hour], from: testCert.sc, to: Date())
            return String(format: "validation_check_popup_valid_pcr_test_title".localized, diffComponents.hour ?? 0)
        }
        // negative rapid
        let diffComponents = Calendar.current.dateComponents([.hour], from: testCert.sc, to: Date())
        return String(format: "validation_check_popup_test_title".localized, diffComponents.hour ?? 0)
    }

    var resultBody: String {
        "validation_check_popup_valid_vaccination_recovery_message".localized
    }

    var paragraphs: [Paragraph] {
        guard let dgc = certificate?.hcert.dgc, let testCert = dgc.t?.first else {
            return []
        }
        return [
            Paragraph(
                icon: .data,
                title: dgc.nam.fullName,
                subtitle: "\(dgc.nam.fullNameTransliterated)\n\(String(format: "validation_check_popup_test_date_of_birth".localized, DateUtils.displayDateOfBirth(dgc)))"
            ),
            Paragraph(
                icon: .calendar,
                title: DateUtils.displayDateTimeFormatter.string(from: testCert.sc),
                subtitle: "validation_check_popup_test_date_of_issue".localized
            )
        ]
    }

    var info: String? {
        nil
    }
    
    var buttonHidden: Bool = false

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
