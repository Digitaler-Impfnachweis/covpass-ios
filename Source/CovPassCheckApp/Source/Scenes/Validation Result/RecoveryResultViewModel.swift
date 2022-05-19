//
//  RecoveryResultViewModel.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import PromiseKit
import UIKit

class RecoveryResultViewModel: ValidationResultViewModel {
    // MARK: - Properties

    weak var delegate: ResultViewModelDelegate?
    var resolvable: Resolver<ExtendedCBORWebToken>
    var router: ValidationResultRouterProtocol
    var repository: VaccinationRepositoryProtocol
    var certificate: ExtendedCBORWebToken?
    var revocationKeyFilename: String

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
        guard let dgc = certificate?.vaccinationCertificate.hcert.dgc else {
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
    
    var buttonHidden: Bool = false
    var _2GContext: Bool
    var userDefaults: Persistence
    var isLoadingScan: Bool = false {
        didSet {
            delegate?.viewModelDidUpdate()
        }
    }
    
    // MARK: - Lifecycle

    init(resolvable: Resolver<ExtendedCBORWebToken>,
         router: ValidationResultRouterProtocol,
         repository: VaccinationRepositoryProtocol,
         certificate: ExtendedCBORWebToken?,
         _2GContext: Bool,
         userDefaults: Persistence,
         revocationKeyFilename: String
    ) {
        self.resolvable = resolvable
        self.router = router
        self.repository = repository
        self.certificate = certificate
        self._2GContext = _2GContext
        self.userDefaults = userDefaults
        self.revocationKeyFilename = revocationKeyFilename
    }
    
    func scanCertificateStarted() {
        isLoadingScan = true
    }
    
    func scanCertificateEnded() {
        isLoadingScan = false
    }
}
