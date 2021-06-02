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
    func testParseCert1() {
        do {
            let res = try QRCoder.parse(CertificateMock.cert1).wait()
            _ = try res.payloadJsonData()
        } catch {
            XCTFail("Parse should succeed")
        }
    }

    func testParseValidCertificate() {
        do {
            let res = try QRCoder.parse(CertificateMock.validCertificate).wait()
            _ = try res.payloadJsonData()
        } catch {
            XCTFail("Parse should succeed")
        }
    }

    func testParseValidCertificateWithNoPrefix() {
        do {
            let res = try QRCoder.parse(CertificateMock.validCertificateNoPrefix).wait()
            _ = try res.payloadJsonData()
        } catch {
            XCTFail("Parse should succeed")
        }
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
