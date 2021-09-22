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

private enum Constants {
    static let image = UIImage.resultError
    static let title = "functional_validation_check_popup_unsuccessful_certificate_title".localized
    static let subTitle = "functional_validation_check_popup_unsuccessful_certificate_subline".localized
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
            Paragraph(icon: .statusPartialDetail,
                      title: "functional_validation_check_popup_unsuccessful_certificate_subheadline_uncompleted".localized,
                      subtitle: "functional_validation_check_popup_unsuccessful_certificate_subheadline_uncompleted_text".localized)
        ]
    }
}

class ErrorResultViewModel: ValidationResultViewModel {
    // MARK: - Properties

    weak var delegate: ResultViewModelDelegate?
    var router: ValidationResultRouterProtocol
    var repository: VaccinationRepositoryProtocol
    var certificate: CBORWebToken?
    var error: Error

    var icon: UIImage? {
        Constants.image
    }

    var resultTitle: String {
        Constants.title
    }

    var resultBody: String {
        Constants.subTitle
    }

    var paragraphs: [Paragraph] {
        switch self.error.mapToCertificateError() {
        case .positiveResult, .expiredCertifcate:
            return Constants.Paragraphs.functionalIssues
        case .invalidEntity:
            return Constants.Paragraphs.technicalIssues
        }
    }

    var info: String? {
        nil
    }

    // MARK: - Lifecycle

    init(
        router: ValidationResultRouterProtocol,
        repository: VaccinationRepositoryProtocol,
        certificate: CBORWebToken? = nil,
        error: Error
    ) {
        self.router = router
        self.repository = repository
        self.certificate = certificate
        self.error = error
    }
}

private extension Error {
    func mapToCertificateError() -> CertificateError {
        switch self {
        case is CertificateError:
            return self as! CertificateError
        default:
            return .invalidEntity
        }
    }
}
