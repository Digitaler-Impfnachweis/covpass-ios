//
//  MaskRequiredQRCodeReasonViewModel.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit

struct MaskRequiredQRCodeReasonViewModel: MaskRequiredReasonViewModelProtocol {
    let icon: UIImage = .statusMaskRequiredReasonQRCode
    let title = "infschg_result_mask_mandatory_reason_5_title".localized
    let description = "infschg_result_mask_mandatory_reason_5_copy".localized
}
