//
//  CertificateDetailViewModel+Reissue.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import Foundation

private enum Constants {
    enum Keys {
        enum Reissue {
            static let boosterHeadline = "certificate_renewal_startpage_headline".localized
            static let boosterDescription = "certificate_renewal_startpage_copy".localized
            static let newText = "vaccination_certificate_overview_booster_vaccination_notification_icon_new".localized
            static let boosterButtonTitle = "certificate_renewal_detail_view_notification_box_secondary_button".localized
            static let vaccinationExpiryButtonTitle = "renewal_expiry_notification_button_vaccination".localized
            static let recoveryExpiryButtonTitle = "renewal_expiry_notification_button_recovery".localized
            enum AboutToExpire {
                static let titleVaccination = "renewal_bluebox_title_expiring_soon_vaccination".localized
                static let titleRecovery = "renewal_bluebox_title_expiring_soon_recovery".localized
                static let copy = "renewal_bluebox_copy_expiring_soon".localized
                static let copyNotAvailable = "renewal_bluebox_copy_expiring_soon_not_available".localized
                static let copyNotGerman = "renewal_bluebox_copy_expiring_soon_not_german".localized
            }

            enum Expired {
                static let titleVaccination = "renewal_bluebox_title_expired_vaccination".localized
                static let titleRecovery = "renewal_bluebox_title_expired_recovery".localized
                static let copy = "renewal_bluebox_copy_expired".localized
                static let copyNotAvailable = "renewal_bluebox_copy_expiry_not_available".localized
                static let copyNotGerman = "renewal_bluebox_copy_expiry_not_german".localized
            }
        }
    }
}

extension CertificateDetailViewModel {
    // MARK: Reissue

    var boosterNotificationHighlightText: String { Constants.Keys.Reissue.newText }
    var boosterReissueNotificationTitle: String { Constants.Keys.Reissue.boosterHeadline }
    var boosterReissueNotificationBody: String { Constants.Keys.Reissue.boosterDescription }
    var boosterReissueButtonTitle: String { Constants.Keys.Reissue.boosterButtonTitle }
    var vaccinationExpiryReissueButtonTitle: String { Constants.Keys.Reissue.vaccinationExpiryButtonTitle }
    var recoveryExpiryReissueButtonTitle: String { Constants.Keys.Reissue.recoveryExpiryButtonTitle }
    var showBoosterReissueNotification: Bool { certificates.qualifiedForBoosterRenewal }
    var boosterReissueTokens: [ExtendedCBORWebToken] { certificates.filterBoosterAfterVaccinationAfterRecoveryFromGermany }
    var expiryVaccination: ExtendedCBORWebToken? { certificates.sortLatest().firstVaccination }

    var showVaccinationExpiryReissueNotification: Bool {
        expiryVaccination?.vaccinationCertificate.passed28DaysBeforeExpiration ?? false && expiryVaccination?.isNotRevoked ?? true
    }

    var showVaccinationExpiryReissueButtonInNotification: Bool {
        certificates.areVaccinationsQualifiedForExpiryReissue
    }

    private var vaccinationExpiryReissueTokens: [ExtendedCBORWebToken] {
        certificates.qualifiedCertificatesForVaccinationExpiryReissue
    }

    private var recoveriesPassed28Days: [ExtendedCBORWebToken] {
        certificates.cleanDuplicates.filterRecoveries.filter(\.vaccinationCertificate.passed28DaysBeforeExpiration)
    }

    var recoveryExpiryReissueCandidatesCount: Int {
        recoveriesPassed28Days.count
    }

    private var recoveriesQualifiedForReissue: [[ExtendedCBORWebToken]] {
        certificates.cleanDuplicates.qualifiedCertificatesForRecoveryExpiryReissue
    }

    var reissueVaccinationTitle: String {
        if expiryVaccination?.vaccinationCertificate.isExpired ?? false {
            return Constants.Keys.Reissue.Expired.titleVaccination
        }
        return Constants.Keys.Reissue.AboutToExpire.titleVaccination
    }

