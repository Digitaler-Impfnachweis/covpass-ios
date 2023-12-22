//
//  RecoveryCertificateItemViewModel.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import Foundation
import UIKit

struct RecoveryCertificateItemViewModel: CertificateItemViewModel {
    private let certificate: ExtendedCBORWebToken
    private var dgc: DigitalGreenCertificate {
        certificate.vaccinationCertificate.hcert.dgc
    }

    private let active: Bool

    var icon: UIImage {
        if isInvalid {
            return .expired
        }
        if certificate.vaccinationCertificate.expiresSoon {
            return .activity
        }
        return .statusFullDetail
    }

    var iconColor: UIColor {
        if !active || isInvalid {
            return .onBackground40
        }
        if dgc.v?.first?.fullImmunization ?? true == false {
            return .brandAccent
        }
        return .neutralWhite
    }

    private var isInvalid: Bool {
        certificate.vaccinationCertificate.isExpired || certificate.isInvalid || certificate.isRevoked
    }

    var iconBackgroundColor: UIColor {
        if !active || isInvalid {
            return .onBackground20
        }
        if dgc.v?.first?.fullImmunization ?? true == false {
            return .brandAccent20
        }
        return .brandAccentBlue
    }

    var title: String {
        isNeutral ? dgc.nam.fullName : "certificates_overview_recovery_certificate_title".localized
    }

    var titleAccessibilityLabel: String? { title }

    var subtitle: String {
        isNeutral ? "certificates_overview_recovery_certificate_title".localized : "certificates_overview_recovery_certificate_message".localized
    }

    var subtitleAccessibilityLabel: String? { subtitle }

    var info: String {
        isNeutral ? "certificates_overview_recovery_certificate_message".localized : infoString(forAccessibility: false) ?? ""
    }

    var infoAccessibilityLabel: String? {
        infoString(forAccessibility: true) ?? info
    }

    var info2: String? {
        if isNeutral {
            return infoString(forAccessibility: false) ?? ""
        }
        if certificate.vaccinationCertificate.isExpired {
            return "certificates_overview_expired_certificate_note".localized
        }
        if certificate.vaccinationCertificate.expiresSoon {
            return "certificates_overview_expires_soon_certificate_note".localized
        }
        if certificate.isInvalid || certificate.isRevoked {
            return "certificates_overview_invalid_certificate_note".localized
        }
        return nil
    }

    var info2AccessibilityLabel: String? { info2 }

    var certificateItemIsSelectableAccessibilityLabel: String {
        "accessibility_overview_certificates_label_display_certificate".localized
    }

    var statusIcon: UIImage? { isNeutral ? nil : .validationCheckmark }

    var statusIconHidden: Bool { statusIcon == nil }

    var statusIconAccessibilityLabel: String? { nil }

    var activeTitle: String? {
        if isNeutral {
            return nil
        }
        return active ? "certificates_overview_currently_uses_certificate_note".localized : nil
    }

    var isNeutral: Bool
    var warningText: String? {
        if renewalNeeded {
            return "renewal_expiry_notification_title".localized
        }
        return nil
    }

    var renewalNeeded: Bool {
        if Date().passedFirstOfJanuary2024 {
            return false
        }
        let cert = certificate.vaccinationCertificate
        return certificate.isNotRevoked && cert.expiresSoon && !cert.expiredMoreThan90Days && cert.isGermanIssuer
    }

    init(_ certificate: ExtendedCBORWebToken, active: Bool = false, neutral: Bool = false) {
        self.certificate = certificate
        self.active = active
        isNeutral = neutral
    }

    // MARK: - Helpers

    private func infoString(forAccessibility accessibility: Bool) -> String? {
        guard let r = dgc.r?.first else { return nil }

        let formatter = accessibility ? DateUtils.audioDateFormatter : DateUtils.displayDateFormatter
        if Date() < r.df {
            return String(format: "certificates_overview_recovery_certificate_valid_from_date".localized,
                          formatter.string(from: r.df))
        }
        return String(format: "certificates_overview_recovery_certificate_sample_date".localized,
                      formatter.string(from: r.fr))
    }
}
