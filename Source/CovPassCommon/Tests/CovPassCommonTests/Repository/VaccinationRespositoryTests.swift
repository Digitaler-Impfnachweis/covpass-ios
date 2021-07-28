//
//  VaccinationRepositoryTests.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import PromiseKit
import XCTest

@testable import CovPassCommon

class VaccinationRepositoryTests: XCTestCase {
    var sut: VaccinationRepository!

    override func setUp() {
        super.setUp()

        let trustListURL = Bundle.commonBundle.url(forResource: "dsc.json", withExtension: nil)!
        sut = VaccinationRepository(service: APIServiceMock(), keychain: MockPersistence(), userDefaults: MockPersistence(), publicKeyURL: URL(fileURLWithPath: "pubkey.pem"), initialDataURL: trustListURL)
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testCheckCertificateValidExtendedKeyUsage() throws {
        let res = try sut.checkCertificate(CertificateMock.validExtendedKeyUsageGreece).wait()
        XCTAssertEqual(res.iss, "GR")
    }

    func testCheckCertificateInvalidExtendedKeyUsage() {
        do {
            _ = try sut.checkCertificate(CertificateMock.invalidExtendedKeyUsagePoland).wait()
            XCTFail("test should fail")
        } catch {
            XCTAssertEqual(error.localizedDescription, HCertError.illegalKeyUsage.localizedDescription)
        }
    }

    func testCheckCertificateValidEC() throws {
        let res = try sut.checkCertificate(CertificateMock.validCertificate).wait()
        XCTAssertEqual(res.iss, "DE")
    }

    func testCheckCertificateValidRSA() throws {
        // FIXME: Refactor repository to mock the date that is being used to check the expiration time
//        let res = try sut.checkCertificate(CertificateMock.validCertifcateRSA).wait()
//        XCTAssertEqual(res.iss, "IS")
    }

    func testCheckCertificateInvalidSignature() {
        do {
            _ = try sut.checkCertificate(CertificateMock.invalidCertificateInvalidSignature).wait()
            XCTFail("Check should fail")
        } catch {
            XCTAssertEqual(error.localizedDescription, HCertError.verifyError.localizedDescription)
        }
    }

    func testCheckCertificateInvalidEntity() {
        do {
            let res = try sut.checkCertificate(CertificateMock.validCertificate).wait()
            res.hcert.dgc.v?.first?.ci = "URN:UVCI:01DE/foobar/F4G7014KQQ2XD0NY8FJHSTDXZ#S"

            try sut.validateEntity(res)
            XCTFail("Should fail")
        } catch {
            XCTAssertEqual(error.localizedDescription, CertificateError.invalidEntity.localizedDescription)
        }
    }
}
