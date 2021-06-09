//
//  VaccinationCertificateItemViewModel.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import UIKit
import CovPassUI
import CovPassCommon

struct VaccinationCertificateItemViewModel: CertificateItemViewModel {
    private let certificate: ExtendedCBORWebToken
    private var dgc: DigitalGreenCertificate {
        certificate.vaccinationCertificate.hcert.dgc
    }
    private let active: Bool

    var icon: UIImage {
        dgc.v?.first?.fullImmunization ?? false ? .statusFullDetail : .statusPartialDetail
    }

    var iconColor: UIColor {
        if !active {
            return .onBackground40
        }
        if dgc.v?.first?.fullImmunization ?? true == false {
            return .brandAccent
        }
        return .neutralWhite
    }

    var iconBackgroundColor: UIColor {
        if !active {
            return .onBackground20
        }
        if dgc.v?.first?.fullImmunization ?? true == false {
            return .brandAccent20
        }
        return .brandAccent
    }

    var title: String {
        "certificates_overview_vaccination_certificate_title".localized
    }

    var subtitle: String {
        if let v = dgc.v?.first {
            return String(format: "certificates_overview_vaccination_certificate_message".localized, v.dn, v.sd)
        }
        return ""
    }

    var info: String {
        if let v = dgc.v?.first {
            return String(format: "certificates_overview_vaccination_certificate_date".localized, DateUtils.displayDateFormatter.string(from: v.dt))
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
