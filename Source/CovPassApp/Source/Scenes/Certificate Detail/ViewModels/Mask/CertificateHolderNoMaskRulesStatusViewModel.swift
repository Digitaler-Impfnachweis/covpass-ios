//
//  CertificateHolderNoMaskRulesStatusViewModel.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit

struct CertificateHolderNoMaskRulesStatusViewModel: CertificateHolderImmunizationStatusViewModelProtocol {
    let icon: UIImage = .statusMaskNoRulesCircleSmall
    let title = "infschg_detail_page_mask_status_uncertain_title".localized
    var subtitle: String? = nil
    var date: String? = nil
    var federalState: String?
    var federalStateText: String? {
        guard let federalState = federalState else { return nil }
        let federalStateLocalized = ("DE_" + federalState).localized
        return String(format: "infschg_detail_page_mask_status_uncertain_federal_state".localized, federalStateLocalized)
    }
    let description = "infschg_detail_page_mask_status_uncertain_copy_1".localized
    let linkLabel: String? = "infschg_detail_page_mask_status_uncertain_link".localized
    let notice: String? = "infschg_detail_page_mask_status_uncertain_subtitle_2".localized
    let noticeText: String? = "infschg_detail_page_mask_status_uncertain_copy_2".localized
    let selectFederalStateButtonTitle: String? = "infschg_detail_page_mask_status_uncertain_button".localized
}
