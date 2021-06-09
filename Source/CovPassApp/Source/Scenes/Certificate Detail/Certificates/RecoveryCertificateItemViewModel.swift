//
//  RecoveryCertificateItemViewModel.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import UIKit
import CovPassUI
import CovPassCommon

struct RecoveryCertificateItemViewModel: CertificateItemViewModel {
    private let certificate: ExtendedCBORWebToken
    private var dgc: DigitalGreenCertificate {
        certificate.vaccinationCertificate.hcert.dgc
    }
    private let active: Bool

    var icon: UIImage {
        .statusFullDetail
    }

    var iconColor: UIColor {
        if !active {
            return .onBackground100
        }
        return .neutralWhite
    }

    var iconBackgroundColor: UIColor {
        if !active {
            return .onBackground70
        }
        return .brandAccentBlue
    }

    var title: String {
        return "certificates_overview_recovery_certificate_title".localized
    }

    var subtitle: String {
        return "certificates_overview_recovery_certificate_message".localized
    }

    var info: String {
        if let r = dgc.r?.first {
            if Date() < r.df {
                return String(format: "certificates_overview_recovery_certificate_valid_from_date".localized, DateUtils.displayDateFormatter.string(from: r.df))
            }
            return String(format: "certificates_overview_recovery_certificate_valid_until_date".localized, DateUtils.displayDateFormatter.string(from: r.du))
        }
        return ""
    }

    var activeTitle: String? {
        active ? "certificates_overview_currently_uses_certificate_note".localized : nil
    }

    init(_ certificate: ExtendedCBORWebToken, active: Bool = false) {
        self.certificate = certificate
        self.active = active
    }
}
