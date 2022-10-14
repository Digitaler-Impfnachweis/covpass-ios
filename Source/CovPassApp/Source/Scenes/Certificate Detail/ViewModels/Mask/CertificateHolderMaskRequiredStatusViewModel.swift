//
//  CertificateHolderMaskRequiredStatusViewModel.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit

struct CertificateHolderMaskRequiredStatusViewModel: CertificateHolderImmunizationStatusViewModelProtocol {
    let icon: UIImage = .statusMaskRequiredCircle
    let title = "infschg_detail_page_mask_mandatory_title".localized
    var subtitle: String? {
        guard let dateString = date else { return nil }
        return String(format: "infschg_detail_page_mask_mandatory_subtitle".localized, dateString)
    }
    var date: String? = nil
    var federalState: String?
    var federalStateText: String? {
        guard let federalState = federalState else { return nil }
        let federalStateLocalized = ("DE_" + federalState).localized
        return String(format: "infschg_detail_page_mask_mandatory_federal_state".localized, federalStateLocalized)
    }
    let description = "infschg_detail_page_mask_mandatory_copy_1".localized
    let linkLabel: String? = "infschg_detail_page_mask_mandatory_link".localized
    let notice: String? = "infschg_detail_page_mask_mandatory_subtitle_2".localized
    let noticeText: String? = "infschg_detail_page_mask_mandatory_copy_2".localized
    let selectFederalStateButtonTitle: String? = "infschg_detail_page_mask_mandatory_button".localized
}
