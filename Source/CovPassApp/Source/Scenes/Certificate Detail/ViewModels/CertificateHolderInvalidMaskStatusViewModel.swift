//
//  CertificateHolderInvalidMaskStatusViewModel.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit

struct CertificateHolderInvalidMaskStatusViewModel: CertificateHolderImmunizationStatusViewModelProtocol {
    let icon: UIImage = .statusMaskInvalidCircle
    let title = "infschg_start_expired_revoked".localized
    let subtitle: String? = nil
    let description = "infschg_cert_overview_mask_hint_mandatory".localized
}
