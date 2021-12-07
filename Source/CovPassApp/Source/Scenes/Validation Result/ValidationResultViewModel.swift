//
//  ValidationResultViewModel.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import PromiseKit
import UIKit


extension ValidationViewModel {
    
    var toolbarState: CustomToolbarState {
        .confirm("vaccination_certificate_detail_view_qrcode_screen_action_button_title".localized)
    }
    
    func cancel() {
        router.showStart()
    }

    func scanNextCertifcate() {
        router.showStart()
    }
}
