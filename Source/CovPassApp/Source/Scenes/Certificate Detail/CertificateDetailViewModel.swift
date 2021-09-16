//
//  CertificateDetailViewModel.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

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
    private let boosterLogic: BoosterLogic
    private let boosterCandidate: BoosterCandidate?
    private let resolver: Resolver<CertificateDetailSceneResult>?
    private var isFavorite = false
    private var showFavorite = false

    private var selectedCertificate: ExtendedCBORWebToken? {
        CertificateSorter.sort(certificates).first
    }

    var fullImmunization: Bool {
        certificates.map { $0.vaccinationCertificate.hcert.dgc.v?.first?.fullImmunization ?? false }.first(where: { $0 }) ?? false
    }

    var immunizationButton: String {
        if selectedCertificate?.vaccinationCertificate.isInvalid ?? false {
            return "certificates_overview_expired_action_button_title".localized
        }
        return "recovery_certificate_overview_action_button_title".localized
    }

    var favoriteIcon: UIImage? {
        if !showFavorite { return nil }
        return isFavorite ? .starFull : .starPartial
    }

    var name: String {
        certificates.first?.vaccinationCertificate.hcert.dgc.nam.fullName ?? ""
    }

    var nameReversed: String {
        certificates.first?.vaccinationCertificate.hcert.dgc.nam.fullNameReverse ?? ""
    }

    var nameTransliterated: String {
        certificates.first?.vaccinationCertificate.hcert.dgc.nam.fullNameTransliteratedReverse ?? ""
    }

    var birthDate: String {
        guard let dgc = certificates.first?.vaccinationCertificate.hcert.dgc else { return "" }
        return DateUtils.displayDateOfBirth(dgc)
    }

    var immunizationIcon: UIImage? {
        if selectedCertificate?.vaccinationCertificate.isExpired ?? false || selectedCertificate?.vaccinationCertificate.isInvalid ?? false {
            return .statusExpired
        }
        if selectedCertificate?.vaccinationCertificate.hcert.dgc.r != nil {
            return .statusFull
        }
        if selectedCertificate?.vaccinationCertificate.hcert.dgc.t != nil {
            return .statusFull
        }
        return fullImmunization ? .statusFull : .statusPartial
    }

    var immunizationTitle: String {
        if selectedCertificate?.vaccinationCertificate.isExpired ?? false {
            return "certificate_expired_detail_view_note_title".localized
        }
        if selectedCertificate?.vaccinationCertificate.isInvalid ?? false {
            return "certificate_invalid_detail_view_note_title".localized
        }
        if let r = selectedCertificate?.vaccinationCertificate.hcert.dgc.r?.first {
            if Date() < r.df {
                return String(format: "recovery_certificate_overview_valid_from_title".localized, DateUtils.displayDateFormatter.string(from: r.df))
            }
            return String(format: "recovery_certificate_overview_valid_until_title".localized, DateUtils.displayDateFormatter.string(from: r.du))
        }
        if let t = selectedCertificate?.vaccinationCertificate.hcert.dgc.t?.first {
            if t.isPCR {
                return String(format: "pcr_test_certificate_overview_title".localized, DateUtils.displayDateTimeFormatter.string(from: t.sc))
            }
            return String(format: "test_certificate_overview_title".localized, DateUtils.displayDateTimeFormatter.string(from: t.sc))
        }
        guard let cert = certificates.sorted(by: { c, _ in c.vaccinationCertificate.hcert.dgc.v?.first?.fullImmunization ?? false }).first?.vaccinationCertificate.hcert.dgc.v?.first else {
            return ""
        }
        if cert.fullImmunizationValid {
            return "vaccination_certificate_overview_complete_title".localized
        } else if let date = cert.fullImmunizationValidFrom, fullImmunization {
            return String(format: "vaccination_certificate_overview_complete_from_title".localized, DateUtils.displayDateFormatter.string(from: date))
        }

        return String(format: "vaccination_certificate_overview_incomplete_title".localized, 1, 2)
    }

    var immunizationBody: String {
        if selectedCertificate?.vaccinationCertificate.isExpired ?? false {
            return "certificates_overview_expired_message".localized
        }
        if selectedCertificate?.vaccinationCertificate.isInvalid ?? false {
            return "certificates_overview_invalid_message".localized
        }
        if let cert = selectedCertificate?.vaccinationCertificate.hcert.dgc.v?.first(where: { $0.fullImmunization }), !cert.fullImmunizationValid {
            return "vaccination_certificate_overview_complete_from_message".localized
        }
        return "recovery_certificate_overview_message".localized
    }

    var items: [CertificateItem] {
        certificates
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
                    self.router.showDetail(for: cert).done {
                        switch $0 {
                        case .didDeleteCertificate:
                            self.certificates = self.certificates.filter { $0 != cert }
                            if self.certificates.count > 0 {
                                self.delegate?.viewModelDidUpdate()
                                self.router.showCertificateDidDeleteDialog()
                            } else {
                                self.resolver?.fulfill($0)
                            }
                        default: break
                        }
                    }.cauterize()
                })
            }
    }

    // MARK: - Booster Notifications

    /// show booster notification until user uploads a new certificate
    var showBoosterNotification: Bool {
        boosterCandidate?.state != BoosterCandidate.BoosterState.none
    }

    /// show new booster notification hint only once
    var showNewBoosterNotification: Bool {
        boosterCandidate?.state == BoosterCandidate.BoosterState.new
    }

    var boosterNotificationTitle: String {
        "vaccination_certificate_overview_booster_vaccination_notification_title".localized
    }

    var boosterNotificationBody: String {
        guard let rule = boosterCandidate?.validationRules.first,
              let description = rule.description.first(where: { $0.lang.lowercased() == Locale.current.languageCode })?.desc ?? rule.description.first?.desc
        else { return "" }
        return "\(String(format: "vaccination_certificate_overview_booster_vaccination_notification_message".localized, description, rule.identifier))\n\n\("vaccination_certificate_overview_faqlink".localized)"
    }

    var boosterNotificationHighlightText: String {
        "vaccination_certificate_overview_booster_vaccination_notification_icon_new".localized
    }

    // MARK: - Lifecyle

    init(
        router: CertificateDetailRouterProtocol,
        repository: VaccinationRepositoryProtocol,
        boosterLogic: BoosterLogic,
        certificates: [ExtendedCBORWebToken],
        resolvable: Resolver<CertificateDetailSceneResult>?
    ) {
        self.router = router
        self.repository = repository
        self.boosterLogic = boosterLogic
        self.certificates = certificates
        boosterCandidate = boosterLogic.checkCertificates(certificates)
        resolver = resolvable
    }

    // MARK: - Methods

    func refresh() {
        refreshFavoriteState()
    }

    func immunizationButtonTapped() {
        if selectedCertificate?.vaccinationCertificate.isInvalid ?? false {
            resolver?.fulfill(.addNewCertificate)
        } else {
            resolver?.fulfill(.showCertificatesOnOverview(certificates))
        }
    }

    func toggleFavorite() {
        guard let id = certificates.first?.vaccinationCertificate.hcert.dgc.uvci else {
            router.showUnexpectedErrorDialog(ApplicationError.unknownError)
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
        .catch { [weak self] error in
            self?.router.showUnexpectedErrorDialog(error)
        }
    }

    private func refreshFavoriteState() {
        firstly {
            repository.favoriteStateForCertificates(certificates)
        }
        .get { isFavorite in
            self.isFavorite = isFavorite
        }
        .then { _ in
            self.repository.getCertificateList()
        }
        .get { certificateList in
            self.showFavorite = certificateList.certificates.count > 1
        }
        .done { _ in
            self.delegate?.viewModelDidUpdate()
        }
        .catch { [weak self] error in
            self?.router.showUnexpectedErrorDialog(error)
        }
    }

    func updateBoosterCandiate() {
        guard var candidate = boosterCandidate, candidate.state == .new else { return }
        candidate.state = .qualified
        boosterLogic.updateBoosterCandidate(candidate)
    }
}
