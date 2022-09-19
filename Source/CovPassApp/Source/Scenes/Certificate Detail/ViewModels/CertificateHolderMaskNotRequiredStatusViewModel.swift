//
//  CertificateHolderMaskNotRequiredStatusViewModel.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit

struct CertificateHolderMaskNotRequiredStatusViewModel: CertificateHolderImmunizationStatusViewModelProtocol {
    let icon: UIImage = .statusMaskOptionalCircle
    let title = "infschg_start_mask_optional".localized
    let subtitle: String? = nil
    let description = "infschg_cert_overview_mask_hint_optional".localized
}
