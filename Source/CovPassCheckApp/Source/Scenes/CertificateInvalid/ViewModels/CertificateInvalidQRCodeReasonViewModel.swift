//
//  CertificateInvalidQRCodeReasonViewModel.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit

struct CertificateInvalidQRCodeReasonViewModel: CertificateInvalidReasonViewModelProtocol {
    let icon: UIImage = .statusMaskRequiredReasonQRCode
    let title = "technical_validation_check_popup_unsuccessful_certificate_qrreadibility_subheading".localized
    let description = "technical_validation_check_popup_unsuccessful_certificate_qrreadibility_subline".localized
}
