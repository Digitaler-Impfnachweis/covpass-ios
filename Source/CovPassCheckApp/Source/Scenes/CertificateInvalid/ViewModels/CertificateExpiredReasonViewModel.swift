//
//  CertificateExpiredReasonViewModel.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit

struct CertificateExpiredReasonViewModel: CertificateInvalidReasonViewModelProtocol {
    let icon: UIImage = .activity
    let title = "technical_validation_invalid_expired_title".localized
    let description = "technical_validation_invalid_expired_subtitle".localized
}
