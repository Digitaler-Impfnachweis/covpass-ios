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
    var token: VAASValidaitonResultToken?
    let revocationKeyFilename = ""
    let countdownTimerModel: CountdownTimerModel? = nil

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
    var isLoadingScan: Bool = false
    
    // MARK: - Lifecycle
    
    init(resolvable: Resolver<ExtendedCBORWebToken>,
         router: ValidationResultRouterProtocol,
         repository: VaccinationRepositoryProtocol,
         certificate: ExtendedCBORWebToken?,
         token: VAASValidaitonResultToken?,
         userDefaults: Persistence ) {
        self.router = router
        self.repository = repository
        self.certificate = certificate
        self.token = token
        self.userDefaults = userDefaults
        self.resolvable = resolvable
    }
    
    func scanCertificateStarted() {
        self.isLoadingScan = true
    }
    
    func scanCertificateEnded() {
        self.isLoadingScan = false
    }
}
