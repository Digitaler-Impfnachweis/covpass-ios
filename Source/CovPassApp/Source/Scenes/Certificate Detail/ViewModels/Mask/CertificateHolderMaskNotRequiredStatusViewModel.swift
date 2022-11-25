//
//  CertificateHolderMaskNotRequiredStatusViewModel.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import UIKit

struct CertificateHolderMaskNotRequiredStatusViewModel: CertificateHolderImmunizationStatusViewModelProtocol {
    let userDefaults: Persistence
    let certificateHolderStatus: CertificateHolderStatusModelProtocol

    let icon: UIImage = .statusMaskOptionalCircle
    let title = "infschg_detail_page_no_mask_mandatory_title".localized
    var subtitle: String? {
        guard let dateString = date else { return nil }
        return String(format: "infschg_detail_page_no_mask_mandatory_subtitle".localized, dateString)
    }

    var date: String?
    var federalState: String?
    var federalStateText: String? {
        guard let federalState = federalState else { return nil }
        let federalStateLocalized = ("DE_" + federalState).localized
        return String(format: "infschg_detail_page_no_mask_mandatory_federal_state".localized, federalStateLocalized)
    }

    var description: String {
        guard let date = certificateHolderStatus.latestMaskRuleDate(for: userDefaults.stateSelection) else {
            return "infschg_detail_page_no_mask_mandatory_copy_1".localized
        }
        return String(format: "infschg_detail_page_no_mask_mandatory_copy_1".localized, DateUtils.displayDateFormatter.string(from: date))
    }

    let linkLabel: String? = "infschg_detail_page_no_mask_mandatory_link".localized
    let notice: String? = "infschg_detail_page_no_mask_mandatory_subtitle_2".localized
    let noticeText: String? = "infschg_detail_page_no_mask_mandatory_copy_2".localized
    let selectFederalStateButtonTitle: String? = "infschg_detail_page_no_mask_mandatory_button".localized
}
