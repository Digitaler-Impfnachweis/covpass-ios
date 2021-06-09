//
//  CertificateDetailViewModel.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import PromiseKit
import UIKit
import CovPassCommon
import CovPassUI
import PromiseKit
import UIKit

class CertificateDetailViewModel: CertificateDetailViewModelProtocol {
    // MARK: - Properties

    weak var delegate: ViewModelDelegate?
    var router: CertificateDetailRouterProtocol
    private let repository: VaccinationRepositoryProtocol
    private var certificates: [ExtendedCBORWebToken]
    private let resolver: Resolver<CertificateDetailSceneResult>?
    private var isFavorite = false

    var fullImmunization: Bool {
        certificates.map { $0.vaccinationCertificate.hcert.dgc.v?.first?.fullImmunization ?? false }.first(where: { $0 }) ?? false
    }

    var favoriteIcon: UIImage? {
        isFavorite ? .starFull : .starPartial
    }

    var name: String {
        certificates.first?.vaccinationCertificate.hcert.dgc.nam.fullName ?? ""
    }

    var birthDate: String {
        guard let date = certificates.first?.vaccinationCertificate.hcert.dgc.dob else { return "" }
        return DateUtils.displayDateFormatter.string(from: date)
    }

    var immunizationIcon: UIImage? {
        fullImmunization ? .statusFull : .statusPartial
    }

    var immunizationTitle: String {
        guard let cert = certificates.sorted(by: { c, _ in c.vaccinationCertificate.hcert.dgc.v?.first?.fullImmunization ?? false }).first?.vaccinationCertificate.hcert.dgc.v?.first else {
            return ""
        }
        if !fullImmunization {
            return String(format: "vaccination_certificate_detail_view_incomplete_title".localized, 1, 2)
        }
        if cert.fullImmunizationValid {
            return "vaccination_certificate_detail_view_complete_title".localized
        } else if let date = cert.fullImmunizationValidFrom, fullImmunization {
            return String(format: "vaccination_start_screen_qrcode_complete_from_date_subtitle".localized, DateUtils.displayDateFormatter.string(from: date))
        }

        return String(format: "vaccination_certificate_detail_view_incomplete_title".localized, 1, 2)
    }

    var immunizationBody: String {
        fullImmunization ?
            "vaccination_certificate_detail_view_complete_message".localized :
            "vaccination_certificate_detail_view_incomplete_message".localized
    }

    var immunizationButton: String {
        fullImmunization ?
            "vaccination_certificate_detail_view_complete_action_button_title".localized :
            "vaccination_certificate_detail_view_incomplete_action_button_title".localized
    }

    var items: [CertificateItem] {
        certificates
            .sorted(by: { $0.vaccinationCertificate.iat ?? Date() < $1.vaccinationCertificate.iat ?? Date() })
            .map({ cert in
                let vm = VaccinationCertificateItemViewModel(cert)
                return CertificateItem(viewModel: vm, action: {
                    self.router.showDetail(for: cert).done({
                        self.resolver?.fulfill($0)
                    }).cauterize()
                })
            })
    }

    // MARK: - Lifecyle

    init(
        router: CertificateDetailRouterProtocol,
        repository: VaccinationRepositoryProtocol,
        certificates: [ExtendedCBORWebToken],
        resolvable: Resolver<CertificateDetailSceneResult>?
    ) {
        self.router = router
        self.repository = repository
        self.certificates = certificates
        resolver = resolvable
    }

    // MARK: - Methods

    func refresh() {
        refreshFavoriteState()
    }

    func immunizationButtonTapped() {
        showCertificatesOnOverview()
    }

    func toggleFavorite() {
        guard let id = self.certificates.first?.vaccinationCertificate.hcert.dgc.v?.first?.ci else {
            self.showErrorDialog()
            return
        }
        firstly {
            repository.toggleFavoriteStateForCertificateWithIdentifier(id)
        }
        .get { isFavorite in
            self.isFavorite = isFavorite
        }
        .done { _ in
            self.delegate?.viewModelDidUpdate()
        }
        .catch { _ in
            self.showErrorDialog()
        }
    }

    private func refreshFavoriteState() {
        firstly {
            repository.favoriteStateForCertificates(certificates)
        }
        .get { isFavorite in
            self.isFavorite = isFavorite
        }
        .done { _ in
            self.delegate?.viewModelDidUpdate()
        }
        .catch { _ in
            self.showErrorDialog()
        }
    }

    private func showErrorDialog() {
        router.showUnexpectedErrorDialog()
    }

    private func showCertificatesOnOverview() {
        resolver?.fulfill(.showCertificatesOnOverview(certificates))
    }
}
