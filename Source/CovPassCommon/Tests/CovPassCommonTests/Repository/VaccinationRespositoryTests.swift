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
    var boosterLogic: BoosterLogicMock!
    var sut: VaccinationRepository!

    override func setUp() {
        super.setUp()
        service = APIServiceMock()
        keychain = MockPersistence()
        userDefaults = MockPersistence()
        boosterLogic = BoosterLogicMock()
        let trustListURL = Bundle.commonBundle.url(forResource: "dsc.json", withExtension: nil)!
        sut = VaccinationRepository(
            service: service,
            keychain: keychain,
            userDefaults: userDefaults,
            boosterLogic: boosterLogic,
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
        XCTAssertEqual(CertificateError.invalidEntity.errorCode, 423)
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

//    func testCheckCertificateValidRSA() throws {
//        // FIXME: Refactor repository to mock the date that is being used to check the expiration time
//        let res = try sut.checkCertificate(CertificateMock.validCertifcateRSA).wait()
//        XCTAssertEqual(res.iss, "IS")
//    }

//    func testCheckCertificateInvalidSignature() {
//        do {
//            _ = try sut.checkCertificate(CertificateMock.invalidCertificateInvalidSignature).wait()
//            XCTFail("Check should fail")
//        } catch {
//            XCTAssertEqual(error.localizedDescription, HCertError.verifyError.localizedDescription)
//        }
//    }

    func testValidateEntityValidRecoveryCertificate() {
        do {
            let res = try sut.checkCertificate(CertificateMock.validRecoveryCertificate).wait()
            XCTAssertNoThrow(try sut.validateEntity(res))
        } catch {
            XCTFail("Should fail")
        }
    }
    
    func testValidateEntityValidCertificateNoPrefix() {
        do {
            let res = try sut.checkCertificate(CertificateMock.validCertificateNoPrefix).wait()
            XCTAssertNoThrow(try sut.validateEntity(res))
        } catch {
            XCTFail("Should fail")
        }
    }
    
    func testValidateEntityValidExtendedKeyUsageGreece() {
        do {
            let res = try sut.checkCertificate(CertificateMock.validExtendedKeyUsageGreece).wait()
            XCTAssertNoThrow(try sut.validateEntity(res))
        } catch {
            XCTFail("Should fail")
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

    func testValidateEntityInvalidCertificateInvalidSignature() {
        do {
            let res = try sut.checkCertificate(CertificateMock.invalidCertificateInvalidSignature).wait()
            try sut.validateEntity(res)
            XCTFail("Should fail")
        } catch {
            XCTAssertEqual(error.localizedDescription, CertificateError.expiredCertifcate.localizedDescription)
        }
    }
    
    func testValidateEntityInvalidCertificate() {
        do {
            let res = try sut.checkCertificate(CertificateMock.invalidCertificate).wait()
            try sut.validateEntity(res)
            XCTFail("Should fail")
        } catch {
            XCTAssertEqual(error.localizedDescription, CoseParsingError.wrongType.localizedDescription)
        }
    }
    
    func testValidateEntityInvalidCertificateOldFormat() {
        do {
            let res = try sut.checkCertificate(CertificateMock.invalidCertificateOldFormat).wait()
            try sut.validateEntity(res)
            XCTFail("Should fail")
        } catch {
            print(error)
            XCTAssertEqual(error.localizedDescription, "The data couldn’t be read because it is missing.")
        }
    }
    
    func testValidateEntityInvalidExtendedKeyUsagePoland() {
        do {
            let res = try sut.checkCertificate(CertificateMock.invalidExtendedKeyUsagePoland).wait()
            try sut.validateEntity(res)
            XCTFail("Should fail")
        } catch {
            print(error)
            XCTAssertEqual(error.localizedDescription, HCertError.illegalKeyUsage.localizedDescription)
        }
    }
    
    func testValidateEntityValidCertifcateRSA() {
        do {
            let res = try sut.checkCertificate(CertificateMock.validCertifcateRSA).wait()
            try sut.validateEntity(res)
            XCTFail("Should fail")
        } catch {
            print(error)
            XCTAssertEqual(error.localizedDescription, CertificateError.expiredCertifcate.localizedDescription)
        }
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
        try keychain.store(KeychainPersistence.Keys.certificateList.rawValue, value: data)

        // Get certificate list
        let list = try sut.getCertificateList().wait()

        XCTAssertEqual(list.favoriteCertificateId, "1")
        XCTAssertEqual(list.certificates.first?.vaccinationCertificate.isInvalid, false)
    }

    func testGetCertificateListWithInvalidation() throws {
        // Store one certficate in list
        let data = try JSONEncoder().encode(
            CertificateList(
                certificates: [
                    ExtendedCBORWebToken(
                        vaccinationCertificate: try JSONDecoder().decode(CBORWebToken.self, from: Data.json("CBORWebToken")),
                        vaccinationQRCodeData: CertificateMock.invalidCertificateInvalidSignature
                    )
                ],
                favoriteCertificateId: "1"
            )
        )
        try keychain.store(KeychainPersistence.Keys.certificateList.rawValue, value: data)

        // Get certificate list
        let list = try sut.getCertificateList().wait()

        XCTAssertEqual(list.favoriteCertificateId, "1")
        XCTAssertEqual(list.certificates.first?.vaccinationCertificate.isInvalid, true)
    }

    func testGetCertificateListFailsWithWrongData() throws {
        try keychain.store(KeychainPersistence.Keys.certificateList.rawValue, value: CertificateList(certificates: [], favoriteCertificateId: "1"))

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
        let cborWebToken = CBORWebToken.mockVaccinationCertificate
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

    func testDeleteCertificateWithBooster() throws {
        let cborWebToken = CBORWebToken.mockVaccinationCertificate
        let cert = ExtendedCBORWebToken(vaccinationCertificate: cborWebToken, vaccinationQRCodeData: "")

        // existing booster notification should be deleted when certificate gets deleted
        boosterLogic.updateBoosterCandidate(BoosterCandidate(certificate: cert))

        _ = try sut.saveCertificateList(CertificateList(certificates: [cert], favoriteCertificateId: cborWebToken.hcert.dgc.uvci)).wait()

        var list = try sut.getCertificateList().wait()
        XCTAssertEqual(list.certificates.count, 1)
        XCTAssertEqual(boosterLogic.boosterCandidates.count, 1)

        _ = try sut.delete(cert).wait()

        list = try sut.getCertificateList().wait()
        XCTAssertEqual(list.certificates.count, 0)
        XCTAssertEqual(boosterLogic.boosterCandidates.count, 0)
    }

    func testDeleteCertificateWithDifferentBooster() throws {
        let cborWebToken = CBORWebToken.mockVaccinationCertificate
        let cert = ExtendedCBORWebToken(vaccinationCertificate: cborWebToken, vaccinationQRCodeData: "")

        // other booster notifications should stay when certificate gets deleted
        boosterLogic.updateBoosterCandidate(BoosterCandidate(certificate: ExtendedCBORWebToken(vaccinationCertificate: CBORWebToken.mockVaccinationCertificate.mockVaccinationUVCI("foo"), vaccinationQRCodeData: "")))

        _ = try sut.saveCertificateList(CertificateList(certificates: [cert], favoriteCertificateId: cborWebToken.hcert.dgc.uvci)).wait()

        var list = try sut.getCertificateList().wait()
        XCTAssertEqual(list.certificates.count, 1)
        XCTAssertEqual(boosterLogic.boosterCandidates.count, 1)

        _ = try sut.delete(cert).wait()

        list = try sut.getCertificateList().wait()
        XCTAssertEqual(list.certificates.count, 0)
        XCTAssertEqual(boosterLogic.boosterCandidates.count, 1)
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
    
    func testSetExpiryAlert() throws {
        let cborWebToken = try! JSONDecoder().decode(CBORWebToken.self, from: Data.json("CBORWebToken"))
        let cert = ExtendedCBORWebToken(vaccinationCertificate: cborWebToken, vaccinationQRCodeData: "")
        _ = try sut.saveCertificateList(CertificateList(certificates: [cert])).wait()

        // Get certificate list
        var list = try sut.getCertificateList().wait()

        // Get the first Token
        var token = try XCTUnwrap(list.certificates.first)
        XCTAssertNil(token.wasExpiryAlertShown)
        // set that the expiry alert view is shown for this token
        _ = try sut.setExpiryAlert(shown: true, token: token).wait()

        // Get the list and check if the was expiry bool was shown is saved
        list = try sut.getCertificateList().wait()
        token = try XCTUnwrap(list.certificates.first)

        XCTAssertNotNil(token.wasExpiryAlertShown)
        XCTAssertTrue(try XCTUnwrap(token.wasExpiryAlertShown))
    }
    
    func testSetReissueAlreadySeenInitialAndNewBadgeAlreadySeen() throws {
        // GIVEN
        let cborWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        _ = try sut.saveCertificateList(CertificateList(certificates: [cborWebToken])).wait()
        var list = try sut.getCertificateList().wait()
        var token = try XCTUnwrap(list.certificates.first)
        
        // WHEN
        _ = try sut.setReissueProcess(initialAlreadySeen: true, newBadgeAlreadySeen: false, tokens: [cborWebToken]).wait()

        // THEN
        list = try sut.getCertificateList().wait()
        token = try XCTUnwrap(list.certificates.first)
        XCTAssertTrue(try XCTUnwrap(token.reissueProcessInitialAlreadySeen))
        XCTAssertFalse(try XCTUnwrap(token.reissueProcessNewBadgeAlreadySeen))
    }
    
    func testSetReissueAlreadySeenInitialAndNewBadgeAlreadySeenAlternative() throws {
        // GIVEN
        let expectationTest = XCTestExpectation()
        let cborWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        _ = try sut.saveCertificateList(CertificateList(certificates: [cborWebToken])).wait()
        sut.getCertificateList().done { list in
            var token = try XCTUnwrap(list.certificates.first)
            
            // WHEN
            _ = try self.sut.setReissueProcess(initialAlreadySeen: false, newBadgeAlreadySeen: true, tokens: [cborWebToken]).wait()

            // THEN
            self.sut.getCertificateList().done{ list in
                token = try XCTUnwrap(list.certificates.first)
                XCTAssertFalse(try XCTUnwrap(token.reissueProcessInitialAlreadySeen))
                XCTAssertTrue(try XCTUnwrap(token.reissueProcessNewBadgeAlreadySeen))
                expectationTest.fulfill()
            }.cauterize()
        }.cauterize()
        wait(for: [expectationTest], timeout: 1.0)
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
        let token = try sut.scanCertificate(CertificateMock.validCertificate, isCountRuleEnabled: true).wait()
        XCTAssertEqual((token as! ExtendedCBORWebToken).vaccinationCertificate.hcert.dgc.uvci, "01DE/00100/1119349007/F4G7014KQQ2XD0NY8FJHSTDXZ#S")
    }

    func testScanCertificateFailsPositive() {
        do {
            let positivePCRTest = "HC1:6BFOXN*TS0BI$ZD8UHYK1EBQZWG8W4:D4WGF-36OLNAOMIZ4WYHZKCML94HK4XPQHIZC4.OI:OI4V2*LP8W2GHKW/F3IKJ5QH*AF/GJ5MQ0KS1OK.GZ/8V5P%C4CAW+DG$$02-7%KSSDCWEGNY0/-9RQPYE9/MVSYSOH6PO9:TUQJAJG9-*NIRICVELZUZM9EN9-O9FNHZO9HQ1*P1MX1+ZE$S9$R1YXL5Q1M35AHLRIN$S4IFN5F599M+BLA4BB%V%3NKQ777IT$M0QIRR97I2HOAXL92L0A KDNKBK4CJ0JQE6H0:WO$NI Q1610AJ27K2FVIP$I/XK$M8X64XDOXCR$35L/5R3FMIA4/B 3ELEE$JD/.D%-B9JAW/BT3E3Z84JBSD9Z3E8AE-QD89MT6KBLEH-BNQMWOCNKE$JDVPLZ2KD0KCZG/WR-RIR.8DZF+:247F./N WBJ JMABA4N$Y55JS+%QOC9H.19CTT595URS9W7 6 VI/U2 PTNZ56 PTS5N*JP.61KJ618S:1*KICQIDGGV+F"
            _ = try sut.scanCertificate(positivePCRTest, isCountRuleEnabled: true).wait()
            XCTFail("Should fail")
        } catch {
            XCTAssertEqual(error.localizedDescription, CertificateError.positiveResult.localizedDescription)
        }
    }

    func testScanCertificateFailsExistingQRCode() {
        do {
            _ = try sut.scanCertificate(CertificateMock.validCertificate, isCountRuleEnabled: true).wait()
            _ = try sut.scanCertificate(CertificateMock.validCertificate, isCountRuleEnabled: true).wait()
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
    
    func testCountRule_Enabled_WithDifferentPersons2() {
        
        let validCert1 = CertificateMock.validCertificate
        let validCert2 = CertificateMock.validRecoveryCertificate

        do {
            _ = try sut.scanCertificate(validCert1, isCountRuleEnabled: true).wait()
            _ = try sut.scanCertificate(validCert2, isCountRuleEnabled: true).wait()
            XCTFail("Should fail")
        } catch {
            XCTAssertEqual(error.localizedDescription, QRCodeError.warningCountOfCertificates.localizedDescription)
        }
    }
    
    func testCountRule_Disabled_WithDifferentPersons2() throws {
        let validCert1 = CertificateMock.validCertificate
        let validCert2 = CertificateMock.validRecoveryCertificate
        _ = try sut.scanCertificate(validCert1, isCountRuleEnabled: true).wait()
        _ = try sut.scanCertificate(validCert2, isCountRuleEnabled: false).wait()
    }
    
    func testCountRule_Enabled_10TimesSamePerson() {
        let validCert1 = CertificateMock.validCertificate
        let validCert2 = CertificateMock.validCertificate.appending("B")
        let validCert3 = CertificateMock.validCertificate.appending("C")
        let validCert4 = CertificateMock.validCertificate.appending("D")
        let validCert5 = CertificateMock.validCertificate.appending("E")
        let validCert6 = CertificateMock.validCertificate.appending("F")
        let validCert7 = CertificateMock.validCertificate.appending("G")
        let validCert8 = CertificateMock.validCertificate.appending("H")
        let validCert9 = CertificateMock.validCertificate.appending("I")
        let validCert10 = CertificateMock.validCertificate.appending("J")

        do {
            _ = try sut.scanCertificate(validCert1, isCountRuleEnabled: true).wait()
            _ = try sut.scanCertificate(validCert2, isCountRuleEnabled: true).wait()
            _ = try sut.scanCertificate(validCert3, isCountRuleEnabled: true).wait()
            _ = try sut.scanCertificate(validCert4, isCountRuleEnabled: true).wait()
            _ = try sut.scanCertificate(validCert5, isCountRuleEnabled: true).wait()
            _ = try sut.scanCertificate(validCert6, isCountRuleEnabled: true).wait()
            _ = try sut.scanCertificate(validCert7, isCountRuleEnabled: true).wait()
            _ = try sut.scanCertificate(validCert8, isCountRuleEnabled: true).wait()
            _ = try sut.scanCertificate(validCert9, isCountRuleEnabled: true).wait()
            _ = try sut.scanCertificate(validCert10, isCountRuleEnabled: true).wait()
            XCTAssert(true)
        } catch {
            XCTFail("Should fail")
        }
    }
    
    func testCountRule_Disabled_10TimesSamePerson() {
        let validCert1 = CertificateMock.validCertificate
        let validCert2 = CertificateMock.validCertificate.appending("B")
        let validCert3 = CertificateMock.validCertificate.appending("C")
        let validCert4 = CertificateMock.validCertificate.appending("D")
        let validCert5 = CertificateMock.validCertificate.appending("E")
        let validCert6 = CertificateMock.validCertificate.appending("F")
        let validCert7 = CertificateMock.validCertificate.appending("G")
        let validCert8 = CertificateMock.validCertificate.appending("H")
        let validCert9 = CertificateMock.validCertificate.appending("I")
        let validCert10 = CertificateMock.validCertificate.appending("J")

        do {
            _ = try sut.scanCertificate(validCert1, isCountRuleEnabled: false).wait()
            _ = try sut.scanCertificate(validCert2, isCountRuleEnabled: false).wait()
            _ = try sut.scanCertificate(validCert3, isCountRuleEnabled: false).wait()
            _ = try sut.scanCertificate(validCert4, isCountRuleEnabled: false).wait()
            _ = try sut.scanCertificate(validCert5, isCountRuleEnabled: false).wait()
            _ = try sut.scanCertificate(validCert6, isCountRuleEnabled: false).wait()
            _ = try sut.scanCertificate(validCert7, isCountRuleEnabled: false).wait()
            _ = try sut.scanCertificate(validCert8, isCountRuleEnabled: false).wait()
            _ = try sut.scanCertificate(validCert9, isCountRuleEnabled: false).wait()
            _ = try sut.scanCertificate(validCert10, isCountRuleEnabled: false).wait()
            XCTAssert(true)
        } catch {
            XCTFail("Should fail")
        }
    }
    
}
