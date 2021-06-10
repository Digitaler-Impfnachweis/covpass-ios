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

    func testcheckCertificateValidEC() throws {
        let res = try sut.checkCertificate(CertificateMock.validCertificate).wait()
        XCTAssertEqual(res.iss, "DE")
    }

    func testcheckCertificateValidRSA() throws {
        let res = try sut.checkCertificate(CertificateMock.validCertifcateRSA).wait()
        XCTAssertEqual(res.iss, "IS")
    }

    func testcheckCertificateInvalidSignature() {
        do {
            _ = try sut.checkCertificate(CertificateMock.invalidCertificateInvalidSignature).wait()
            XCTFail("Check should fail")
        } catch {
            XCTAssertEqual(error.localizedDescription, HCertError.verifyError.localizedDescription)
        }
    }
}
