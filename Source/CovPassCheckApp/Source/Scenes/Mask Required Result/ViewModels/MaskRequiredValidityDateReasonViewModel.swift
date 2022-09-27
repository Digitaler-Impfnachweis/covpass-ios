//
//  MaskRequiredValidityDateReasonViewModel.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit

struct MaskRequiredValidityDateReasonViewModel: MaskRequiredReasonViewModelProtocol {
    let icon: UIImage = .statusMaskRequiredReasonValidityDate
    let title = "infschg_result_mask_mandatory_reason_1_title".localized
    let description = "infschg_result_mask_mandatory_reason_1_copy".localized
}
