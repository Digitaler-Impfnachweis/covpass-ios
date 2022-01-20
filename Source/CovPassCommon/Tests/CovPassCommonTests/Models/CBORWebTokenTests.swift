//
//  ExtendedVaccinationTests.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCommon

import Foundation
import XCTest

class ExtendedVaccinationTests: XCTestCase {
    func testDecoding() {
        let jsonData = Data.json("CBORWebToken")
        let sut = try! JSONDecoder().decode(CBORWebToken.self, from: jsonData)

        XCTAssertEqual(sut.iss, "DE")
        XCTAssertEqual(sut.iat?.timeIntervalSince1970, 1_619_167_131)
        XCTAssertEqual(sut.exp?.timeIntervalSince1970, 1_682_239_131)
        XCTAssertEqual(sut.hcert.dgc.ver, "1.0.0")
    }
    
    func testIsVaccination() {
        let certificate = CBORWebToken.mockVaccinationCertificate.extended(vaccinationQRCodeData: "")
        XCTAssertTrue(certificate.vaccinationCertificate.isVaccination)
        XCTAssertFalse(certificate.vaccinationCertificate.isNotVaccination)
        XCTAssertFalse(certificate.vaccinationCertificate.isRecovery)
        XCTAssertFalse(certificate.vaccinationCertificate.isTest)
    }
    
    func testIsTest() {
        let certificate = CBORWebToken.mockTestCertificate.extended(vaccinationQRCodeData: "")
        XCTAssertFalse(certificate.vaccinationCertificate.isVaccination)
        XCTAssertFalse(certificate.vaccinationCertificate.isRecovery)
        XCTAssertFalse(certificate.vaccinationCertificate.isNotTest)
        XCTAssertTrue(certificate.vaccinationCertificate.isTest)
    }
    
    func testIsRecovery() {
        let certificate = CBORWebToken.mockRecoveryCertificate.extended(vaccinationQRCodeData: "")
        XCTAssertFalse(certificate.vaccinationCertificate.isVaccination)
        XCTAssertFalse(certificate.vaccinationCertificate.isTest)
        XCTAssertFalse(certificate.vaccinationCertificate.isNotRecovery)
        XCTAssertTrue(certificate.vaccinationCertificate.isRecovery)
    }
    
    func testIsNotFraud() {
        let certificate = CBORWebToken.mockVaccinationCertificate.extended(vaccinationQRCodeData: "")
        XCTAssertFalse(certificate.vaccinationCertificate.isFraud)
    }
}
