//
//  TestCertificateItemViewModel.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import Foundation
import UIKit

struct TestCertificateItemViewModel: CertificateItemViewModel {
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
        return .iconTest
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
        return .brandAccentPurple
    }

    var title: String {
        isNeutral ? dgc.nam.fullName : "certificates_overview_test_certificate_title".localized
    }

    var titleAccessibilityLabel: String? { title }

    var subtitle: String {
        if isNeutral {
            return "certificates_overview_test_certificate_title".localized
        }
        if let t = dgc.t?.first {
            return t.isPCR ? "certificates_overview_pcr_test_certificate_message".localized : "certificates_overview_test_certificate_message".localized
        }
        return ""
    }

    var subtitleAccessibilityLabel: String? { subtitle }

    var info: String {
        if isNeutral {
            if let t = dgc.t?.first {
                return t.isPCR ? "certificates_overview_pcr_test_certificate_message".localized : "certificates_overview_test_certificate_message".localized
            }
        }
        if let t = dgc.t?.first {
            return String(format: "certificates_overview_test_certificate_date".localized, DateUtils.displayDateTimeFormatter.string(from: t.sc))
        }
        return ""
    }

    var infoAccessibilityLabel: String? {
        guard let t = dgc.t?.first else { return info }
        return String(format: "certificates_overview_vaccination_certificate_date".localized, DateUtils.audioDateFormatter.string(from: t.sc))
    }

    var info2: String? {
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
            if let t = dgc.t?.first {
                return String(format: "certificates_overview_test_certificate_date".localized, DateUtils.displayDateTimeFormatter.string(from: t.sc))
            }
        }
        return active ? "certificates_overview_currently_uses_certificate_note".localized : nil
    }

    var isNeutral: Bool

    init(_ certificate: ExtendedCBORWebToken, active: Bool = false, neutral: Bool = false) {
        self.certificate = certificate
        self.active = active
        isNeutral = neutral
    }
}
