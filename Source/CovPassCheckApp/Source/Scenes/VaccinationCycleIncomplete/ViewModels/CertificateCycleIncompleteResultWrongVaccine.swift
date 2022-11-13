//
//  CertificateCycleIncompleteResultWrongVaccine.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit

struct CertificateCycleIncompleteResultWrongVaccine: CertificateInvalidReasonViewModelProtocol {
    let icon: UIImage = .statusExpired
    let title = "functional_validation_check_popup_unsuccessful_certificate_subheadline_uncompleted".localized
    let description = "functional_validation_check_popup_unsuccessful_certificate_subheadline_uncompleted_text".localized
}
