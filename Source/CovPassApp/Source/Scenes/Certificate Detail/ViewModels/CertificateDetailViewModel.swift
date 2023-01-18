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
        enum PersonalData {
            static let title = "certificates_overview_personal_data_title".localized
            static let name = "certificates_overview_personal_data_name".localized
            static let nameStandard = "vaccination_certificate_detail_view_data_name_standard".localized
            static let dateOfBirth = "certificates_overview_personal_data_date_of_birth".localized
            static let certificatesTitle = "certificates_overview_all_certificates_title".localized
            static let header = "infschg_cert_overview_title".localized
        }
    }

    enum Accessibility {
        enum PersonalData {
            static let name = "accessibility_certificates_overview_personal_data_name".localized
            static let nameStandard = "accessibility_vaccination_certificate_detail_view_data_name_standard".localized
            static let dateOfBirth = "accessibility_certificates_overview_personal_data_date_of_birth".localized
            static let certificatesTitle = "accessibility_certificates_overview_all_certificates_title".localized
        }

        enum General {
            static let backToStart = "accessibility_overview_certificates_label_back".localized
        }
    }
}

class CertificateDetailViewModel: CertificateDetailViewModelProtocol {
    // MARK: - Properties

    weak var delegate: ViewModelDelegate?
    var router: CertificateDetailRouterProtocol
    let repository: VaccinationRepositoryProtocol
    var certificates: [ExtendedCBORWebToken]
    private let boosterLogic: BoosterLogicProtocol
    private let boosterCandidate: BoosterCandidate?
    private let resolver: Resolver<CertificateDetailSceneResult>
    private let certificateHolderStatusModel: CertificateHolderStatusModelProtocol
    private let certificateHolderName: Name
    private let certificateHolderDateOfBirth: Date?
    private var isFavorite = false
    private var showFavorite = false
    private var holderNeedsMask = true
    private var vaccinationCycleCompleteResponse: HolderStatusResponse
    private var vaccinationCycleIsComplete: Bool { vaccinationCycleCompleteResponse.passed }
    private var selectedCertificate: ExtendedCBORWebToken? { certificates.sortLatest().first }
    private var selectedToken: CBORWebToken? { selectedCertificate?.vaccinationCertificate }
    private var selectedDgc: DigitalGreenCertificate? { selectedToken?.hcert.dgc }
    private var selectedCertificateIsRevoked: Bool { selectedCertificate?.isRevoked ?? false }
    private var selectedCertificatetIsInvalid: Bool { selectedCertificate?.isInvalid ?? false }
    private var selectedCertificatetIsRecovery: Bool { selectedCertificate?.vaccinationCertificate.isRecovery ?? false }
    private var selectedTokenIsGermanIssuer: Bool { selectedToken?.isGermanIssuer ?? false }
    private var selectedTokenIsExpired: Bool { selectedToken?.isExpired ?? false }
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

    private var userDefaults: Persistence
    var accessibilityBackToStart = Constants.Accessibility.General.backToStart
    var name: String { selectedDgc?.nam.fullName ?? "" }
    var nameReversed: String { selectedDgc?.nam.fullNameReverse ?? "" }
    var nameTransliterated: String { selectedDgc?.nam.fullNameTransliteratedReverse ?? "" }
    var title = Constants.Keys.PersonalData.title
    var nameTitle = Constants.Keys.PersonalData.name
    var nameTitleStandard = Constants.Keys.PersonalData.nameStandard
    var dateOfBirth = Constants.Keys.PersonalData.dateOfBirth
    var certificatesTitle = Constants.Keys.PersonalData.certificatesTitle
    var accessibilityName = Constants.Accessibility.PersonalData.name
    var accessibilityNameStandard = Constants.Accessibility.PersonalData.nameStandard
    var accessibilityDateOfBirth = Constants.Accessibility.PersonalData.dateOfBirth
    var accessibilityCertificatesTitle = Constants.Accessibility.PersonalData.certificatesTitle
    let immunizationHeader = Constants.Keys.PersonalData.header
    var fullImmunization: Bool { certificates.map { $0.firstVaccination?.fullImmunization ?? false }.first(where: { $0 }) ?? false }
    var birthDate: String {
        guard let dgc = selectedDgc else { return "" }
        return DateUtils.displayIsoDateOfBirth(dgc)
    }

    var immunizationButton: String {
        if selectedCertificatetIsInvalid || selectedCertificateIsRevoked || selectedTokenIsExpired {
            return "certificates_overview_expired_action_button_title".localized
        }
        return "recovery_certificate_overview_action_button_title".localized
    }

