//
//  CertificateHolderIncompleteImmunizationStatusViewModel.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit

struct CertificateHolderIncompleteImmunizationStatusViewModel: CertificateHolderImmunizationStatusViewModelProtocol {
    let icon: UIImage = .statusPartialCircle
    let title = "infschg_start_immune_incomplete".localized
    let subtitle: String? = nil
    let description = "infschg_cert_overview_immunisation_incomplete_A".localized
}

struct CertificateHolderImmunizationE22StatusViewModel: CertificateHolderImmunizationStatusViewModelProtocol {
    let icon: UIImage = .statusPartialCircle
    let title = "infschg_start_immune_incomplete".localized
    let subtitle: String? = nil
    let days: Int!
    var description: String {String(format: "infschg_cert_overview_immunisation_E22".localized, days)}
}
