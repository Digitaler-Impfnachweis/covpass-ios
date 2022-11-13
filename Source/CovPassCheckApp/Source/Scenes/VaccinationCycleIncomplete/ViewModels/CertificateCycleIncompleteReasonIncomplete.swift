//
//  CertificateCycleIncompleteReasonIncomplete.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit

struct CertificateCycleIncompleteReasonIncomplete: CertificateInvalidReasonViewModelProtocol {
    let icon: UIImage = .statusMaskRequiredReasonIncomplete
    let title = "functional_validation_check_popup_unsuccessful_certificate_subheadline_expiration".localized
    let description = "functional_validation_check_popup_unsuccessful_certificate_subheadline_expiration_text".localized
}
