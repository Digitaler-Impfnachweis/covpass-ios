//
//  CertificateListTests.swift
//  
//
//  Created by Thomas Kuleßa on 23.02.22.
//

@testable import CovPassCommon

import Foundation
import XCTest

class CertificateListTests: XCTestCase {
    func testCertificatePairs_empty() {
        // Given
        let sut = CertificateList(certificates: [])

        // When
        let pairs = sut.certificatePairs

        // Then
        XCTAssertTrue(pairs.isEmpty)
    }

    func testCertificatePairs_same() {
        // Given
        let certificates: [ExtendedCBORWebToken] = [
            CBORWebToken.mockVaccinationCertificate.extended(),
            CBORWebToken.mockTestCertificate.extended(),
            CBORWebToken.mockRecoveryCertificate.extended(),
        ]
        let sut = CertificateList(certificates: certificates)

        // When
        let pairs = sut.certificatePairs

        // Then
        XCTAssertEqual(pairs.count, 1)
    }

    func testCertificatePairs_different() {
        // Given
        let certificates: [ExtendedCBORWebToken] = [
            CBORWebToken.mockVaccinationCertificate.extended(),
            CBORWebToken.mockVaccinationCertificateWithOtherName.extended()
        ]
        let sut = CertificateList(certificates: certificates)

        // When
        let pairs = sut.certificatePairs

        // Then
        XCTAssertEqual(pairs.count, 2)
    }
}
