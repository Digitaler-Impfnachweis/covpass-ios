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
    var router: ChooseCertificateRouterProtocol
    private let repository: VaccinationRepositoryProtocol
    private var certificates: [ExtendedCBORWebToken]? {
        certificateList.certificates
    }
    private let resolver: Resolver<Void>?
    private var certificateList = CertificateList(certificates: [])

    private var filteredCertificates: [ExtendedCBORWebToken] {
        certificates?.filter(types: [.vaccination], givenName: "ERIKA<DOERTEs", familyName: "SCHMITT<MUSTERMANN", dob: "1964-08-12") ?? []
    }
    
    var title: String {
        return Constant.Keys.title
    }
    
    var subtitle: String {
        return Constant.Keys.subtitle
    }
    
    var certdetails: String {
        return "\(name)\n\(dateOfBirth)\n\(availableCertTypes)"
    }

    var name: String {
        certificates?.first?.vaccinationCertificate.hcert.dgc.nam.fullNameTransliterated ?? ""
    }

    var dateOfBirth: String {
        guard let dgc = certificates?.first?.vaccinationCertificate.hcert.dgc else { return "" }
        return DateUtils.displayIsoDateOfBirth(dgc)
    }
    
    var availableCertTypes: String {
        "\("certificate_check_validity_vaccination".localized)"
    }
    
    var certificatesAvailable: Bool {
        certificates?.count ?? 0 > 0
    }
    
    var items: [CertificateItem] {
        filteredCertificates
            .reversed()
            .compactMap { cert in
                var vm: CertificateItemViewModel?
                if cert.vaccinationCertificate.hcert.dgc.r != nil {
                    vm = RecoveryCertificateItemViewModel(cert)
                }
                if cert.vaccinationCertificate.hcert.dgc.t != nil {
                    vm = TestCertificateItemViewModel(cert)
                }
                if cert.vaccinationCertificate.hcert.dgc.v != nil {
                    vm = VaccinationCertificateItemViewModel(cert)
                }
                if vm == nil {
                    return nil
                }
                return CertificateItem(viewModel: vm!, action: {
                    
                    
                })
            }
    }
    
    // MARK: - Lifecyle

    init(router: ChooseCertificateRouterProtocol,
         repository: VaccinationRepositoryProtocol,
         resolvable: Resolver<Void>?) {
        self.router = router
        self.repository = repository
        resolver = resolvable
    }

    // MARK: - Methods
    
    func refreshCertificates() -> Promise<Void> {
        firstly {
            repository.getCertificateList()
        }
        .get {
            self.certificateList = $0
        }
        .map { list in
            self.delegate?.viewModelDidUpdate()
        }
        .asVoid()
    }
    
    func cancel() {
        resolver?.cancel()
    }
}
