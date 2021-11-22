//
//  ChooseCertificateViewModel.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import PromiseKit
import UIKit

public enum Constant {
    enum Keys {
        static var title = "share_certificate_selection_title".localized
        static var subtitle = "share_certificate_selection_message".localized
        static var dobLabel = "share_certificate_selection_requirements_date_of_birth".localized
        static var recoveryLabel = "certificates_overview_recovery_certificate_title".localized
        static var testLabel = "certificates_overview_test_certificate_title".localized
        static var vaccinationLabel = "certificates_overview_vaccination_certificate_title".localized
        enum NoMatch {
            static var title = "share_certificate_selection_no_match_title".localized
            static var subtitle = "share_certificate_selection_no_match_subline".localized
            static var actionButton = "share_certificate_selection_no_match_action_button".localized
            static var image = UIImage.prevention
        }
    }
    enum Accessibility {
        static var labelClose = "accessibility_share_certificate_selection_label_close".localized
        static var labelBack = "accessibility_share_certificate_selection_label_back".localized
        static var openingAnnounce = "accessibility_share_certificate_selection_announce".localized
        static var closingAnnounce = "accessibility_share_certificate_selection_closing_announce".localized
    }
}

class ChooseCertificateViewModel: ChooseCertificateViewModelProtocol {
    // MARK: - Properties

    weak var delegate: ViewModelDelegate?
    var router: ValidationServiceRoutable?
    private let repository: VaccinationRepositoryProtocol
    private let vaasRepository: VAASRepositoryProtocol
    private let resolver: Resolver<Void>?
    private var certificates: [ExtendedCBORWebToken]? { certificateList.certificates }
    private var certificateList = CertificateList(certificates: [])
    private var filteredCertificates: [ExtendedCBORWebToken] {
        guard let typeFilter = typeFilter,
              let givenNameFilter = givenNameFilter,
              let familyNameFilter = familyNameFilter,
              let dobFilter = dobFilter else {
                  return []
              }
        return certificates?.filter(types: typeFilter,
                                    givenName: givenNameFilter,
                                    familyName: familyNameFilter,
                                    dob: dobFilter) ?? []
    }
    
    var typeFilter: [CertType]?
    
    var givenNameFilter: String?
    
    var familyNameFilter: String?
    var dobFilter: String?
    var validationServiceName: String = ""

    
    var title: String {
        return Constant.Keys.title
    }
    
    var subtitle: String {
        return Constant.Keys.subtitle
    }
    
    var dobLabel: String {
        return Constant.Keys.dobLabel
    }
    
    var certdetails: String {
        guard let givenNameFilter = givenNameFilter,
              let familyNameFilter = familyNameFilter,
              let dobFilter = dobFilter else {
                  return ""
              }
        return "\(givenNameFilter) \(familyNameFilter)\n\(dobLabel): \(dobFilter)\n\(availableCertTypes)"
    }
    
    var availableCertTypes: String {
        guard let typeFilter = typeFilter else {
            return ""
        }
        return typeFilter.map {
            switch $0 {
            case .recovery: return Constant.Keys.recoveryLabel
            case .test: return Constant.Keys.testLabel
            case .vaccination: return Constant.Keys.vaccinationLabel
            }
        }
        .joined(separator: ", ")
    }
    
    var certificatesAvailable: Bool {
        !filteredCertificates.isEmpty
    }
    
    var noMatchTitle: String {
        Constant.Keys.NoMatch.title
    }
    
    var noMatchSubtitle: String {
        Constant.Keys.NoMatch.subtitle
    }

    var noMatchImage: UIImage {
        Constant.Keys.NoMatch.image
    }
    
