//
//  CertificateHolderCompleteImmunizationStatusViewModel.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit

struct CertificateHolderCompleteVaccinationCycleStatusViewModel: CertificateHolderImmunizationStatusViewModelProtocol {
    let icon: UIImage = .statusFullCircle
    let title = "infschg_start_immune_complete".localized
    let description: String
    var subtitle: String?
    var date: String?
    var federalState: String?
    var federalStateText: String?
    let linkLabel: String? = nil
    let notice: String? = nil
    let noticeText: String? = nil
    let selectFederalStateButtonTitle: String? = nil
}
