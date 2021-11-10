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

    private var selectedCertificate: ExtendedCBORWebToken? {
        certificates?.filter(type: .vaccination, givenName: "ERIKA<DOERTE", familyName: "SCHMITT<MUSTERMANN", dob: "1964-08-12").first
    }
    
    private var filteredCertificates: [ExtendedCBORWebToken] {
        certificates?.filter(type: .vaccination, givenName: "ERIKA<DOERTE", familyName: "SCHMITT<MUSTERMANN", dob: "1964-08-12") ?? []
    }

    var name: String {
        certificates?.first?.vaccinationCertificate.hcert.dgc.nam.fullName ?? ""
    }

    var nameReversed: String {
        certificates?.first?.vaccinationCertificate.hcert.dgc.nam.fullNameReverse ?? ""
    }

    var nameTransliterated: String {
        certificates?.first?.vaccinationCertificate.hcert.dgc.nam.fullNameTransliteratedReverse ?? ""
    }

    var birthDate: String {
        guard let dgc = certificates?.first?.vaccinationCertificate.hcert.dgc else { return "" }
        return DateUtils.displayIsoDateOfBirth(dgc)
    }
    
    
    var items: [CertificateItem] {
        filteredCertificates
            .reversed()
            .compactMap { cert in
                let active = cert == selectedCertificate
                var vm: CertificateItemViewModel?
                if cert.vaccinationCertificate.hcert.dgc.r != nil {
                    vm = RecoveryCertificateItemViewModel(cert, active: active)
                }
                if cert.vaccinationCertificate.hcert.dgc.t != nil {
                    vm = TestCertificateItemViewModel(cert, active: active)
                }
                if cert.vaccinationCertificate.hcert.dgc.v != nil {
                    vm = VaccinationCertificateItemViewModel(cert, active: active)
                }
                if vm == nil {
                    return nil
                }
                return CertificateItem(viewModel: vm!, action: {
                    
                    
                })
            }
    }
    
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

    
    // MARK: - Lifecyle

    init(
        router: ChooseCertificateRouterProtocol,
        repository: VaccinationRepositoryProtocol,
        resolvable: Resolver<Void>?
    ) {
        self.router = router
        self.repository = repository
        resolver = resolvable
    }

    // MARK: - Methods
}
