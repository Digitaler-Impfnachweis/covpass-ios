//
//  ValidationViewModel+Extension.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import CovPassUI
import PromiseKit
import UIKit


extension ValidationViewModelProtocol {
   
    var revocationInfoHidden: Bool { true }
    var revocationInfoText: String { "" }
    var revocationHeadline: String { "" }

    func revocationButtonTapped() {
        // not covered by CovPass
    }
    
    var toolbarState: CustomToolbarState {
        .confirm("vaccination_certificate_detail_view_qrcode_screen_action_button_title".localized)
    }
    
    func cancel() {
        router.showStart()
    }

    func scanCertificate() {
        router.showStart()
    }
}
