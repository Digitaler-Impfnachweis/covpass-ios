//
//  CertificateItemDetailViewModel.swift
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
    static let germanyAbbreviation = "DE"
    enum Keys {
        static let germanyAbbreviationKey = "vaccination_certificate_detail_view_data_vaccine_country_germany".localized
    }
}

class CertificateItemDetailViewModel: CertificateItemDetailViewModelProtocol {
    // MARK: - Properties

    private let router: CertificateItemDetailRouterProtocol
    private let resolver: Resolver<CertificateDetailSceneResult>?
    private let repository: VaccinationRepositoryProtocol
    private let certificate: ExtendedCBORWebToken
    private let certificates: [ExtendedCBORWebToken]
    private var dgc: DigitalGreenCertificate {
        certificate.vaccinationCertificate.hcert.dgc
    }

    private var passed28DaysBeforeExpiration: Bool {
        certificate.vaccinationCertificate.passed28DaysBeforeExpiration
    }

    private var expiredMoreThan90Days: Bool {
        certificate.vaccinationCertificate.expiredMoreThan90Days
    }

    private var expiredForLessOrEqual90Days: Bool {
        certificate.vaccinationCertificate.expiredForLessOrEqual90Days
    }

    private var willExpireInLessOrEqual28Days: Bool {
        certificate.vaccinationCertificate.willExpireInLessOrEqual28Days
    }

    private var isExpired: Bool {
        certificate.vaccinationCertificate.isExpired
    }

    private var isReissuable: Bool {
        certificates.qualifiedCertificatesForVaccinationExpiryReissue.first == certificate || !certificates.cleanDuplicates.qualifiedCertificatesForRecoveryExpiryReissue.filter { $0.first == certificate }.isEmpty
    }

    private var isSuperseded: Bool {
        guard isVaccination else {
            return false
        }
        guard !certificates.isEmpty else {
            return false
        }
        return certificates.sortLatest().firstVaccination != certificate
    }

    private var isVaccination: Bool {
        certificate.vaccinationCertificate.certType == .vaccination
    }

    private var expirationDate: Date? {
        certificate.vaccinationCertificate.exp
    }

    private var reissuableRecoveries: [[ExtendedCBORWebToken]] {
        certificates.cleanDuplicates.qualifiedCertificatesForRecoveryExpiryReissue
    }

    private var recoveryReissueIndex: Int {
        reissuableRecoveries.firstIndex(where: { $0.first?.vaccinationQRCodeData == certificate.vaccinationQRCodeData }) ?? 0
    }

    var title: String {
        if dgc.r != nil {
            return "recovery_certificate_detail_view_title".localized
        }
        if let t = dgc.t?.first {
            return t.isPCR ? "test_certificate_detail_view_pcr_test_title".localized : "test_certificate_detail_view_title".localized
        }
        return String(format: "vaccination_certificate_detail_view_vaccination_title".localized, dgc.v?.first?.dn ?? 0, dgc.v?.first?.sd ?? 0)
    }

    var headline: String {
        if dgc.r != nil {
            return "recovery_certificate_detail_view_headline".localized
        }
        if dgc.t != nil {
            return "test_certificate_detail_view_headline".localized
        }
        return "vaccination_certificate_detail_view_vaccination_headline".localized
    }

