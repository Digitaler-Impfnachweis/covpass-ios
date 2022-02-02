//
//  ConsentExchangeViewModel.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import CovPassCommon
import CovPassUI
import PromiseKit
import JWTDecode

private enum Constants {
    
    static let reuseIdentifier = "cell"
    static let reuseIdentifierHintCell = "hintCell"
    static let reuseIdentifierSubTitleCell = "subTitleCell"
    
    static let numberOfSections = 1
    
    enum Text {
        static let additionalInformation1 = "share_certificate_transmission_notes_first_list_item".localized
        static let additionalInformation2 = "share_certificate_transmission_notes_second_list_item".localized
        static let additionalInformation3 = "share_certificate_transmission_notes_third_list_item".localized
        static let additionalInformation4 = "share_certificate_transmission_notes_fourth_list_item".localized
        static let additionalInformation5 = "share_certificate_transmission_note_privacy_notice".localized
        
        enum HintView {
            static let title = "share_certificate_transmission_consent_title".localized
            static let introText = "share_certificate_transmission_consent_message".localized
            static let bulletText1 = "share_certificate_transmission_consent_first_list_item".localized
            static let bulletText2 = "share_certificate_transmission_consent_second_list_item".localized
            static let bulletText3 = "share_certificate_transmission_consent_second_list_item_first_subitem".localized
            static let bulletText4 = "share_certificate_transmission_consent_second_list_item_second_subitem".localized
            static let bulletText5 = "share_certificate_transmission_consent_second_list_item_third_subitem".localized
            static let bulletText6 = "share_certificate_transmission_consent_second_list_item_fourth_subitem".localized
        }
        
        enum Cell {
            static let providerTitle = "Prüfpartner"
            static let subjectTitle = "share_certificate_transmission_details_provider".localized
        }
    }
}

class ConsentExchangeViewModel {
    
    enum Accessibility {
        static let close = VoiceOverOptions.Settings(label: "accessibility_share_certificate_label_close".localized)
        static let openViewController = VoiceOverOptions.Settings(label: "accessibility_share_certificate_announce".localized)
        static let closeViewController = VoiceOverOptions.Settings(label: "accessibility_share_certificate_closing_announce".localized)
    }
    
    enum Rows: Int, CaseIterable {
        case provider = 0, subject, consentHeader, hintView, additionalInformation, privacyLink
        
        var cellTitle: String {
            switch self {
            case .provider:
                return Constants.Text.Cell.providerTitle
            case .subject:
                return Constants.Text.Cell.subjectTitle
            case .hintView:
                return Constants.Text.HintView.title
            default:
                return ""
            }
        }
        
        var reuseIdentifier: String {
            switch self {
            case .provider, .subject:
                return Constants.reuseIdentifierSubTitleCell
            case .hintView:
                return Constants.reuseIdentifierHintCell
            default:
                return Constants.reuseIdentifier
            }
        }
        
    }
    
    weak var delegate: ViewModelDelegate?
    let router: ValidationServiceRoutable
    let initialisationData: ValidationServiceInitialisation
    let certificate: ExtendedCBORWebToken
    private let vaasRepository: VAASRepositoryProtocol
    private let userDefaults = UserDefaultsPersistence()
    
    var additionalInformation: NSAttributedString {
        let bullets = NSAttributedString().appendBullets([Constants.Text.additionalInformation1.styledAs(.body),
                                                          Constants.Text.additionalInformation2.styledAs(.body),
                                                          Constants.Text.additionalInformation3.styledAs(.body),
                                                          Constants.Text.additionalInformation4.styledAs(.body)],
                                                         spacing: nil)
        let attrString = NSMutableAttributedString(attributedString: bullets)
        
        attrString.append(NSAttributedString(string: "\n\n"))
        
        attrString.append(Constants.Text.additionalInformation5.styledAs(.body).colored(.onBackground70, in: nil))
        return attrString
    }
    
    var hintViewText: NSAttributedString {
        String(format: Constants.Text.HintView.introText, vaasRepository.selectedValidationService?.name ?? "").styledAs(.body)
            .appendBullets([
                String(format: Constants.Text.HintView.bulletText1, initialisationData.serviceProvider).styledAs(.body),
                String(format: Constants.Text.HintView.bulletText2, initialisationData.serviceProvider).styledAs(.body),
                Constants.Text.HintView.bulletText3.styledAs(.body),
                Constants.Text.HintView.bulletText4.styledAs(.body),
                Constants.Text.HintView.bulletText5.styledAs(.body),
                Constants.Text.HintView.bulletText6.styledAs(.body)
            ], spacing: 12)
    }
    
    var numberOfSections: Int {
        Constants.numberOfSections
    }
    
    var numberOfRows: Int {
        Rows.allCases.count
    }
    
    var validationServiceName: String {
        vaasRepository.selectedValidationService?.name ?? ""
    }
    
    var isLoading = false
    
    internal init(router: ValidationServiceRoutable, vaasRepository: VAASRepositoryProtocol, initialisationData: ValidationServiceInitialisation, certificate: ExtendedCBORWebToken) {
        self.router = router
        self.initialisationData = initialisationData
        self.certificate = certificate
        self.vaasRepository = vaasRepository
    }
    
    
    func cancel() {
        firstly {
            router.routeToWarning()
        }
        .done { canceled in
            if canceled {
                self.vaasRepository.cancellation()
            }
        }
        .cauterize()
    }
    
    func routeToPrivacyStatement() {
        router.routeToPrivacyStatement(url: initialisationData.privacyUrl)
    }
    
    private func handleApiErrors(_ error: Error) {
        self.router.showNoVerificationSubmissionPossible(error: error)
            .done { canceled in
                if canceled {
                    self.vaasRepository.cancellation()
                }
            }
            .cauterize()
    }
    
    private func handleVaasErrors(_ error: Error) {
        self.router.showNoVerificationPossible(error: error)
            .done { canceled in
                if canceled {
                    self.vaasRepository.cancellation()
                }
            }
            .cauterize()
    }
    
    private func errorHandling(_ error: Error) {
        if error is APIError {
            handleApiErrors(error)
        } else if error is VAASErrors {
            handleVaasErrors(error)
        } else {
            self.router.showUnexpectedErrorDialog(error)
        }
    }
    
    func routeToValidation() {
        firstly {
            self.isLoading = true
            self.delegate?.viewModelDidUpdate()
        }
        .then {
            try self.vaasRepository.validateTicketing(choosenCert: self.certificate)
        }
        .ensure { [weak self] in
            self?.isLoading = false
            self?.delegate?.viewModelDidUpdate()
        }
        .done { accessToken in
            self.router.showCertificate(self.certificate,
                                        with: accessToken,
                                        userDefaults: self.userDefaults)
        }
        .catch { error in
            self.errorHandling(error)
        }
    }
}