    var favoriteIcon: UIImage? {
        if !showFavorite { return nil }
        return isFavorite ? .starFull : .starPartial
    }

    var immunizationIcon: UIImage? {
        if isInvalid {
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
        if selectedCertificatetIsInvalid || selectedCertificateIsRevoked {
            return "certificate_invalid_detail_view_note_title".localized
        }
        if selectedCertificatetIsRecovery {
            return "recovery_certificate_overview_valid_until_title".localized
        }
        if let t = selectedCertificate?.firstTest {
            if t.isPCR {
                return String(format: "pcr_test_certificate_overview_title".localized, t.sc.readableString)
            }
            return String(format: "test_certificate_overview_title".localized, t.sc.readableString)
        }

        if let vaccination = selectedCertificate?.firstVaccination {
            return .init(
                format: "certificates_overview_vaccination_certificate_message".localized,
                vaccination.dn,
                vaccination.sd
            )
        }

        return String(format: "vaccination_certificate_overview_incomplete_title".localized, 1, 2)
    }

    var immunizationBody: String {
        if selectedTokenIsGermanIssuer && selectedCertificateIsRevoked {
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

    var maskStatusViewModel: CertificateHolderImmunizationStatusViewModelProtocol {
        guard certificateHolderStatusModel.maskRulesAvailable(for: userDefaults.stateSelection) else {
            return CertificateHolderNoMaskRulesStatusViewModel(federalState: userDefaults.stateSelection)
        }
        guard !isInvalid else {
            return CertificateHolderInvalidMaskStatusViewModel()
        }
        if holderNeedsMask {
            if let vaccination = certificates.latestVaccination, let recovery = certificates.latestRecovery,
               recovery.fr > vaccination.dt, !recovery.fr.isOlderThan29Days,
               let fr = recovery.fr.add(days: 29) {
                return CertificateHolderMaskRequiredStatusViewModel(
                    userDefaults: userDefaults,
                    certificateHolderStatus: certificateHolderStatusModel,
                    date: fr.readableString,
                    federalState: userDefaults.stateSelection
                )
            }
            return CertificateHolderMaskRequiredStatusViewModel(
                userDefaults: userDefaults,
                certificateHolderStatus: certificateHolderStatusModel,
                federalState: userDefaults.stateSelection
            )
        } else {
            let certificatesUsed = certificateHolderStatusModel.validCertificates(certificates, logicType: .deAcceptenceAndInvalidationRules)
            let latestCertificate = certificatesUsed.sortedByDtFrAndSc.first
            let isTest = latestCertificate?.vaccinationCertificate.isTest ?? false
            let dtOrFr = latestCertificate?.dtFrOrSc.add(days: isTest ? 1 : 90)
            return CertificateHolderMaskNotRequiredStatusViewModel(
                userDefaults: userDefaults,
                certificateHolderStatus: certificateHolderStatusModel,
                date: dtOrFr?.readableString,
                federalState: userDefaults.stateSelection
            )
        }
    }

    var vaccinationCycleCompleteDescription: String {
        if let localizedDescription = vaccinationCycleCompleteResponse.results?.values.first?.first?.rule?.localizedDescription(for: Locale.current.languageCode) {
            return localizedDescription
        }
        return vaccinationCycleCompleteResponse.results?.values.first?.first?.rule?.description.first?.desc ?? ""
    }

    var immunizationStatusViewModel: CertificateHolderImmunizationStatusViewModelProtocol {
        if isInvalid {
            return CertificateHolderInvalidImmunizationStatusViewModel()
        } else if vaccinationCycleIsComplete {
            guard let ruleType = vaccinationCycleCompleteResponse.results?.first?.key else {
                return CertificateHolderIncompleteImmunizationStatusViewModel()
            }
            switch ruleType {
            case .impfstatusBZwei, .impfstatusCZwei, .impfstatusEZwei:
                return CertificateHolderCompleteVaccinationCycleStatusViewModel(description: vaccinationCycleCompleteDescription)
            case .impfstatusEEins:
                return CertificateHolderImmunizationE1StatusViewModel(description: vaccinationCycleCompleteDescription, date: certificates.latestRecovery?.fr.readableStringAfter29Days)
            default:
                break
            }
        }
        return CertificateHolderIncompleteImmunizationStatusViewModel()
    }

    var immunizationStatusViewIsHidden: Bool {
        expiryVaccination?.vaccinationCertificate.isExpired ?? false
    }

    // MARK: - Booster Notifications

    var showBoosterNotification: Bool {
        boosterCandidate?.state != BoosterCandidate.BoosterState.none
    }

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

    var immunizationDetailsHidden: Bool {
        !(selectedCertificatetIsInvalid || selectedCertificateIsRevoked)
    }

    // MARK: - Lifecyle

    init?(
        router: CertificateDetailRouterProtocol,
        repository: VaccinationRepositoryProtocol,
        boosterLogic: BoosterLogicProtocol,
        certificates: [ExtendedCBORWebToken],
        resolvable: Resolver<CertificateDetailSceneResult>,
        certificateHolderStatusModel: CertificateHolderStatusModelProtocol,
        userDefaults: Persistence
    ) {
        self.certificateHolderStatusModel = certificateHolderStatusModel
        self.router = router
        self.repository = repository
        self.boosterLogic = boosterLogic
        self.userDefaults = userDefaults
        self.certificates = certificates
        boosterCandidate = boosterLogic.checkCertificates(certificates)
        resolver = resolvable
        holderNeedsMask = certificateHolderStatusModel.holderNeedsMask(self.certificates, region: userDefaults.stateSelection)
        vaccinationCycleCompleteResponse = certificateHolderStatusModel.vaccinationCycleIsComplete(certificates)
        guard let digitalGreenCertificate = certificates.first?.vaccinationCertificate.hcert.dgc else {
            return nil
        }
        certificateHolderName = digitalGreenCertificate.nam
        certificateHolderDateOfBirth = digitalGreenCertificate.dob
    }

    // MARK: - Methods

    func refresh() {
        refreshFavoriteState()
    }

    func immunizationButtonTapped() {
        if selectedCertificatetIsInvalid || selectedCertificateIsRevoked || selectedTokenIsExpired {
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
                self.holderNeedsMask = self.certificateHolderStatusModel.holderNeedsMask(self.certificates, region: self.userDefaults.stateSelection)
                self.vaccinationCycleCompleteResponse = self.certificateHolderStatusModel.vaccinationCycleIsComplete(self.certificates)
            }
        }
        .done {
            self.delegate?.viewModelDidUpdate()
        }
        .cauterize()
    }

    func showStateSelection() {
        router.showStateSelection().done { [weak self] in
            self?.refreshCertsAndUpdateView()
        }.cauterize()
    }

    // MARK: Private methods

    private func certDetailDoneDidDeleteCertificate(_ cert: ExtendedCBORWebToken, _ result: CertificateDetailSceneResult) {
        certificates = certificates.filter { $0 != cert }
        holderNeedsMask = certificateHolderStatusModel.holderNeedsMask(certificates, region: userDefaults.stateSelection)
        vaccinationCycleCompleteResponse = certificateHolderStatusModel.vaccinationCycleIsComplete(certificates)
        if certificates.count > 0 {
            delegate?.viewModelDidUpdate()
            router.showCertificateDidDeleteDialog()
            removeReissueDataIfBoosterWasDeleted()
        } else {
            resolver.fulfill(result)
        }
    }

    private func certetailDone(_ result: CertificateDetailSceneResult, cert: ExtendedCBORWebToken) {
        switch result {
        case .didReissuedCertificate:
            refreshCertsAndUpdateView()
        case .didDeleteCertificate:
            certDetailDoneDidDeleteCertificate(cert, result)
        default: break
        }
    }

    private func certItem(_ vm: CertificateItemViewModel?,
                          _ cert: ReversedCollection<[ExtendedCBORWebToken]>.Element) -> CertificateItem? {
        CertificateItem(viewModel: vm!) {
            self.router.showDetail(for: cert, certificates: self.certificates)
                .done { [weak self] in
                    self?.certetailDone($0, cert: cert)
                }
                .cauterize()
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

private extension CertificateDetailViewModel {
    var isBoosterVaccination: Bool {
        selectedDgc?.v?.first?.isBoosted(vaccinations: vaccinations, recoveries: recoveries) ?? false && !isInvalid
    }

    var isInvalid: Bool {
        selectedTokenIsExpired || selectedCertificatetIsInvalid || selectedCertificateIsRevoked
    }

    private var vaccinations: [Vaccination] {
        certificates.sortLatest().vaccinations
    }

    private var recoveries: [Recovery] {
        certificates.sortLatest().recoveries
    }

    private var isJohnsonAndJohnson2of2Vaccination: Bool {
        selectedDgc?.isJohnsonAndJohnson2of2Vaccination ?? false
    }
}

private extension Date {
    var readableString: String {
        DateUtils.displayDateFormatter.string(from: self)
    }

    var readableStringAfter29Days: String {
        guard let dateAfter29Days = add(days: 29) else {
            return ""
        }
        return dateAfter29Days.readableString
    }
}
