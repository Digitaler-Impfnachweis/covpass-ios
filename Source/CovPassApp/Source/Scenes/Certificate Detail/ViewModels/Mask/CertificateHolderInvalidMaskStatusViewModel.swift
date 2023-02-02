//
//  CertificateHolderInvalidMaskStatusViewModel.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit

struct CertificateHolderInvalidMaskStatusViewModel: CertificateHolderImmunizationStatusViewModelProtocol {
    let icon: UIImage = .statusMaskInvalidCircle
    let title = "infschg_detail_view_status_not_applicable_title".localized
    let subtitle: String? = nil
    let description = "infschg_detail_view_status_not_applicable_copy".localized
    var date: String?
    var federalState: String?
    var federalStateText: String?
    let linkLabel: String? = "infschg_detail_page_no_valid_certificate_link".localized
    let notice: String? = "infschg_detail_page_mask_status_uncertain_subtitle_2".localized
    let noticeText: String? = "infschg_detail_page_mask_status_uncertain_copy_2".localized
    let selectFederalStateButtonTitle: String? = "infschg_detail_page_mask_status_uncertain_button".localized
}
