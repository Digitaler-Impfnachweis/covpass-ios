//
//  ResultItemViewModel.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import Foundation
import UIKit

struct ResultItemViewModel: CertificateItemViewModel {
    let result: CertificateResult

    var icon: UIImage {
        if result.state == .open {
            if result.certificate.vaccinationCertificate.hcert.dgc.t?.isEmpty == false {
                return .iconTest
            }
            if result.certificate.vaccinationCertificate.hcert.dgc.r?.isEmpty == false {
                return .iconYellow
            }
            return .iconYellow
        }
        if result.state == .fail {
            return .iconRed
        }
        if result.certificate.vaccinationCertificate.hcert.dgc.t?.isEmpty == false {
            return .iconTest
        }
        if result.certificate.vaccinationCertificate.hcert.dgc.r?.isEmpty == false {
            return .statusFullDetail
        }
        return .statusFullDetail
    }

    var iconColor: UIColor {
        if result.state == .open {
            return .resultYellow
        }
        if result.state == .fail {
            return .resultRed
        }
        return .resultGreen
    }

    var iconBackgroundColor: UIColor {
        if result.state == .open {
            return .resultYellowBackground
        }
        if result.state == .fail {
            return .resultRedBackground
        }
        return .resultGreenBackground
    }

    var title: String {
        result.certificate.vaccinationCertificate.hcert.dgc.nam.fullName
    }

    var titleAccessibilityLabel: String? { title }

    var subtitle: String {
        if result.certificate.vaccinationCertificate.hcert.dgc.t?.isEmpty == false {
            return "certificate_check_validity_test".localized
        }
        if result.certificate.vaccinationCertificate.hcert.dgc.r?.isEmpty == false {
            return "certificate_check_validity_recovery".localized
        }
        return "certificate_check_validity_vaccination".localized
    }

    var subtitleAccessibilityLabel: String? { subtitle }

    var info: String {
        if result.state == .open {
            return "certificate_check_validity_result_not_testable".localized
        }
        if result.state == .fail {
            return "certificate_check_validity_result_not_valid".localized
        }
        return "certificate_check_validity_result_valid".localized
    }

    var infoAccessibilityLabel: String? { info }

    var certificateItemIsSelectableAccessibilityLabel: String {
        "accessibility_overview_certificates_label_display_certificate".localized
    }

    var info2: String? { nil }
    var info2AccessibilityLabel: String? { nil }

    var statusIcon: UIImage { .validationCheckmark }
    var statusIconAccessibilityLabel: String? { nil }

    var activeTitle: String? { nil }

    init(_ result: CertificateResult) {
        self.result = result
    }
}
