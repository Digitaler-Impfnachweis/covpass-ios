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
    var service: APIServiceMock!
    var keychain: MockPersistence!
    var userDefaults: MockPersistence!
    var sut: VaccinationRepository!

    override func setUp() {
        super.setUp()
        service = APIServiceMock()
        keychain = MockPersistence()
        userDefaults = MockPersistence()
        let trustListURL = Bundle.commonBundle.url(forResource: "dsc.json", withExtension: nil)!
        sut = VaccinationRepository(
            service: service,
            keychain: keychain,
            userDefaults: userDefaults,
            publicKeyURL: Bundle.module.url(forResource: "pubkey.pem", withExtension: nil)!,
            initialDataURL: trustListURL
        )
    }

    override func tearDown() {
        service = nil
        keychain = nil
        userDefaults = nil
        sut = nil
        super.tearDown()
    }

    func testErrorCode() {
        XCTAssertEqual(CertificateError.positiveResult.errorCode, 421)
        XCTAssertEqual(CertificateError.expiredCertifcate.errorCode, 422)
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

//    func testCheckCertificateInvalidSignature() {
//        do {
//            _ = try sut.checkCertificate(CertificateMock.invalidCertificateInvalidSignature).wait()
//            XCTFail("Check should fail")
//        } catch {
//            XCTAssertEqual(error.localizedDescription, HCertError.verifyError.localizedDescription)
//        }
//    }

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

    func testLastUpdatedTrustList() throws {
        XCTAssertNil(sut.getLastUpdatedTrustList())

        let date = Date()
        try userDefaults.store(UserDefaults.keyLastUpdatedTrustList, value: date)

        XCTAssertEqual(sut.getLastUpdatedTrustList(), date)
    }

    func testGetCertificateList() throws {
        // Store one certficate in list
        let data = try JSONEncoder().encode(
            CertificateList(
                certificates: [
                    ExtendedCBORWebToken(
                        vaccinationCertificate: try JSONDecoder().decode(CBORWebToken.self, from: Data.json("CBORWebToken")),
                        vaccinationQRCodeData: CertificateMock.validCertificate
                    )
                ],
                favoriteCertificateId: "1"
            )
        )
        try keychain.store(KeychainPersistence.certificateListKey, value: data)

        // Get certificate list
        let list = try sut.getCertificateList().wait()

        XCTAssertEqual(list.favoriteCertificateId, "1")
        XCTAssertEqual(list.certificates.first?.vaccinationCertificate.isInvalid, false)
    }

//    func testGetCertificateListWithInvalidation() throws {
//        // Store one certficate in list
//        let data = try JSONEncoder().encode(
//            CertificateList(
//                certificates: [
//                    ExtendedCBORWebToken(
//                        vaccinationCertificate: try JSONDecoder().decode(CBORWebToken.self, from: Data.json("CBORWebToken")),
//                        vaccinationQRCodeData: CertificateMock.invalidCertificateInvalidSignature
//                    )
//                ],
//                favoriteCertificateId: "1"
//            )
//        )
//        try keychain.store(KeychainPersistence.certificateListKey, value: data)
//
//        // Get certificate list
//        let list = try sut.getCertificateList().wait()
//
//        XCTAssertEqual(list.favoriteCertificateId, "1")
//        XCTAssertEqual(list.certificates.first?.vaccinationCertificate.isInvalid, true)
//    }

    func testGetCertificateListFailsWithWrongData() throws {
        try keychain.store(KeychainPersistence.certificateListKey, value: CertificateList(certificates: [], favoriteCertificateId: "1"))

        let list = try sut.getCertificateList().wait()
        XCTAssertNil(list.favoriteCertificateId)
    }

    func testGetCertificateListFails() {
        do {
            keychain.fetchError = ApplicationError.unknownError
            _ = try sut.getCertificateList().wait()
            XCTFail("Should fail")
        } catch {
            XCTAssertEqual(error.localizedDescription, ApplicationError.unknownError.localizedDescription)
        }
    }

    func testSaveCertificateList() throws {
        _ = try sut.saveCertificateList(CertificateList(certificates: [], favoriteCertificateId: "1")).wait()
    }

    func testSaveCertificateListFails() throws {
        do {
            keychain.storeError = ApplicationError.unknownError
            _ = try sut.saveCertificateList(CertificateList(certificates: [], favoriteCertificateId: "1")).wait()
            XCTFail("Should fail")
        } catch {
            XCTAssertEqual(error.localizedDescription, ApplicationError.unknownError.localizedDescription)
        }
    }

    func testDeleteCertificate() throws {
        let cborWebToken = try! JSONDecoder().decode(CBORWebToken.self, from: Data.json("CBORWebToken"))
        let cert = ExtendedCBORWebToken(vaccinationCertificate: cborWebToken, vaccinationQRCodeData: "")
        _ = try sut.saveCertificateList(CertificateList(certificates: [cert], favoriteCertificateId: cborWebToken.hcert.dgc.uvci)).wait()

        var list = try sut.getCertificateList().wait()
        XCTAssertEqual(list.certificates.count, 1)
        XCTAssertEqual(list.favoriteCertificateId, cborWebToken.hcert.dgc.uvci)

        _ = try sut.delete(cert).wait()

        list = try sut.getCertificateList().wait()
        XCTAssertEqual(list.certificates.count, 0)
        XCTAssertNil(list.favoriteCertificateId)
    }

    func testCheckCertificate() throws {
        let token = try sut.checkCertificate(CertificateMock.validCertificate).wait()
        XCTAssertEqual(token.hcert.dgc.uvci, "01DE/00100/1119349007/F4G7014KQQ2XD0NY8FJHSTDXZ#S")
    }

    func testCheckCertificateFails() {
        do {
            _ = try sut.checkCertificate(CertificateMock.invalidCertificate).wait()
            XCTFail("Should fail")
        } catch {
            XCTAssertEqual(error.localizedDescription, CoseParsingError.wrongType.localizedDescription)
        }
    }

    func testToogleFavoriteState() throws {
        var list = try sut.getCertificateList().wait()
        XCTAssertNil(list.favoriteCertificateId)

        let res = try sut.toggleFavoriteStateForCertificateWithIdentifier("01DE/00100/1119349007/F4G7014KQQ2XD0NY8FJHSTDXZ#S").wait()
        XCTAssert(res)

        list = try sut.getCertificateList().wait()
        XCTAssertEqual(list.favoriteCertificateId, "01DE/00100/1119349007/F4G7014KQQ2XD0NY8FJHSTDXZ#S")
    }

    func testFavoriteStateForCertificates() throws {
        let cborWebToken = try! JSONDecoder().decode(CBORWebToken.self, from: Data.json("CBORWebToken"))
        let cert = ExtendedCBORWebToken(vaccinationCertificate: cborWebToken, vaccinationQRCodeData: "")
        _ = try sut.saveCertificateList(CertificateList(certificates: [cert])).wait()

        var res = try sut.favoriteStateForCertificates([cert]).wait()
        XCTAssertFalse(res)

        res = try sut.toggleFavoriteStateForCertificateWithIdentifier("01DE/84503/1119349007/DXSGWLWL40SU8ZFKIYIBK39A3#S").wait()
        XCTAssert(res)

        res = try sut.favoriteStateForCertificates([cert]).wait()
        XCTAssert(res)
    }

    func testMatchedCertificates() throws {
        let cert1 = ExtendedCBORWebToken(
            vaccinationCertificate: try! JSONDecoder().decode(CBORWebToken.self, from: Data.json("CBORWebToken")),
            vaccinationQRCodeData: ""
        )
        let cert2 = ExtendedCBORWebToken(
            vaccinationCertificate: try! JSONDecoder().decode(CBORWebToken.self, from: Data.json("CBORWebToken")),
            vaccinationQRCodeData: ""
        )
        let list = CertificateList(certificates: [cert1, cert2])

        let res = sut.matchedCertificates(for: list)
        XCTAssertEqual(res.count, 1)
        XCTAssertEqual(res.first?.certificates.count, 2)
    }

    func testMatchedCertificatesDifferentPeople() throws {
        let cert1 = ExtendedCBORWebToken(
            vaccinationCertificate: try! JSONDecoder().decode(CBORWebToken.self, from: Data.json("CBORWebToken")),
            vaccinationQRCodeData: ""
        )
        var token = try! JSONDecoder().decode(CBORWebToken.self, from: Data.json("CBORWebToken"))
        token.hcert.dgc.dob = Date()
        let cert2 = ExtendedCBORWebToken(
            vaccinationCertificate: token,
            vaccinationQRCodeData: ""
        )
        let list = CertificateList(certificates: [cert1, cert2])

        let res = sut.matchedCertificates(for: list)
        XCTAssertEqual(res.count, 2)
        XCTAssertEqual(res.first?.certificates.count, 1)
    }

    func testScanCertificate() throws {
        let token = try sut.scanCertificate(CertificateMock.validCertificate).wait()
        XCTAssertEqual(token.vaccinationCertificate.hcert.dgc.uvci, "01DE/00100/1119349007/F4G7014KQQ2XD0NY8FJHSTDXZ#S")
    }

    func testScanCertificateFailsPositive() {
        do {
            let positivePCRTest = "HC1:6BFOXN*TS0BI$ZD8UHYK1EBQZWG8W4:D4WGF-36OLNAOMIZ4WYHZKCML94HK4XPQHIZC4.OI:OI4V2*LP8W2GHKW/F3IKJ5QH*AF/GJ5MQ0KS1OK.GZ/8V5P%C4CAW+DG$$02-7%KSSDCWEGNY0/-9RQPYE9/MVSYSOH6PO9:TUQJAJG9-*NIRICVELZUZM9EN9-O9FNHZO9HQ1*P1MX1+ZE$S9$R1YXL5Q1M35AHLRIN$S4IFN5F599M+BLA4BB%V%3NKQ777IT$M0QIRR97I2HOAXL92L0A KDNKBK4CJ0JQE6H0:WO$NI Q1610AJ27K2FVIP$I/XK$M8X64XDOXCR$35L/5R3FMIA4/B 3ELEE$JD/.D%-B9JAW/BT3E3Z84JBSD9Z3E8AE-QD89MT6KBLEH-BNQMWOCNKE$JDVPLZ2KD0KCZG/WR-RIR.8DZF+:247F./N WBJ JMABA4N$Y55JS+%QOC9H.19CTT595URS9W7 6 VI/U2 PTNZ56 PTS5N*JP.61KJ618S:1*KICQIDGGV+F"
            _ = try sut.scanCertificate(positivePCRTest).wait()
            XCTFail("Should fail")
        } catch {
            XCTAssertEqual(error.localizedDescription, CertificateError.positiveResult.localizedDescription)
        }
    }

    func testScanCertificateFailsExistingQRCode() {
        do {
            _ = try sut.scanCertificate(CertificateMock.validCertificate).wait()
            _ = try sut.scanCertificate(CertificateMock.validCertificate).wait()
            XCTFail("Should fail")
        } catch {
            XCTAssertEqual(error.localizedDescription, QRCodeError.qrCodeExists.localizedDescription)
        }
    }

    func testUpdateTrustList() throws {
        service.trustListResult = Promise.value(String(data: Data.json("dsc-with-signature"), encoding: .utf8)!)
        _ = try sut.updateTrustList().wait()
    }

    func testUpdateTrustListWithWrongNoSignature() {
        do {
            service.trustListResult = Promise.value(String(data: Data.json("dsc"), encoding: .utf8)!)
            _ = try sut.updateTrustList().wait()
            XCTFail("Should fail")
        } catch {
            XCTAssertEqual(error.localizedDescription, HCertError.verifyError.localizedDescription)
        }
    }
}
