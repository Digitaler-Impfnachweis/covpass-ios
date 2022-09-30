//
//  MaskRequiredSecondCertificateReasonViewModel.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit

struct MaskRequiredSecondCertificateReasonViewModel: MaskRequiredSecondCertificateReasonViewModelProtocol {
    let icon: UIImage = .statusMaskRequiredReasonSecondCertificate
    let title = "infschg_result_mask_mandatory_second_scan_infobox_title".localized
    let description = "infschg_result_mask_mandatory_second_scan_infobox_copy".localized
    let buttonText = "infschg_result_mask_mandatory_second_scan_infobox_button".localized
}
