//
//  RecoveryImportSelectionItem.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
import Foundation

private enum Constants {
    static let certificateType = "certificates_overview_recovery_certificate_title".localized
    static let dateFormatString = "certificates_overview_recovery_certificate_valid_until_date".localized
    static let infoString = "certificates_overview_recovery_certificate_message".localized
}

final class RecoveryImportSelectionItem: CertificateImportSelectionItem {
    init?(token: ExtendedCBORWebToken) {
        let dgc = token.vaccinationCertificate.hcert.dgc
        let name = dgc.nam
        guard let recovery = dgc.r?.first else {
            return nil
        }
        let recoveryDateString = String(
            format: Constants.dateFormatString,
            DateUtils.dayMonthYearDateFormatter.string(from: recovery.du)
        )
        super.init(
            title: name.fullName,
            subtitle: Constants.certificateType,
            additionalLines: [Constants.infoString, recoveryDateString],
            token: token
        )
    }
}
