//
//  CertificateHolderMaskRequiredStatusViewModel.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit

struct CertificateHolderMaskRequiredStatusViewModel: CertificateHolderImmunizationStatusViewModelProtocol {
    let icon: UIImage = .statusMaskRequiredCircle
    let title = "infschg_start_mask_mandatory".localized
    let description = "infschg_cert_overview_mask_hint_mandatory".localized
    var subtitle: String? {
        guard let dateString = date else { return nil }
        return String(format: "infschg_cert_overview_mask_time_from".localized, dateString)
    }
    var date: String? = nil
}
