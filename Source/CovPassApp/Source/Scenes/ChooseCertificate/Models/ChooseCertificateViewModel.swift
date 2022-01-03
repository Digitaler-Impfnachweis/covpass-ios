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
    private var vaasRepository: VAASRepositoryProtocol
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
                    self.chooseSert(cert: cert)
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
    
    func runMainProcess() {
        isLoading = true
        self.delegate?.viewModelDidUpdate()
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
            self.givenNameFilter = accessToken.vc?.gnt?.trimmingCharacters(in: .whitespaces) ?? ""
            self.familyNameFilter = accessToken.vc?.fnt?.trimmingCharacters(in: .whitespaces) ?? ""
            self.dobFilter = accessToken.vc?.dob ?? ""
            self.typeFilter = accessToken.vc?.type?.compactMap{ CertType(rawValue: $0) } ?? []
        }
        .done { () in
            self.isLoading = false
            self.delegate?.viewModelDidUpdate()
        }.catch { error in
            
            switch self.vaasRepository.step {
            case .downloadIdentityDecorator:
                if let error = error as? APIError {
                    if error == .trustList {
                        self.router?.showValidationFailed(ticket: self.vaasRepository.ticket)
                            .done{ shouldContinue in
                                if shouldContinue {
                                    self.vaasRepository.useUnsecureApi = true
                                    self.runMainProcess()
                                } else {
                                    self.cancel()
                                }
                            }
                            .cauterize()
                    } else {
                        self.router?.showIdentityDocumentApiError(error: error, provider: self.vaasRepository.ticket.serviceProvider)
                            .done { canceled in
                                if canceled {
                                    self.vaasRepository.cancellation()
                                }
                            }
                            .cauterize()
                    }
                } else if error is VAASErrors {
                    self.router?.showIdentityDocumentVAASError(error: error)
                        .done { canceled in
                            if canceled {
                                self.vaasRepository.cancellation()
                            }
                        }
                        .cauterize()
                } else {
                    self.router?.showUnexpectedErrorDialog(error)
                }
            case .downloadIdentityService:
                if error is APIError {
                    self.router?.showIdentityDocumentApiError(error: error, provider: self.vaasRepository.ticket.serviceProvider)
                        .done { canceled in
                            if canceled {
                                self.vaasRepository.cancellation()
                            }
                        }
                        .cauterize()
                } else {
                    self.router?.showUnexpectedErrorDialog(error)
                }
            case .downloadAccessToken:
                if error is APIError {
                    self.router?.accessTokenNotRetrieved(error: error)
                        .done { canceled in
                            if canceled {
                                self.vaasRepository.cancellation()
                            }
                        }
                        .cauterize()
                } else if error is VAASErrors {
                    self.router?.showAccessTokenNotProcessed(error: error)
                        .done { canceled in
                            if canceled {
                                self.vaasRepository.cancellation()
                            }
                        }
                        .cauterize()
                } else {
                    self.router?.showUnexpectedErrorDialog(error)
                }
            }
            self.isLoading = false
            self.delegate?.viewModelDidUpdate()
        }
        
    }
    
    func cancel() {
        firstly {
            router?.routeToWarning() ?? .init(error: APIError.invalidResponse)
        }
        .done { canceled in
            if canceled {
                self.vaasRepository.cancellation()
            }
        }
        .cauterize()
    }
    
    func back() {
        resolver?.cancel()
        vaasRepository.cancellation()
    }
    
    func chooseSert(cert: ExtendedCBORWebToken) {
        router?.routeToCertificateConsent(ticket: vaasRepository.ticket, certificate: cert, vaasRepository: self.vaasRepository)
    }
}
