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

private enum Constants {
    static let image = UIImage.resultError

    enum Title {
        static let technical = "technical_validation_check_popup_unsuccessful_certificate_title".localized
        static let functional = "functional_validation_check_popup_unsuccessful_certificate_title".localized
    }
    enum SubTitle {
        static let technical = "technical_validation_check_popup_unsuccessful_certificate_subline".localized
        static let functional = "functional_validation_check_popup_unsuccessful_certificate_subline".localized
    }

    enum Paragraphs {
        static let technicalIssues = [
            Paragraph(icon: .technicalError,
                      title: "technical_validation_check_popup_unsuccessful_certificate_signature_subheading".localized,
                      subtitle: "technical_validation_check_popup_unsuccessful_certificate_signature_subline".localized),
            Paragraph(icon: .scan,
                      title: "technical_validation_check_popup_unsuccessful_certificate_qrreadibility_subheading".localized,
                      subtitle: "technical_validation_check_popup_unsuccessful_certificate_qrreadibility_subline".localized)
        ]
        static let functionalIssues = [
            Paragraph(icon: .activity,
                      title: "functional_validation_check_popup_unsuccessful_certificate_subheadline_expiration".localized,
                      subtitle: "functional_validation_check_popup_unsuccessful_certificate_subheadline_expiration_text".localized),
            Paragraph(icon: .calendar,
                      title: "functional_validation_check_popup_unsuccessful_certificate_subheadline_protection".localized,
                      subtitle: "functional_validation_check_popup_unsuccessful_certificate_subheadline_protection_text".localized),
            Paragraph(icon: .statusPartial,
                      title: "functional_validation_check_popup_unsuccessful_certificate_subheadline_uncompleted".localized,
                      subtitle: "functional_validation_check_popup_unsuccessful_certificate_subheadline_uncompleted_text".localized)
        ]
    }
}

class ErrorResultViewModel: ValidationResultViewModel {
    
    // MARK: - Properties

    weak var delegate: ResultViewModelDelegate?
    var resolvable: Resolver<ExtendedCBORWebToken>
    var router: ValidationResultRouterProtocol
    var repository: VaccinationRepositoryProtocol
    var certificate: ExtendedCBORWebToken?
    var error: Error
    let revocationKeyFilename: String
    let countdownTimerModel: CountdownTimerModel? = nil
    private var validationResultError: ValidationResultError {
        error as? ValidationResultError ?? .technical        
    }

    var icon: UIImage? {
        Constants.image
    }

    var resultTitle: String {
        validationResultError == .functional ? Constants.Title.functional : Constants.Title.technical
    }

    var resultBody: String {
        validationResultError == .functional ? Constants.SubTitle.functional : Constants.SubTitle.technical
    }

    var paragraphs: [Paragraph] {
        validationResultError == .functional ? Constants.Paragraphs.functionalIssues : Constants.Paragraphs.technicalIssues
    }

    var info: String? {
        nil
    }
    
    var revocationInfoHidden: Bool {
        let revocationExportModeIsDisabled = !userDefaults.revocationExpertMode
        let isNotAnFunctionalError = !((error as? ValidationResultError) == .functional)
        return revocationExportModeIsDisabled || isNotAnFunctionalError || _2GContext
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
         certificate: ExtendedCBORWebToken? = nil,
         error: Error,
         _2GContext: Bool,
         userDefaults: Persistence,
         revocationKeyFilename: String) {
        self.resolvable = resolvable
        self.router = router
        self.repository = repository
        self.certificate = certificate
        self.error = error
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
