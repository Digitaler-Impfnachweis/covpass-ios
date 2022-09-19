//
//  CertificateHolderInvalidImmunizationStatusViewModel.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit

struct CertificateHolderInvalidImmunizationStatusViewModel: CertificateHolderImmunizationStatusViewModelProtocol {
    let icon: UIImage = .statusExpiredCircle
    let title = "infschg_start_expired_revoked".localized
    let subtitle: String? = nil
    let description = "infschg_cert_overview_immunisation_invalid".localized
}
