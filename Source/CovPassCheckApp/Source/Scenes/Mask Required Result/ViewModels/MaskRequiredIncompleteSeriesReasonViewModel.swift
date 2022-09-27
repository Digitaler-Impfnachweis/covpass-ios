//
//  MaskRequiredIncompleteSeriesReasonViewModel.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit

struct MaskRequiredIncompleteSeriesReasonViewModel: MaskRequiredReasonViewModelProtocol {
    let icon: UIImage = .statusMaskRequiredReasonIncomplete
    let title = "infschg_result_mask_mandatory_reason_3_title".localized
    let description = "infschg_result_mask_mandatory_reason_3_copy".localized
}
