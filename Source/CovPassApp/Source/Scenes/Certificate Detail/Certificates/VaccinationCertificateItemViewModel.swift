//
//  VaccinationCertificateItemViewModel.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import Foundation
import UIKit

struct VaccinationCertificateItemViewModel: CertificateItemViewModel {
    private let certificate: ExtendedCBORWebToken
    private var dgc: DigitalGreenCertificate {
        certificate.vaccinationCertificate.hcert.dgc
    }

    private var formatter: NumberFormatter {
        let nf = NumberFormatter()
        nf.numberStyle = .ordinal
        return nf
    }

    private let active: Bool

    var icon: UIImage {
        if certificate.vaccinationCertificate.isExpired || certificate.isInvalid {
            return .expired
        }
        if certificate.vaccinationCertificate.expiresSoon {
            return .activity
        }
        return dgc.v?.first?.fullImmunization ?? false ? .statusFullDetail : .statusPartial
    }

    var iconColor: UIColor {
        if !active || certificate.vaccinationCertificate.isExpired || certificate.isInvalid {
            return .onBackground40
        }
        if dgc.v?.first?.fullImmunization ?? true == false {
            return .brandAccent
        }
        return .neutralWhite
    }

    var iconBackgroundColor: UIColor {
        if !active || certificate.vaccinationCertificate.isExpired || certificate.isInvalid {
            return .onBackground20
        }
        if dgc.v?.first?.fullImmunization ?? true == false {
            return .brandAccent20
        }
        return .brandAccent
    }

    var title: String {
        neutral ? dgc.nam.fullName : "certificates_overview_vaccination_certificate_title".localized
    }

    var titleAccessibilityLabel: String? { title }

    var subtitle: String {
        if neutral {
            return "certificates_overview_vaccination_certificate_title".localized
        }
        guard let v = dgc.v?.first else { return "" }
        return String(format: "certificates_overview_vaccination_certificate_message".localized, v.dn, v.sd)
    }

    var subtitleAccessibilityLabel: String? { subtitle }

    var info: String {
        if neutral {
            guard let v = dgc.v?.first else { return "" }
            return String(format: "certificates_overview_vaccination_certificate_message".localized, v.dn, v.sd)
        }
        if let v = dgc.v?.first {
            return String(format: "certificates_overview_vaccination_certificate_date".localized, DateUtils.displayDateFormatter.string(from: v.dt))
        }
        return ""
    }

    var infoAccessibilityLabel: String? {
        guard let v = dgc.v?.first else { return info }
        return String(format: "certificates_overview_vaccination_certificate_date".localized, DateUtils.audioDateFormatter.string(from: v.dt))
    }

    var info2: String? {
        if certificate.vaccinationCertificate.isExpired {
            return "certificates_overview_expired_certificate_note".localized
        }
        if certificate.vaccinationCertificate.expiresSoon {
            return "certificates_overview_expires_soon_certificate_note".localized
        }
        if certificate.isInvalid {
            return "certificates_overview_invalid_certificate_note".localized
        }
        return nil
    }

    var info2AccessibilityLabel: String? { info2 }

    var certificateItemIsSelectableAccessibilityLabel: String {
        "accessibility_overview_certificates_label_display_certificate".localized
    }

    var statusIcon: UIImage? { neutral ? nil : .validationCheckmark }
    
    var statusIconHidden: Bool { statusIcon == nil }

    var statusIconAccessibilityLabel: String? { activeTitle }

    var activeTitle: String? {
        if neutral {
            if let v = dgc.v?.first {
                return String(format: "certificates_overview_vaccination_certificate_date".localized, DateUtils.displayDateFormatter.string(from: v.dt))
            }
        }
        return active ? "certificates_overview_currently_uses_certificate_note".localized : nil
    }
    
    var neutral: Bool

    init(_ certificate: ExtendedCBORWebToken, active: Bool = false, neutral: Bool = false) {
        self.certificate = certificate
        self.active = active
        self.neutral = neutral
    }
}
