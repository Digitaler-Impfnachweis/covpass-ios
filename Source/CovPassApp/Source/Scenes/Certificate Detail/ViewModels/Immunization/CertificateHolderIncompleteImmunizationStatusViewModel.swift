//
//  CertificateHolderIncompleteImmunizationStatusViewModel.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import UIKit

struct CertificateHolderIncompleteImmunizationStatusViewModel: CertificateHolderImmunizationStatusViewModelProtocol {
    let icon: UIImage = .statusPartialCircle
    let title = "infschg_start_immune_incomplete".localized
    let subtitle: String? = nil
    let description = "infschg_cert_overview_immunisation_incomplete_A".localized
    var date: String?
    var federalState: String?
    var federalStateText: String?
    let linkLabel: String? = nil
    let notice: String? = nil
    let noticeText: String? = nil
    let selectFederalStateButtonTitle: String? = nil
}

struct CertificateHolderImmunizationE1StatusViewModel: CertificateHolderImmunizationStatusViewModelProtocol {
    let icon: UIImage = .statusPartialCircle
    let title = "infschg_start_immune_incomplete".localized
    var description: String
    var subtitle: String? {
        guard let date = date else { return nil }
        return String(format: "infschg_cert_overview_immunisation_time_from".localized, date)
    }

    var date: String?
    var federalState: String?
    var federalStateText: String?
    let linkLabel: String? = nil
    let notice: String? = nil
    let noticeText: String? = nil
    let selectFederalStateButtonTitle: String? = nil
}
