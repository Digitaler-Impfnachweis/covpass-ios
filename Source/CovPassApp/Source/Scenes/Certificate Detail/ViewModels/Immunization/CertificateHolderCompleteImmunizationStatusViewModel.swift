//
//  CertificateHolderCompleteImmunizationStatusViewModel.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit

struct CertificateHolderCompleteImmunizationB2StatusViewModel: CertificateHolderImmunizationStatusViewModelProtocol {
    let icon: UIImage = .statusFullCircle
    let title = "infschg_start_immune_complete".localized
    let description: String = "infschg_cert_overview_immunisation_complete_B2".localized
    var subtitle: String?
    var date: String?
    var federalState: String?
    var federalStateText: String?
    let linkLabel: String? = nil
    let notice: String? = nil
    let noticeText: String? = nil
    let selectFederalStateButtonTitle: String? = nil
}

struct CertificateHolderImmunizationC2StatusViewModel: CertificateHolderImmunizationStatusViewModelProtocol {
    let icon: UIImage = .statusFullCircle
    let title = "infschg_start_immune_complete".localized
    let description = "infschg_cert_overview_immunisation_third_vacc_C2".localized
    var subtitle: String?
    var date: String?
    var federalState: String?
    var federalStateText: String?
    let linkLabel: String? = nil
    let notice: String? = nil
    let noticeText: String? = nil
    let selectFederalStateButtonTitle: String? = nil
}

struct CertificateHolderImmunizationE2StatusViewModel: CertificateHolderImmunizationStatusViewModelProtocol {
    let icon: UIImage = .statusFullCircle
    let title = "infschg_start_immune_complete".localized
    let description = "infschg_cert_overview_immunisation_E2".localized
    var subtitle: String?
    var date: String?
    var federalState: String?
    var federalStateText: String?
    let linkLabel: String? = nil
    let notice: String? = nil
    let noticeText: String? = nil
    let selectFederalStateButtonTitle: String? = nil
}
