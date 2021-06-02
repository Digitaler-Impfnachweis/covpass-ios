//
//  VaccinationRepositoryTests.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import XCTest
import PromiseKit

@testable import CovPassCommon

class VaccinationRepositoryTests: XCTestCase {
    var sut: VaccinationRepository!

    override func setUp() {
        super.setUp()
        sut = VaccinationRepository(service: APIServiceMock(), publicKeyURL: URL(fileURLWithPath: "pubkey.pem"), initialDataURL: URL(fileURLWithPath: "dsc.json"))
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testCert() {
        do {
            let res = try sut.checkVaccinationCertificate(CertificateMock.validCertificate).wait()
            XCTAssertEqual(res.iss, "DE")
        } catch {
            XCTFail("Check should succeed")
        }
    }
//
//    func testCheckCertificate() {
//        do {
//            let res = try sut.checkVaccinationCertificate(<#T##data: String##String#>)(CertificateMock.validCertificate).wait()
//            XCTAssertEqual(res.vaccinationCertificate.iss, "DE")
//        } catch {
//            XCTFail("Parse should succeed")
//        }
//    }

//    func testCheckCertificate() {
//        do {
//            let res = try sut.checkVaccinationCertificate(CertificateMock.validCertificate).wait()
//            XCTAssertEqual(res.iss, "DE")
//        } catch {
//            XCTFail("Parse should succeed")
//        }
//    }

//    func testParseValidCertificate() {
//        do {
//            let res = try QRCoder.parse(CertificateMock.validCertificate).wait()
//            _ = try res.payloadJsonData()
//        } catch {
//            XCTFail("Parse should succeed")
//        }
//    }
//
//    func testParseValidCertificateWithNoPrefix() {
//        do {
//            let res = try QRCoder.parse(CertificateMock.validCertificateNoPrefix).wait()
//            _ = try res.payloadJsonData()
//        } catch {
//            XCTFail("Parse should succeed")
//        }
//    }
//
//    func testParseInvalidCertificate() {
//        do {
//            _ = try QRCoder.parse(CertificateMock.invalidCertificate).wait()
//            XCTFail("Parse should fail")
//        } catch {
//            XCTAssertEqual(error.localizedDescription, CoseParsingError.wrongType.localizedDescription)
//        }
//    }
}