    var items: [CertificateItem] {
        filteredCertificates
            .reversed()
            .compactMap { cert in
                var vm: CertificateItemViewModel?
                if cert.vaccinationCertificate.hcert.dgc.r != nil {
                    vm = RecoveryCertificateItemViewModel(cert, active: true, neutral: true)
                }
                if cert.vaccinationCertificate.hcert.dgc.t != nil {
                    vm = TestCertificateItemViewModel(cert, active: true, neutral: true)
                }
                if cert.vaccinationCertificate.hcert.dgc.v != nil {
                    vm = VaccinationCertificateItemViewModel(cert, active: true, neutral: true)
                }
                if vm == nil {
                    return nil
                }
                return CertificateItem(viewModel: vm!, action: {
                    //self.chooseSert(cert: cert)
                })
            }
    }
    
    var isLoading = false
    
    // MARK: - Lifecyle

    init(router: ValidationServiceRoutable?,
         repository: VaccinationRepositoryProtocol,
         vaasRepository: VAASRepositoryProtocol,
         resolvable: Resolver<Void>?) {
        self.router = router
        self.repository = repository
        self.resolver = resolvable
        self.vaasRepository = vaasRepository
    }

    // MARK: - Methods
    
    func goLive() {
        isLoading = true
        firstly {
            repository.getCertificateList()
        }
        .map { certificateList in
            self.certificateList = certificateList
        }
        .then {
            self.vaasRepository.fetchValidationService()
        }
        .map { accessToken in
            self.givenNameFilter = accessToken.vc?.gnt ?? ""
            self.familyNameFilter = accessToken.vc?.fnt ?? ""
            self.dobFilter = accessToken.vc?.dob ?? ""
            self.typeFilter = accessToken.vc?.type?.compactMap{ CertType(rawValue: $0) } ?? []
        }
        .done { () in
            self.isLoading = false
            self.delegate?.viewModelDidUpdate()
        }.catch { error in
            
            self.vaasRepository.step
            
            switch self.vaasRepository.step {
            case .downloadIdentityDecorator:
                // Step 1
                // 1. Error during download: (Error Message 2 – Identity of Service Provider cannot be verified + Error Code + Trigger Cancellation Process).
                if error is APIError {
                    self.router?.showError2(error: error)
                }
                
                //  If not in Allow-List error message "The Validation Service is not trusted - please contact xy" (Cancellation Screen 2 – Validation Service cannot be trusted + Trigger Cancellation Process). Show this only if there is no other listed Validation Service which is a trusted one (should there be an indication that some are not trusted?).
                
                
            case .downloadIdentityService:
                // Step2
                // a) Not found: Error message "Validation Service not identifiable" or
                // b) Error during download: (Error Message 3 - – Identity of Validation Service cannot be verified + Error Code + Trigger Cancellation Process)
                if error is APIError {
                    self.router?.showError3(error: error)
                }
            case .downloadAccessToken:
                
                // Step 5
                // The endpoint returns an access token for the validation service which contains the information of the booking session. If error occurs: Display error message "Connection to service provider failed. Access for validation service could not be requested + error code from Reponse". (Or similar text) (Error Message 4 –Cannot connect to Service Provider + Error Code + Trigger Cancellation Process).
                if error is APIError {
                    self.router?.showError4(error: error)
                }
            }
            


            
            // Step 4
            // 4.) Check AccessTokenServiceKey-X against AccessTokenService“-Endpoint -> If fails: (Error Message 3 - – Identity of Validation Service cannot be verified + Trigger Cancellation Process).
      
            
            // Step 6
            // -> If fails: Error message: „Validation Service not valid anymore? “ (Error Message 3 - – Identity of Validation Service cannot be verified + Trigger Cancellation Process).
            
            self.isLoading = false
            self.delegate?.viewModelDidUpdate()
        }
    }
    
    func cancel() {
        resolver?.cancel()
    }
    
    func chooseSert(cert: ExtendedCBORWebToken) {
        router?.routeToCertificateConsent(ticket: vaasRepository.ticket, certificate: cert, vaasRepository: self.vaasRepository)
//        firstly {
//            try vaasRepository.validateTicketing(choosenCert: cert)
//        }
//        .done { () in
//            
//        }
    }
}