    var vaccinationExpiryReissueNotificationBody: String {
        var copyText = ""
        if let reissueableVaccination = expiryVaccination {
            if reissueableVaccination.vaccinationCertificate.isExpired {
                if !reissueableVaccination.vaccinationCertificate.isGermanIssuer {
                    copyText = Constants.Keys.Reissue.Expired.copyNotGerman
                } else if !certificates.areVaccinationsQualifiedForExpiryReissue {
                    copyText = Constants.Keys.Reissue.Expired.copyNotAvailable
                } else {
                    copyText = Constants.Keys.Reissue.Expired.copy
                }
            } else {
                if !reissueableVaccination.vaccinationCertificate.isGermanIssuer {
                    copyText = Constants.Keys.Reissue.AboutToExpire.copyNotGerman
                } else if !certificates.areVaccinationsQualifiedForExpiryReissue {
                    copyText = Constants.Keys.Reissue.AboutToExpire.copyNotAvailable
                } else {
                    copyText = Constants.Keys.Reissue.AboutToExpire.copy
                }
            }
            guard let expireDate = reissueableVaccination.vaccinationCertificate.exp else {
                return copyText
            }
            copyText = String(format: copyText,
                              DateUtils.displayDateFormatter.string(from: expireDate),
                              DateUtils.displayTimeFormatter.string(from: expireDate))
        }
        return copyText
    }

    func reissueRecoveryTitle(index: Int) -> String {
        guard index < recoveriesPassed28Days.count else {
            return ""
        }
        let expiryRecovery = recoveriesPassed28Days[index]
        if expiryRecovery.vaccinationCertificate.isExpired {
            return Constants.Keys.Reissue.Expired.titleRecovery
        }
        return Constants.Keys.Reissue.AboutToExpire.titleRecovery
    }

    func recoveryExpiryReissueNotificationBody(index: Int) -> String {
        var copyText = ""
        if recoveriesPassed28Days.indices.contains(index) {
            let expiryRecovery = recoveriesPassed28Days[index]
            let token = expiryRecovery.vaccinationCertificate
            if token.willExpireInLessOrEqual28Days {
                if !token.isGermanIssuer {
                    copyText = Constants.Keys.Reissue.AboutToExpire.copyNotGerman
                } else if !certificates.areRecoveriesQualifiedForExpiryReissue {
                    copyText = Constants.Keys.Reissue.AboutToExpire.copyNotAvailable
                } else {
                    copyText = Constants.Keys.Reissue.AboutToExpire.copy
                }
            } else {
                if !token.isGermanIssuer {
                    copyText = Constants.Keys.Reissue.Expired.copyNotGerman
                } else if !certificates.areVaccinationsQualifiedForExpiryReissue {
                    copyText = Constants.Keys.Reissue.Expired.copyNotAvailable
                } else {
                    copyText = Constants.Keys.Reissue.Expired.copy
                }
            }
            guard let expireDate = token.exp else {
                return copyText
            }
            copyText = String(format: copyText,
                              DateUtils.displayDateFormatter.string(from: expireDate),
                              DateUtils.displayTimeFormatter.string(from: expireDate))
        }
        return copyText
    }

    func showRecoveryExpiryReissueButtonInNotification(index: Int) -> Bool {
        guard recoveriesPassed28Days.indices.contains(index) else {
            return false
        }
        let recoveryTapped = recoveriesPassed28Days[index]
        guard recoveriesQualifiedForReissue.contains(where: { $0.first == recoveryTapped }) else {
            return false
        }
        return true
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
            for: recoveriesQualifiedForReissue[index],
            context: .certificateExtension
        )
    }

    func updateReissueCandidate(to value: Bool) {
        if certificates.qualifiedForBoosterRenewal {
            repository.setReissueProcess(initialAlreadySeen: value,
                                         newBadgeAlreadySeen: value,
                                         tokens: certificates.filterBoosterAfterVaccinationAfterRecoveryFromGermany).cauterize()
        }
    }

    func removeReissueDataIfBoosterWasDeleted() {
        if certificates.filterBoosters.isEmpty {
            repository.setReissueProcess(initialAlreadySeen: false,
                                         newBadgeAlreadySeen: false,
                                         tokens: certificates.filterBoosterAfterVaccinationAfterRecoveryFromGermany).cauterize()
        }
    }
}
