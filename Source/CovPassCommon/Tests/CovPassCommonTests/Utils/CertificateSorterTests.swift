//
//  CertificateSorterTests.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import PromiseKit
import XCTest

@testable import CovPassCommon

extension CBORWebToken {
    func mockName(_ name: Name) -> Self {
        var token = self
        token.hcert.dgc.nam = name
        return token
    }
    func mockVaccinationUVCI(_ uvci: String) -> Self {
        hcert.dgc.v?.first?.ci = uvci
        return self
    }

    func mockVaccinationSetDate(_ date: Date) -> Self {
        hcert.dgc.v?.first?.dt = date
        return self
    }

    func extended() -> ExtendedCBORWebToken {
        ExtendedCBORWebToken(vaccinationCertificate: self, vaccinationQRCodeData: "")
    }
}

class CertificateSorterTests: XCTestCase {
    func testSorting() throws {
        let certificates = [
            CBORWebToken
                .mockVaccinationCertificate
                .mockVaccinationUVCI("1")
                .mockVaccinationSetDate(Date())
                .extended(),
            CBORWebToken
                .mockVaccinationCertificate
                .mockVaccinationUVCI("2")
                .mockVaccinationSetDate(Calendar.current.date(byAdding: .day, value: -20, to: Date())!)
                .extended()
        ]
        let sortedCertifiates = CertificateSorter.sort(certificates)

        XCTAssertEqual(sortedCertifiates.count, 2)
        XCTAssertEqual(sortedCertifiates[0].vaccinationCertificate.hcert.dgc.uvci, "2")
        XCTAssertEqual(sortedCertifiates[1].vaccinationCertificate.hcert.dgc.uvci, "1")
    }
}
