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

private enum Constants {
    enum Keys {
        enum Reissue {
            static let headline = "certificate_renewal_startpage_headline".localized
            static let description = "certificate_renewal_startpage_copy".localized
            static let newText = "vaccination_certificate_overview_booster_vaccination_notification_icon_new".localized
            static let reissueButtonTitle = "certificate_renewal_detail_view_notification_box_secondary_button".localized
        }
    }
}

class CertificateDetailViewModel: CertificateDetailViewModelProtocol {

    // MARK: - Properties

    weak var delegate: ViewModelDelegate?
    var router: CertificateDetailRouterProtocol
    private let repository: VaccinationRepositoryProtocol
    private var certificates: [ExtendedCBORWebToken]
    private let boosterLogic: BoosterLogicProtocol
    private let boosterCandidate: BoosterCandidate?
    private let resolver: Resolver<CertificateDetailSceneResult>?
    private var isFavorite = false
    private var showFavorite = false

    private var selectedCertificate: ExtendedCBORWebToken? {
        certificates.sortLatest().first
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
        return DateUtils.displayIsoDateOfBirth(dgc)
    }

    var immunizationIcon: UIImage? {
        if selectedCertificate?.vaccinationCertificate.isExpired ?? false || selectedCertificate?.vaccinationCertificate.isInvalid ?? false {
            return UIImage.statusExpiredCircle
        }
        if selectedCertificate?.vaccinationCertificate.expiresSoon ?? false {
            return UIImage.activity
        }
        if selectedCertificate?.vaccinationCertificate.hcert.dgc.r != nil {
            return UIImage.detailStatusFull
        }
        if selectedCertificate?.vaccinationCertificate.hcert.dgc.t != nil {
            return UIImage.detailStatusFull
        }
        return fullImmunization ? UIImage.detailStatusFull : UIImage.detailStatusPartial
    }

    var immunizationTitle: String {
        if selectedCertificate?.vaccinationCertificate.isExpired ?? false {
            return "certificate_expired_detail_view_note_title".localized
        }
        if selectedCertificate?.vaccinationCertificate.expiresSoon ?? false {
            guard let expireDate = selectedCertificate?.vaccinationCertificate.exp else {
                return "certificates_overview_expires_soon_certificate_note".localized
            }
            return String(format: "certificates_overview_soon_expiring_title".localized,
                          DateUtils.displayDateFormatter.string(from: expireDate),
                          DateUtils.displayTimeFormatter.string(from: expireDate))
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
        if let t = selectedCertificate?.firstTest {
            if t.isPCR {
                return String(format: "pcr_test_certificate_overview_title".localized, DateUtils.displayDateTimeFormatter.string(from: t.sc))
            }
            return String(format: "test_certificate_overview_title".localized, DateUtils.displayDateTimeFormatter.string(from: t.sc))
        }

        let sortedByVacs = certificates.sorted(by: { c, _ in
            c.vaccinationCertificate.hcert.dgc.v != nil
        })
        let sortedByFullImmunization = sortedByVacs.sorted(by: { c, _ in
            c.vaccinationCertificate.hcert.dgc.v?.first?.fullImmunization ?? false
        })
        guard let cert = sortedByFullImmunization.first?.vaccinationCertificate.hcert.dgc.v?.first else {
            return "vaccination_certificate_overview_incomplete_title".localized
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
        if selectedCertificate?.vaccinationCertificate.expiresSoon ?? false {
            return "certificates_overview_soon_expiring_subtitle".localized
        }
        if selectedCertificate?.vaccinationCertificate.isInvalid ?? false {
            return "certificates_overview_invalid_message".localized
        }
        if let cert = selectedCertificate?.vaccinationCertificate.hcert.dgc.v?.first(where: { $0.fullImmunization }), !cert.fullImmunizationValid {
            return "vaccination_certificate_overview_complete_from_message".localized
        }
        if (selectedCertificate?.vaccinationCertificate.hcert.dgc.r?.first) != nil {
            return "recovery_certificate_overview_message".localized
        }
        if let t = selectedCertificate?.firstTest {
            return t.isPCR ? "pcr_test_certificate_overview_message".localized : "test_certificate_overview_message".localized
        }
        if !fullImmunization {
            return "vaccination_certificate_overview_incomplete_message".localized
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
                return certItem(vm, cert)
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
    
    // MARK: Reissue Notification
    
    var showReissueNotification: Bool { certificates.qualifiedForReissue }

    var reissueNotificationTitle = Constants.Keys.Reissue.headline

    var reissueNotificationBody = Constants.Keys.Reissue.description

    var reissueNotificationHighlightText = Constants.Keys.Reissue.newText
   
    var reissueButtonTitle = Constants.Keys.Reissue.reissueButtonTitle

    var reissueNew: Bool { !certificates.reissueNewBadgeAlreadySeen }

    // MARK: - Lifecyle

    init(
        router: CertificateDetailRouterProtocol,
        repository: VaccinationRepositoryProtocol,
        boosterLogic: BoosterLogicProtocol,
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
            guard let cert = certificates.sortLatest().first else {
                return
            }
            router.showCertificate(for: cert)
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
    
    func updateReissueCandidate(to value: Bool) {
        if certificates.qualifiedForReissue {
            self.repository.setReissueProcess(initialAlreadySeen: value,
                                              newBadgeAlreadySeen: value,
                                              tokens: self.certificates.filterBoosterAfterVaccinationAfterRecovery).cauterize()
        }
    }
    
    func updateBoosterCandiate() {        
        guard var candidate = boosterCandidate, candidate.state == .new else { return }
        candidate.state = .qualified
        boosterLogic.updateBoosterCandidate(candidate)
    }
    
    func refreshCertsAndUpdateView() -> Promise<Void> {
        firstly {
            self.repository.getCertificateList()
        }
        .map {
            self.certificates = $0.certificates
        }
        .done {
            self.delegate?.viewModelDidUpdate()
        }
    }
    
    func triggerReissue() {
        router.showReissue(for: certificates.filterBoosterAfterVaccinationAfterRecovery)
            .ensure {
                self.refreshCertsAndUpdateView().cauterize()
            }
            .cauterize()
    }
    
    // MARK: Private methods
    
    private func removeReissueDataIfBoosterWasDeleted() {
        if certificates.filterBoosted.isEmpty {
            updateReissueCandidate(to: false)
        }
    }
    
    private func certDetailDoneDidDeleteCertificate(_ cert: ExtendedCBORWebToken, _ result: CertificateDetailSceneResult) {
        certificates = certificates.filter { $0 != cert }
        if certificates.count > 0 {
            delegate?.viewModelDidUpdate()
            router.showCertificateDidDeleteDialog()
            removeReissueDataIfBoosterWasDeleted()
        } else {
            resolver?.fulfill(result)
        }
    }
    
    private func certetailDone(_ result: CertificateDetailSceneResult, cert: ExtendedCBORWebToken) {
        switch result{
        case .didDeleteCertificate:
            certDetailDoneDidDeleteCertificate(cert, result)
        default: break
        }
    }
    
    private func certItem(_ vm: CertificateItemViewModel?,
                          _ cert: ReversedCollection<[ExtendedCBORWebToken]>.Element) -> CertificateItem? {
        return CertificateItem(viewModel: vm!) {
            self.router.showDetail(for: cert).done { [weak self] in
                self?.certetailDone($0, cert: cert)
            }.cauterize()
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
}
