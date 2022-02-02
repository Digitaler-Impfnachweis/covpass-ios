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
    var router: ValidationResultRouterProtocol
    var repository: VaccinationRepositoryProtocol
    var certificate: CBORWebToken?
    var token: VAASValidaitonResultToken?

    var icon: UIImage? {
        .resultSuccess
    }

    var resultTitle: String {
        "share_certificate_detail_view_requirements_met_title".localized
    }

    var resultBody: String {
        String(format: "share_certificate_detail_view_requirements_met_subline".localized, token?.verifyingService ?? "")
    }

    var paragraphs: [Paragraph] {
        return [
            Paragraph(
                icon: .none,
                title: "",
                subtitle: String(format: "share_certificate_detail_view_requirements_met_message".localized, token?.provider ?? "")
            )
        ]
    }

    var info: String? {
        return nil
    }
    
    var buttonHidden: Bool = false
    var _2GContext: Bool = false
    var userDefaults: Persistence
    
    // MARK: - Lifecycle
    
    init(router: ValidationResultRouterProtocol,
         repository: VaccinationRepositoryProtocol,
         certificate: CBORWebToken?,
         token: VAASValidaitonResultToken?,
         userDefaults: Persistence ) {
        self.router = router
        self.repository = repository
        self.certificate = certificate
        self.token = token
        self.userDefaults = userDefaults
    }
}