    private var dob: String { DateUtils.displayIsoDateOfBirth(dgc) }
    var items: [ListContentItem] {
        if let r = dgc.r?.first {
            return [
                ListContentItem("recovery_certificate_detail_view_data_name".localized, dgc.nam.fullNameReverse),
                ListContentItem("recovery_certificate_detail_view_data_name_standard".localized, dgc.nam.fullNameTransliteratedReverse),
                ListContentItem("recovery_certificate_detail_view_data_date_of_birth".localized, dob,
                                accessibilityLabel(for: dob, label: "recovery_certificate_detail_view_data_date_of_birth".localized)),
                ListContentItem("recovery_certificate_detail_view_data_disease".localized, r.tgDisplayName),
                ListContentItem("recovery_certificate_detail_view_data_date_first_positive_result".localized, DateUtils.isoDateFormatter.string(from: r.fr),
                                accessibilityLabel(for: r.fr, label: "recovery_certificate_detail_view_data_date_first_positive_result".localized)),
                ListContentItem("recovery_certificate_detail_view_data_country".localized, countryLocalized(r)),
                ListContentItem("recovery_certificate_detail_view_data_issuer".localized, r.is),
                ListContentItem("recovery_certificate_detail_view_data_valid_from".localized, DateUtils.isoDateFormatter.string(from: r.df),
                                accessibilityLabel(for: r.df, label: "recovery_certificate_detail_view_data_valid_from".localized)),
                ListContentItem("recovery_certificate_detail_view_data_valid_until".localized, DateUtils.isoDateFormatter.string(from: r.du),
                                accessibilityLabel(for: r.du, label: "recovery_certificate_detail_view_data_valid_until".localized)),
                ListContentItem("recovery_certificate_detail_view_data_identifier".localized, r.ciDisplayName),
                ListContentItem("recovery_certificate_detail_view_data_expiry_date".localized, String(format: "\("recovery_certificate_detail_view_data_expiry_date_message".localized)\n\("recovery_certificate_detail_view_data_expiry_date_note".localized)", certificate.vaccinationCertificate.exp != nil ? DateUtils.displayDateTimeFormatter.string(from: certificate.vaccinationCertificate.exp!) : "") /* TODO: accessibility label */ )
            ]
        }
        if let t = dgc.t?.first {
            return [
                ListContentItem("test_certificate_detail_view_data_name".localized, dgc.nam.fullNameReverse),
                ListContentItem("test_certificate_detail_view_data_name_standard".localized, dgc.nam.fullNameTransliteratedReverse),
                ListContentItem("test_certificate_detail_view_data_date_of_birth".localized, dob,
                                accessibilityLabel(for: dob, label: "test_certificate_detail_view_data_date_of_birth".localized)),
                ListContentItem("test_certificate_detail_view_data_disease".localized, t.tgDisplayName),
                ListContentItem("test_certificate_detail_view_data_test_type".localized, t.ttDisplayName),
                ListContentItem("test_certificate_detail_view_data_test_name".localized, t.nm ?? ""),
                ListContentItem("test_certificate_detail_view_data_test_manufactur".localized, t.maDisplayName ?? ""),
                ListContentItem("test_certificate_detail_view_data_test_date_and_time".localized, DateUtils.displayIsoDateTimeFormatter.string(from: t.sc),
                                accessibilityLabel(for: t.sc, label: "test_certificate_detail_view_data_test_date_and_time".localized, includesTime: true)),
                ListContentItem("test_certificate_detail_view_data_test_results".localized, t.trDisplayName),
                ListContentItem("test_certificate_detail_view_data_test_centre".localized, t.tc ?? ""),
                ListContentItem("test_certificate_detail_view_data_test_country".localized, countryLocalized(t)),
                ListContentItem("test_certificate_detail_view_data_test_issuer".localized, t.is),
                ListContentItem("test_certificate_detail_view_data_test_identifier".localized, t.ciDisplayName),
                ListContentItem("test_certificate_detail_view_data_expiry_date".localized,
                                String(format: "\("test_certificate_detail_view_data_expiry_date_message".localized)\n\("test_certificate_detail_view_data_expiry_date_note".localized)", certificate.vaccinationCertificate.exp != nil ? DateUtils.displayDateTimeFormatter.string(from: certificate.vaccinationCertificate.exp!) : "") /* TODO: accessibility label */ )
            ]
        }
        if let v = dgc.v?.first {
            return [
                ListContentItem("vaccination_certificate_detail_view_data_name".localized, dgc.nam.fullNameReverse),
                ListContentItem("vaccination_certificate_detail_view_data_name_standard".localized, dgc.nam.fullNameTransliteratedReverse),
                ListContentItem("vaccination_certificate_detail_view_data_date_of_birth".localized, dob,
                                accessibilityLabel(for: dob, label: "vaccination_certificate_detail_view_data_date_of_birth".localized)),
                ListContentItem("vaccination_certificate_detail_view_data_disease".localized, v.tgDisplayName),
                ListContentItem("vaccination_certificate_detail_view_data_vaccine".localized, v.map(key: v.mp, from: Bundle.commonBundle.url(forResource: "vaccines-covid-19-names", withExtension: "json")) ?? v.mp),
                ListContentItem("vaccination_certificate_detail_view_data_vaccine_type".localized, v.vpDisplayName),
                ListContentItem("vaccination_certificate_detail_view_data_vaccine_manufactur".localized, v.maDisplayName),
                ListContentItem("vaccination_certificate_detail_view_data_vaccine_number".localized, "\(v.dn) / \(v.sd)"),
                ListContentItem("vaccination_certificate_detail_view_data_vaccine_date_".localized, DateUtils.isoDateFormatter.string(from: v.dt),
                                accessibilityLabel(for: v.dt, label: "vaccination_certificate_detail_view_data_vaccine_date_".localized)),
                ListContentItem("vaccination_certificate_detail_view_data_vaccine_country".localized, countryLocalized(v)),
                ListContentItem("vaccination_certificate_detail_view_data_vaccine_issuer".localized, v.is),
                ListContentItem("vaccination_certificate_detail_view_data_vaccine_identifier".localized, v.ciDisplayName),
                ListContentItem("vaccination_certificate_detail_view_data_expiry_date".localized,
                                String(format: "\("vaccination_certificate_detail_view_data_expiry_date_message".localized)\n\("vaccination_certificate_detail_view_data_expiry_date_note".localized)", certificate.vaccinationCertificate.exp != nil ? DateUtils.displayDateTimeFormatter.string(from: certificate.vaccinationCertificate.exp!) : "" /* TODO: accessibility label */ ))
            ]
        }
        return []
    }

