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

enum ValidationResultError: Error {
    case technical
    case functional
}

class ErrorResultViewModel: ValidationResultViewModel {
    
    // MARK: - Properties
    
    weak var delegate: ResultViewModelDelegate?
    var resolvable: Resolver<ExtendedCBORWebToken>
    var router: ValidationResultRouterProtocol
    var repository: VaccinationRepositoryProtocol
    var certificate: ExtendedCBORWebToken?
    var token: VAASValidaitonResultToken?
    var error: Error
    let revocationKeyFilename = ""
    let countdownTimerModel: CountdownTimerModel? = nil
    let revocationRepository: CertificateRevocationRepositoryProtocol? = nil
    
    private var validationResultError: ValidationResultError {
        error as? ValidationResultError ?? .technical
    }
    
    var icon: UIImage? {
        token?.result == .crossCheck ? .resultOpen : .resultError
    }
    
    var resultTitle: String {
        token?.result == .crossCheck ?
        "share_certificate_detail_view_requirements_not_verifiable_title".localized :
        "share_certificate_detail_view_requirements_not_met_title".localized
    }
    
    var resultBody: String {
        token?.result == .crossCheck ?
        String(format: "share_certificate_detail_view_requirements_not_verifiable_subline".localized, token?.verifyingService ?? "") :
        String(format: "share_certificate_detail_view_requirements_not_met_subline".localized, token?.verifyingService ?? "")
    }
    
    var paragraphSubtitle: String {
        token?.result == .crossCheck ?
        String(format: "share_certificate_detail_view_requirements_not_verifiable_message".localized, token?.provider ?? "") :
        String(format: "share_certificate_detail_view_requirements_not_met_message".localized, token?.provider ?? "")
    }
    
    var paragraphs: [Paragraph] {
        var paragraphs = [
            Paragraph(
                icon: .none,
                title: "",
                subtitle: paragraphSubtitle
            )
        ]
        
        let variableParagraphs = token?.results.map({ result in
            Paragraph(
                icon: token?.result == .crossCheck ? .warning : .error,
                title: result.details,
                subtitle: ""
            )
        }) ?? []
        
        paragraphs.append(contentsOf: variableParagraphs)
        return paragraphs
    }
    
    var info: String? {
        nil
    }
    
    var buttonHidden: Bool = false
    var _2GContext: Bool = false
    var userDefaults: Persistence
    var isLoadingScan: Bool = false
    
    // MARK: - Lifecycle
    
    init(resolvable: Resolver<ExtendedCBORWebToken>,
         router: ValidationResultRouterProtocol,
         repository: VaccinationRepositoryProtocol,
         certificate: ExtendedCBORWebToken? = nil,
         error: Error,
         token: VAASValidaitonResultToken?,
         userDefaults: Persistence) {
        self.router = router
        self.repository = repository
        self.certificate = certificate
        self.error = error
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
