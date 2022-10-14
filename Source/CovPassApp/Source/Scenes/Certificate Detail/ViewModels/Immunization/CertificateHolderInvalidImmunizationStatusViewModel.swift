//
//  CertificateHolderInvalidImmunizationStatusViewModel.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit

struct CertificateHolderInvalidImmunizationStatusViewModel: CertificateHolderImmunizationStatusViewModelProtocol {
    let icon: UIImage = .statusExpiredCircle
    let title = "infschg_start_expired_revoked".localized
    let subtitle: String? = nil
    let description = "infschg_cert_overview_immunisation_invalid".localized
    var date: String?
    var federalState: String? = nil
    var federalStateText: String? = nil
    let linkLabel: String? = nil
    let notice: String? = nil
    let noticeText: String? = nil
    let selectFederalStateButtonTitle: String? = nil
}