    var canExportToPDF: Bool { certificate.canExportToPDF }
    var vaasResultToken: VAASValidaitonResultToken?
    var hasValidationResult: Bool { vaasResultToken != nil }
    var isInvalid: Bool { certificate.isInvalid }
    var isRevoked: Bool { certificate.isRevoked }
    let isGerman: Bool
    lazy var hideQRCodeButtons = (isInvalid && !certificate.vaccinationCertificate.isExpired) || isRevoked
    lazy var revocationText = (
        certificate.vaccinationCertificate.isGermanIssuer ?
            "revocation_detail_single_DE" :
            "revocation_detail_single_notDE"
    ).localized

    var expirationHintButtonIsHidden: Bool? {
        guard !expirationHintIsHidden else { return nil }
        return !isReissuable
    }

    var expirationHintIsHidden: Bool {
        guard !certificate.vaccinationCertificate.isTest else { return true }
        return !certificate.vaccinationCertificate.passed28DaysBeforeExpiration && !isRevoked && !isInvalid
    }

    var expirationHintIcon: UIImage? {
        guard !expirationHintIsHidden else { return nil }
        if !isReissuable {
            if certificate.vaccinationCertificate.isExpired, isSuperseded {
                return .warning
            } else if isRevoked {
                return .warning
            } else if isInvalid {
                return .warning
            } else if isExpired {
                return .error
            } else {
                return .activity
            }
        }
        return .error
    }

    var expirationHintBackgroundColor: UIColor? {
        guard !expirationHintIsHidden else { return nil }
        if isSuperseded, certificate.vaccinationCertificate.isExpired {
            return .hintBackground
        } else if isRevoked {
            return .hintBackground
        } else if isInvalid {
            return .hintBackground
        }
        return .brandAccent20
    }

