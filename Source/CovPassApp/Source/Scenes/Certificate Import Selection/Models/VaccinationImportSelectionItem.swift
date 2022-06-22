//
//  VaccinationImportSelectionItem.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import Foundation

private enum Constants {
    static let certificateType = "certificates_overview_vaccination_certificate_title".localized
    static let dateFormatString = "certificates_overview_vaccination_certificate_date".localized
    static let doseFormatString = "certificates_overview_vaccination_certificate_message".localized
}

final class VaccinationImportSelectionItem: CertificateImportSelectionItem {
    init(name: Name, vaccination: Vaccination) {
        let dose = String(
            format: Constants.doseFormatString,
            vaccination.dn, vaccination.sd
        )
        let vaccinationDateString = String(
            format: Constants.dateFormatString,
            DateUtils.dayMonthYearDateFormatter.string(from: vaccination.dt)
        )
        super.init(
            title: name.fullName,
            subtitle: Constants.certificateType,
            additionalLines: [dose, vaccinationDateString]
        )
    }
}
