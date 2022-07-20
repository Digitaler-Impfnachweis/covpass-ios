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
            static let boosterHeadline = "certificate_renewal_startpage_headline".localized
            static let boosterDescription = "certificate_renewal_startpage_copy".localized
            static let newText = "vaccination_certificate_overview_booster_vaccination_notification_icon_new".localized
            static let boosterButtonTitle = "certificate_renewal_detail_view_notification_box_secondary_button".localized
            static let expiryHeadline = "renewal_expiry_notification_title".localized
            static let vaccinationExpiryDescription = "renewal_expiry_notification_copy_vaccination".localized
            static let recoveryExpiryDescription = "renewal_expiry_notification_copy_recovery".localized
            static let vaccinationExpiryButtonTitle = "renewal_expiry_notification_button_vaccination".localized
            static let recoveryExpiryButtonTitle = "renewal_expiry_notification_button_recovery".localized
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
    private let resolver: Resolver<CertificateDetailSceneResult>
    private var isFavorite = false
    private var showFavorite = false

    private var selectedCertificate: ExtendedCBORWebToken? {
        certificates.sortLatest().first
    }

    private var selectedToken: CBORWebToken? {
        selectedCertificate?.vaccinationCertificate
    }

    private var selectedDgc: DigitalGreenCertificate?  {
        selectedToken?.hcert.dgc
    }

    private var selectedCertificateIsRevoked: Bool {
        selectedCertificate?.isRevoked ?? false
    }

    private var selectedCertificatetIsInvalid: Bool {
        selectedCertificate?.isInvalid ?? false
    }

    private var selectedTokenIsGermanIssuer: Bool {
        selectedToken?.isGermanIssuer ?? false
    }

    private var selectedTokenIsExpired: Bool {
        selectedToken?.isExpired ?? false
    }

    var fullImmunization: Bool {
        certificates.map { $0.vaccinationCertificate.hcert.dgc.v?.first?.fullImmunization ?? false }.first(where: { $0 }) ?? false
    }

    var immunizationButton: String {
        if selectedCertificatetIsInvalid || selectedCertificateIsRevoked {
            return "certificates_overview_expired_action_button_title".localized
        }
        return "recovery_certificate_overview_action_button_title".localized
    }

    var favoriteIcon: UIImage? {
        if !showFavorite { return nil }
        return isFavorite ? .starFull : .starPartial
    }

    var name: String {
        selectedDgc?.nam.fullName ?? ""
    }

    var nameReversed: String {
        selectedDgc?.nam.fullNameReverse ?? ""
    }

    var nameTransliterated: String {
        selectedDgc?.nam.fullNameTransliteratedReverse ?? ""
    }

    var birthDate: String {
        guard let dgc = selectedDgc else { return "" }
        return DateUtils.displayIsoDateOfBirth(dgc)
    }

    var immunizationIcon: UIImage? {
        if selectedTokenIsExpired || selectedCertificatetIsInvalid || selectedCertificateIsRevoked
        {
            return UIImage.statusExpiredCircle
        }
        if selectedToken?.expiresSoon ?? false {
            return UIImage.activity
        }
        if selectedDgc?.r != nil {
            return UIImage.detailStatusFull
        }
        if selectedDgc?.t != nil {
            return UIImage.detailStatusFull
        }
        return fullImmunization ? UIImage.detailStatusFull : UIImage.detailStatusPartial
    }

    var immunizationTitle: String {
        if selectedCertificatetIsInvalid || selectedCertificateIsRevoked {
            return "certificate_invalid_detail_view_note_title".localized
        }
        if selectedTokenIsExpired {
            return "certificate_expired_detail_view_note_title".localized
        }
        if selectedToken?.expiresSoon ?? false {
            guard let expireDate = selectedToken?.exp else {
                return "certificates_overview_expires_soon_certificate_note".localized
            }
            return String(format: "certificates_overview_soon_expiring_title".localized,
                          DateUtils.displayDateFormatter.string(from: expireDate),
                          DateUtils.displayTimeFormatter.string(from: expireDate))
        }
        if let r = selectedDgc?.r?.first {
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
        if isBoosterVaccination && !isJohnsonAndJohnson2of2Vaccination {
            return "certificate_type_booster".localized
        } else if cert.fullImmunizationValid {
            return "vaccination_certificate_overview_complete_title".localized
        } else if fullImmunization {
            return "vaccination_certificate_overview_complete_from_title".localized
        }

        return String(format: "vaccination_certificate_overview_incomplete_title".localized, 1, 2)
    }

    var immunizationBody: String {
        if selectedTokenIsGermanIssuer && selectedCertificateIsRevoked  {
            return "revocation_detail_single_DE".localized
        }
        if !selectedTokenIsGermanIssuer && selectedCertificateIsRevoked {
            return "revocation_detail_single_notDE".localized
        }
        if selectedTokenIsGermanIssuer && selectedTokenIsExpired {
            return "certificates_overview_expired_message".localized
        }
        if (selectedTokenIsExpired && !selectedTokenIsGermanIssuer) || selectedCertificateIsNonGermanExpiringSoon {
            return "certificates_overview_expired_or_soon_expiring_nonDE".localized
        }
        if selectedCertificateIsGermanExpiringSoon {
            return "certificates_overview_soon_expiring_subtitle".localized
        }
        if selectedCertificate?.isInvalid ?? false {
            return "certificates_overview_invalid_message".localized
        }
        if let cert = selectedDgc?.v?.first(where: { $0.fullImmunization }), !cert.fullImmunizationValid {
            return "vaccination_certificate_overview_complete_from_message".localized
        }
        if selectedToken?.isRecovery ?? false {
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

    private var selectedCertificateIsGermanExpiringSoon: Bool {
        guard let token = selectedToken else {
            return false
        }
        return token.expiresSoon && token.isGermanIssuer
    }

    private var selectedCertificateIsNonGermanExpiringSoon: Bool {
        guard let token = selectedToken else {
            return false
        }
        return token.expiresSoon && !token.isGermanIssuer
    }

    var showScanHint: Bool {
        guard let selectedCertificate = selectedCertificate else {
            return true
        }
        return !selectedCertificate.isRevoked
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

    var boosterNotificationHighlightText = Constants.Keys.Reissue.newText
    
    // MARK: Reissue
    
    var showBoosterReissueNotification: Bool {
        certificates.qualifiedForReissue
    }

    var showVaccinationExpiryReissueNotification: Bool {
        certificates.areVaccinationsQualifiedForExpiryReissue
    }

    var showVaccinationExpiryReissueIsNewBadge: Bool {
        !certificates.vaccinationExpiryReissueNewBadgeAlreadySeen
    }

    private var vaccinationExpiryReissueTokens: [ExtendedCBORWebToken] {
        certificates.qualifiedCertificatesForVaccinationExpiryReissue
    }

    var showBoosterReissueIsNewBadge: Bool {
        guard let alreadyShown = boosterReissueTokens.first?.reissueProcessNewBadgeAlreadySeen else {
            return false
        }
        return !alreadyShown
    }

    private var boosterReissueTokens: [ExtendedCBORWebToken] {
        certificates.filterBoosterAfterVaccinationAfterRecoveryFromGermany
    }

    func showRecoveryExpiryReissueIsNewBadge(index: Int) -> Bool {
        guard 0 ..< recoveryExpiryReissueCandidatesCount ~= index,
              let alreadySeen = recoveryExpiryReissueTokens[index].first?.reissueProcessNewBadgeAlreadySeen  else {
            return false
        }
        return !alreadySeen
    }

    var recoveryExpiryReissueCandidatesCount: Int {
        recoveryExpiryReissueTokens.count
    }

    private var recoveryExpiryReissueTokens: [[ExtendedCBORWebToken]] {
        certificates.cleanDuplicates.qualifiedCertificatesForRecoveryExpiryReissue
    }

    var boosterReissueNotificationTitle = Constants.Keys.Reissue.boosterHeadline

    var boosterReissueNotificationBody = Constants.Keys.Reissue.boosterDescription

    var reissueNotificationHighlightText = Constants.Keys.Reissue.newText
   
    var boosterReissueButtonTitle = Constants.Keys.Reissue.boosterButtonTitle

    let expiryReissueNotificationTitle = Constants.Keys.Reissue.expiryHeadline

    let vaccinationExpiryReissueNotificationBody = Constants.Keys.Reissue.vaccinationExpiryDescription

    let vaccinationExpiryReissueButtonTitle = Constants.Keys.Reissue.vaccinationExpiryButtonTitle

    let recoveryExpiryReissueNotificationBody = Constants.Keys.Reissue.recoveryExpiryDescription

    let recoveryExpiryReissueButtonTitle = Constants.Keys.Reissue.recoveryExpiryButtonTitle

    // MARK: - Lifecyle

    init(
        router: CertificateDetailRouterProtocol,
        repository: VaccinationRepositoryProtocol,
        boosterLogic: BoosterLogicProtocol,
        certificates: [ExtendedCBORWebToken],
        resolvable: Resolver<CertificateDetailSceneResult>
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
        if selectedCertificatetIsInvalid || selectedCertificateIsRevoked {
            resolver.fulfill(.addNewCertificate)
        } else {
            showLatestCertificate()
        }
    }

    private func showLatestCertificate() {
        guard let certificate = certificates.sortLatest().first else {
            return
        }
        resolver.fulfill(.showCertificatesOnOverview(certificate))
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
                                              tokens: certificates.filterBoosterAfterVaccinationAfterRecoveryFromGermany).cauterize()
        }
    }
    
    func updateBoosterCandiate() {        
        guard var candidate = boosterCandidate, candidate.state == .new else { return }
        candidate.state = .qualified
        boosterLogic.updateBoosterCandidate(candidate)
    }
    
    func refreshCertsAndUpdateView() {
        firstly {
            self.repository.getCertificateList()
        }
        .map {
            if let selectedCertificate = self.selectedCertificate {
                self.certificates = $0.certificates.filterMatching(selectedCertificate)
            }
        }
        .done {
            self.delegate?.viewModelDidUpdate()
        }
        .cauterize()
    }
    
    func triggerBoosterReissue() {
        showReissue(
            for: certificates.filterBoosterAfterVaccinationAfterRecoveryFromGermany,
            context: .boosterRenewal
        )
    }

    private func showReissue(
        for certificates: [ExtendedCBORWebToken],
        context: ReissueContext
    ) {
        router.showReissue(for: certificates.cleanDuplicates, context: context)
            .ensure {
                self.refreshCertsAndUpdateView()
            }
            .cauterize()
    }


    func triggerVaccinationExpiryReissue() {
        showReissue(
            for: vaccinationExpiryReissueTokens,
            context: .certificateExtension
        )
    }

    func triggerRecoveryExpiryReissue(index: Int) {
        guard 0 ..< recoveryExpiryReissueCandidatesCount ~= index else {
            return
        }
        showReissue(
            for: recoveryExpiryReissueTokens[index],
            context: .certificateExtension
        )
    }

    func markExpiryReissueCandidatesAsSeen() {
        markVaccinationExpiryReissueAsSeen()
        markRecoveryExpiryReissueAsSeen()
    }

    private func markVaccinationExpiryReissueAsSeen() {
        guard var vaccination = vaccinationExpiryReissueTokens.first else {
            return
        }
        vaccination.reissueProcessNewBadgeAlreadySeen = true
        repository.replace(vaccination).cauterize()
    }

    private func markRecoveryExpiryReissueAsSeen() {
        let recoveries = recoveryExpiryReissueTokens
        for tokens in recoveries {
            guard var recovery = tokens.first else {
                continue
            }
            recovery.reissueProcessNewBadgeAlreadySeen = true
            repository.replace(recovery).cauterize()
        }
    }

    // MARK: Private methods
    
    private func removeReissueDataIfBoosterWasDeleted() {
        if certificates.filterBoosters.isEmpty {
            self.repository.setReissueProcess(initialAlreadySeen: false,
                                              newBadgeAlreadySeen: false,
                                              tokens: certificates.filterBoosterAfterVaccinationAfterRecoveryFromGermany).cauterize()
        }
    }
    
    private func certDetailDoneDidDeleteCertificate(_ cert: ExtendedCBORWebToken, _ result: CertificateDetailSceneResult) {
        certificates = certificates.filter { $0 != cert }
        if certificates.count > 0 {
            delegate?.viewModelDidUpdate()
            router.showCertificateDidDeleteDialog()
            removeReissueDataIfBoosterWasDeleted()
        } else {
            resolver.fulfill(result)
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
        .get { allPersonsCertificates in
            self.showFavorite = allPersonsCertificates.numberOfPersons > 1
        }
        .done { _ in
            self.delegate?.viewModelDidUpdate()
        }
        .catch { [weak self] error in
            self?.router.showUnexpectedErrorDialog(error)
        }
    }
}

extension CertificateDetailViewModel {
    var isBoosterVaccination: Bool {
        selectedDgc?.v?.first?.isBoosted(vaccinations: vaccinations, recoveries: recoveries) ?? false && !isInvalid
    }

    private var isInvalid: Bool {
        selectedTokenIsExpired || selectedCertificatetIsInvalid || selectedCertificateIsRevoked
    }

    private var vaccinations: [Vaccination] {
        certificates.sortLatest().vaccinations
    }

    private var recoveries: [Recovery] {
        certificates.sortLatest().recoveries
    }

    fileprivate var isJohnsonAndJohnson2of2Vaccination: Bool {
        selectedDgc?.isJohnsonAndJohnson2of2Vaccination ?? false
    }
}
