//
//  TestImportSelectionItem.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon

private enum Constants {
    static let certificateType = "certificates_overview_test_certificate_title".localized
    static let dateFormatString = "certificates_overview_test_certificate_date".localized
    static let infoString = "certificates_overview_recovery_certificate_message".localized
}

final class TestImportSelectionItem: CertificateImportSelectionItem {
    init?(token: ExtendedCBORWebToken) {
        let dgc = token.vaccinationCertificate.hcert.dgc
        let name = dgc.nam
        guard let test = dgc.t?.first else {
            return nil
        }
        let testDateString = String(
            format: Constants.dateFormatString,
            DateUtils.dayMonthYearDateFormatter.string(from: test.sc)
        )
        super.init(
            title: name.fullName,
            subtitle: Constants.certificateType,
            additionalLines: [test.testType, testDateString],
            token: token
        )
    }
}

private extension Test {
    var testType: String {
        isPCR ?
            "certificates_overview_pcr_test_certificate_message".localized :
            "certificates_overview_test_certificate_message".localized
    }
}
