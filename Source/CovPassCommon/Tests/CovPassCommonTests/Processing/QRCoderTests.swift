//
//  QRCoderTests.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import XCTest

@testable import CovPassCommon

class QRCoderTests: XCTestCase {
    func testParseValidCertificate() throws {
        let res = try QRCoder.parse(CertificateMock.validCertificate).wait()
        _ = try res.payloadJsonData()
    }

    func testParseValidCertificateRSA() throws {
        let res = try QRCoder.parse(CertificateMock.validCertifcateRSA).wait()
        _ = try res.payloadJsonData()
    }

    func testParseValidCertificateWithNoPrefix() throws {
        let res = try QRCoder.parse(CertificateMock.validCertificateNoPrefix).wait()
        _ = try res.payloadJsonData()
    }

    func testParseInvalidCertificate() {
        do {
            _ = try QRCoder.parse(CertificateMock.invalidCertificate).wait()
            XCTFail("Parse should fail")
        } catch {
            XCTAssertEqual(error.localizedDescription, CoseParsingError.wrongType.localizedDescription)
        }
    }
}
