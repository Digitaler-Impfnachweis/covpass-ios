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
            static var actionButton = "share_certificate_selection_no_match_action button".localized
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
    var router: ChooseCertificateRouterProtocol?
    private let repository: VaccinationRepositoryProtocol
    private let resolver: Resolver<Void>?
    private var certificates: [ExtendedCBORWebToken]? { certificateList.certificates }
    private var certificateList = CertificateList(certificates: [])
    private var filteredCertificates: [ExtendedCBORWebToken] {
        certificates?.filter(types: typeFilter,
                             givenName: givenNameFilter,
                             familyName: familyNameFilter,
                             dob: dobFilter) ?? []
    }
    
    var typeFilter: [CertType]
    
    var givenNameFilter: String
    
    var familyNameFilter: String
    
    var dobFilter: String
    
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
        return "\(givenNameFilter) \(familyNameFilter)\n\(dobLabel): \(dobFilter)\n\(availableCertTypes)"
    }
    
    var availableCertTypes: String {
        var string = ""
        typeFilter.forEach { certType in
            switch certType {
            case .recovery: string.append(Constant.Keys.recoveryLabel)
            case .test: string.append(Constant.Keys.testLabel)
            case .vaccination: string.append(Constant.Keys.vaccinationLabel)
            }
            if typeFilter.last != certType {
                string.append(", ")
            }
        }
        return string
    }
    
    var certificatesAvailable: Bool {
        filteredCertificates.count > 0
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
                    
                    
                })
            }
    }
    
    var isLoading = false
    
    // MARK: - Lifecyle

    init(router: ChooseCertificateRouterProtocol?,
         repository: VaccinationRepositoryProtocol,
         resolvable: Resolver<Void>?,
         givenNameFilter: String = "ERIKA<DOERTE",
         familyNameFilter: String = "SCHMITT<MUSTERMANN",
         dobFilter: String = "1964-08-12",
         typeFilter: [CertType] =  [.vaccination, .recovery, .test]) {
        self.router = router
        self.repository = repository
        resolver = resolvable
        
        self.givenNameFilter = givenNameFilter
        self.familyNameFilter = familyNameFilter
        self.dobFilter = dobFilter
        self.typeFilter = typeFilter
    }

    // MARK: - Methods
    
    func refreshCertificates() {
        isLoading = true
        firstly {
            repository.getCertificateList()
        }
        .get {
            self.certificateList = $0
        }
        .map {  [weak self] list in
            self?.isLoading = false
            self?.delegate?.viewModelDidUpdate()
        }
        .cauterize()
    }
    
    func cancel() {
        resolver?.cancel()
    }
}
