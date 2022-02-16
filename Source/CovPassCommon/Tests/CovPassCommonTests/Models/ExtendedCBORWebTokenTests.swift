//
//  ExtendedCBORWebTokenTests.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import XCTest

@testable import CovPassCommon

class ExtendedCBORWebTokenTests: XCTestCase {
    let sut1 = [
        CBORWebToken.mockVaccinationCertificate.mockName(Name(fnt: "foo")).extended(),
        CBORWebToken.mockVaccinationCertificate.mockName(Name(fnt: "foo")).extended(),
        CBORWebToken.mockVaccinationCertificate.mockName(Name(fnt: "bar")).extended(),
    ]

    let sut2 = [
        CBORWebToken.mockVaccinationCertificate.mockName(Name(fnt: "foo")).extended(),
        CBORWebToken.mockVaccinationCertificate.mockName(Name(fnt: "foo")).extended(),
    ]

    func testCertificatePair() {
        XCTAssertEqual(sut1.certificatePair(for: CBORWebToken.mockVaccinationCertificate.mockName(Name(fnt: "foo")).extended()).count, 2)
        XCTAssertEqual(sut1.certificatePair(for: CBORWebToken.mockVaccinationCertificate.mockName(Name(fnt: "bar")).extended()).count, 1)
        XCTAssertEqual(sut2.certificatePair(for: CBORWebToken.mockVaccinationCertificate.mockName(Name(fnt: "bar")).extended()).count, 0)

        let emptyArray = [ExtendedCBORWebToken]()
        XCTAssertEqual(emptyArray.count, 0)
    }
}
