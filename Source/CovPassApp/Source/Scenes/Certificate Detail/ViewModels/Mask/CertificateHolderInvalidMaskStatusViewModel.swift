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
    let notice: String? = nil
    let noticeText: String? = nil
    let selectFederalStateButtonTitle: String? = nil
}