    var expirationHintBorderColor: UIColor? {
        guard !expirationHintIsHidden else { return nil }
        if isSuperseded, certificate.vaccinationCertificate.isExpired {
            return .hintBorder
        } else if isRevoked {
            return .hintBorder
        } else if isInvalid {
            return .hintBorder
        }
        return .brandAccent40
    }

    var expirationHintTitle: String? {
        if isRevoked || isInvalid {
            return "certificate_invalid_detail_view_note_title".localized.replaceIfAvailable(expirationDate: expirationDate)
        } else if isSuperseded {
            if isExpired {
                if isVaccination {
                    return "renewal_bluebox_title_expired_vaccination".localized.replaceIfAvailable(expirationDate: expirationDate)
                } else {
                    return "renewal_bluebox_title_expired_recovery".localized.replaceIfAvailable(expirationDate: expirationDate)
                }
            } else {
                return "certificate_expires_detail_view_note_title".localized.replaceIfAvailable(expirationDate: expirationDate)
            }
        } else if isExpired {
            if isVaccination {
                return "renewal_bluebox_title_expired_vaccination".localized.replaceIfAvailable(expirationDate: expirationDate)
            } else {
                return "renewal_bluebox_title_expired_recovery".localized.replaceIfAvailable(expirationDate: expirationDate)
            }
        } else if certificate.vaccinationCertificate.expiresSoon {
            if isVaccination {
                return "renewal_bluebox_title_expiring_soon_vaccination".localized.replaceIfAvailable(expirationDate: expirationDate)
            } else {
                return "renewal_bluebox_title_expiring_soon_recovery".localized.replaceIfAvailable(expirationDate: expirationDate)
            }
        }
        return nil
    }

    var expirationHintButtonTitle: String? {
        guard !expirationHintIsHidden, isGerman else { return nil }
        if certificate.vaccinationCertificate.isVaccination {
            return "renewal_expiry_notification_button_vaccination".localized
        } else if certificate.vaccinationCertificate.isRecovery {
            return "renewal_expiry_notification_button_recovery".localized
        }
        return nil
    }

    var expirationHintBodyText: String? {
        if !isGerman, isRevoked {
            return "revocation_detail_single_notDE".localized.replaceIfAvailable(expirationDate: expirationDate)
        } else if isRevoked {
            return "revocation_detail_single_DE".localized.replaceIfAvailable(expirationDate: expirationDate)
        } else if isInvalid {
            return "revocation_detail_locationID".localized.replaceIfAvailable(expirationDate: expirationDate)
        } else if isReissuable {
            if isExpired {
                return "renewal_bluebox_copy_expired".localized.replaceIfAvailable(expirationDate: expirationDate)
            } else {
                return "renewal_bluebox_copy_expiring_soon".localized.replaceIfAvailable(expirationDate: expirationDate)
            }
        } else if isSuperseded {
            if isExpired {
                return "certificate_expired_detail_view_note_message".localized.replaceIfAvailable(expirationDate: expirationDate)
            } else {
                return "certificate_expires_detail_view_note_message".localized.replaceIfAvailable(expirationDate: expirationDate)
            }
        } else if !isReissuable {
            if isGerman, isExpired {
                return "renewal_bluebox_copy_expiry_not_available".localized.replaceIfAvailable(expirationDate: expirationDate)
            } else if !isGerman, isExpired {
                return "renewal_bluebox_copy_expiry_not_german".localized.replaceIfAvailable(expirationDate: expirationDate)
            } else if isGerman, certificate.vaccinationCertificate.expiresSoon {
                return "renewal_bluebox_copy_expiring_soon_not_available".localized.replaceIfAvailable(expirationDate: expirationDate)
            } else if !isGerman, certificate.vaccinationCertificate.expiresSoon {
                return "renewal_bluebox_copy_expiring_soon_not_german".localized.replaceIfAvailable(expirationDate: expirationDate)
            }
        }

        return nil
    }

