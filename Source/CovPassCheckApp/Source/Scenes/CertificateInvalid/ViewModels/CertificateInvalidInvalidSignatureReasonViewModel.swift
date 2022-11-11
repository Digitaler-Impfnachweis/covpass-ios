//
//  CertificateInvalidInvalidSignatureReasonViewModel.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit

struct CertificateInvalidInvalidSignatureReasonViewModel: CertificateInvalidReasonViewModelProtocol {
    let icon: UIImage = .statusMaskRequiredReasonOther
    let title = "technical_validation_check_popup_unsuccessful_certificate_signature_subheading".localized
    let description = "technical_validation_check_popup_unsuccessful_certificate_signature_subline".localized
}
