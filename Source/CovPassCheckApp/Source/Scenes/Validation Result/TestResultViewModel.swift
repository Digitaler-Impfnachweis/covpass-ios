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
    var resolvable: Resolver<ExtendedCBORWebToken>
    var router: ValidationResultRouterProtocol
    var repository: VaccinationRepositoryProtocol
    var certificate: ExtendedCBORWebToken?

    var icon: UIImage? {
        .group
    }

    var resultTitle: String {
        guard let testCert = certificate?.vaccinationCertificate.hcert.dgc.t?.first else {
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
        guard let dgc = certificate?.vaccinationCertificate.hcert.dgc, let testCert = dgc.t?.first else {
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
    var _2GContext: Bool
    var userDefaults: Persistence
    
    // MARK: - Lifecycle
    
    init(resolvable: Resolver<ExtendedCBORWebToken>,
         router: ValidationResultRouterProtocol,
         repository: VaccinationRepositoryProtocol,
         certificate: ExtendedCBORWebToken?,
         _2GContext: Bool,
         userDefaults: Persistence
    ) {
        self.resolvable = resolvable
        self.router = router
        self.repository = repository
        self.certificate = certificate
        self._2GContext = _2GContext
        self.userDefaults = userDefaults
    }
}