    // MARK: - Lifecyle

    init(
        router: CertificateItemDetailRouterProtocol,
        repository: VaccinationRepositoryProtocol,
        certificate: ExtendedCBORWebToken,
        certificates: [ExtendedCBORWebToken],
        resolvable: Resolver<CertificateDetailSceneResult>?,
        vaasResultToken: VAASValidaitonResultToken?
    ) {
        self.router = router
        self.repository = repository
        self.certificate = certificate
        self.certificates = certificates
        resolver = resolvable
        self.vaasResultToken = vaasResultToken
        isGerman = certificate.vaccinationCertificate.isGermanIssuer
    }

    // MARK: - Methods

    func deleteCertificate() {
        firstly {
            showDeleteDialog()
        }
        .then {
            self.repository.delete(self.certificate)
        }
        .done {
            self.resolver?.fulfill(.didDeleteCertificate)
        }
        .catch { error in
            self.router.showUnexpectedErrorDialog(error)
        }
    }

    func showQRCode() {
        router.showCertificate(for: certificate).cauterize()
    }

    func startPDFExport() {
        router.showPDFExport(for: certificate).cauterize()
    }

    func triggerVaccinationExpiryReissue() {
        if isVaccination {
            showReissue(
                for: certificates.qualifiedCertificatesForVaccinationExpiryReissue,
                context: .certificateExtension
            )
        } else {
            triggerRecoveryExpiryReissue(index: recoveryReissueIndex)
        }
    }

    func triggerRecoveryExpiryReissue(index: Int) {
        guard reissuableRecoveries.indices.contains(index) else {
            return
        }
        showReissue(
            for: reissuableRecoveries[index],
            context: .certificateExtension
        )
    }

    private func showReissue(for certificates: [ExtendedCBORWebToken],
                             context: ReissueContext) {
        router.showReissue(for: certificates.cleanDuplicates, context: context)
            .ensure {
                self.resolver?.fulfill(.didReissuedCertificate)
            }
            .cauterize()
    }

    private func showDeleteDialog() -> Promise<Void> {
        .init { seal in
            let delete = DialogAction(title: "dialog_delete_certificate_button_delete".localized, style: .destructive) { _ in
                seal.fulfill_()
            }
            let cancel = DialogAction(title: "dialog_delete_certificate_button_cancel".localized, style: .cancel) { _ in
                seal.cancel()
            }
            self.router.showDialog(
                title: "dialog_delete_certificate_title".localized,
                message: "dialog_delete_certificate_message".localized,
                actions: [delete, cancel],
                style: .alert
            )
        }
    }

    private func countryLocalized(_ v: Vaccination) -> String {
        countryLocalized(v.co)
    }

    private func countryLocalized(_ r: Recovery) -> String {
        countryLocalized(r.co)
    }

    private func countryLocalized(_ t: Test) -> String {
        countryLocalized(t.co)
    }

    private func countryLocalized(_ co: String) -> String {
        if co == Constants.germanyAbbreviation {
            return Constants.Keys.germanyAbbreviationKey
        }
        return co.localized
    }

    // MARK: - Accessibility

    private func accessibilityLabel(for dateString: String, label: String) -> String {
        let dateStr = DateUtils.audioDate(dateString) ?? dateString
        return "\(label)\n\(dateStr)"
    }

    private func accessibilityLabel(for date: Date, label: String, includesTime: Bool = false) -> String {
        let formatter = includesTime ? DateUtils.displayDateTimeFormatter : DateUtils.audioDateFormatter
        let dateStr = formatter.string(from: date)
        return "\(label)\n\(dateStr)"
    }
}

extension String {
    func replaceIfAvailable(expirationDate: Date?) -> String {
        if let expirationDate = expirationDate {
            return String(format: self,
                          DateUtils.displayDateFormatter.string(from: expirationDate),
                          DateUtils.displayTimeFormatter.string(from: expirationDate))
        }
        return self
    }
}
