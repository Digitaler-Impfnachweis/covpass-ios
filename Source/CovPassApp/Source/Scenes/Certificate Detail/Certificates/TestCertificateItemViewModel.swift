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
        .iconTest
    }

    var iconColor: UIColor {
        if !active {
            return .onBackground40
        }
        return .neutralWhite
    }

    var iconBackgroundColor: UIColor {
        if !active {
            return .onBackground20
        }
        return .brandAccentPurple
    }

    var title: String {
        return "certificates_overview_test_certificate_title".localized
    }

    var subtitle: String {
        if let t = dgc.t?.first {
            return t.isPCR ? "certificates_overview_pcr_test_certificate_message".localized : "certificates_overview_test_certificate_message".localized
        }
        return ""
    }

    var info: String {
        if let t = dgc.t?.first {
            return String(format: "certificates_overview_test_certificate_date".localized, DateUtils.displayDateTimeFormatter.string(from: t.sc))
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
