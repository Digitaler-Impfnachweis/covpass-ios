//
//  CertificateCycleIncompleteReasonInvalid.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit

struct CertificateCycleIncompleteReasonInvalid: CertificateInvalidReasonViewModelProtocol {
    let icon: UIImage = .statusExpired
    let title = "functional_validation_check_popup_unsuccessful_certificate_subheadline_protection".localized
    let description = "functional_validation_check_popup_unsuccessful_certificate_subheadline_protection_text".localized
}
