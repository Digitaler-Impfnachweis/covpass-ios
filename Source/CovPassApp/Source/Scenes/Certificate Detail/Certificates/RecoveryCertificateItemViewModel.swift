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

struct RecoveryCertificateItemViewModel: CertificateItemViewModel {
    var icon: UIImage {
        .completness
    }

    var iconColor: UIColor {
        .neutralWhite
    }

    var iconBackgroundColor: UIColor {
        .brandAccent
    }

    var title: String {
        "Testcert"
    }

    var subtitle: String {
        "Antigen-Schnelltest"
    }

    var info: String {
        "Getestet am 123.123.123, 12:12"
    }

    var activeTitle: String? {
        "Aktuell verwendetes Zertifikat"
    }

    init(_ certificate: ExtendedCBORWebToken) {

    }
}
