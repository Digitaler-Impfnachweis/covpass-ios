//
//  MaskRequiredInvalidSignatureReasonViewModel.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit

struct MaskRequiredInvalidSignatureReasonViewModel: MaskRequiredReasonViewModelProtocol {
    let icon: UIImage = .statusMaskRequiredReasonOther
    let title = "infschg_result_mask_mandatory_reason_4_title".localized
    let description = "infschg_result_mask_mandatory_reason_4_copy".localized
}
