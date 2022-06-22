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
        let revocationRepo = CertificateRevocationRepositoryMock()
        sut = VaccinationRepository(
            revocationRepo: revocationRepo,
            service: service,
            keychain: keychain,
            userDefaults: userDefaults,
            boosterLogic: boosterLogic,
            publicKeyURL: Bundle.module.url(forResource: "pubkey.pem", withExtension: nil)!,
            initialDataURL: trustListURL
        )
    }
    
    func configureSut(revoked: Bool) -> VaccinationRepository {
        service = APIServiceMock()
        keychain = MockPersistence()
        userDefaults = MockPersistence()
        boosterLogic = BoosterLogicMock()
        let trustListURL = Bundle.commonBundle.url(forResource: "dsc.json", withExtension: nil)!
        let revocationRepo = CertificateRevocationRepositoryMock()
        revocationRepo.isRevoked = revoked
        let sut = VaccinationRepository(
            revocationRepo: revocationRepo,
            service: service,
            keychain: keychain,
            userDefaults: userDefaults,
            boosterLogic: boosterLogic,
            publicKeyURL: Bundle.module.url(forResource: "pubkey.pem", withExtension: nil)!,
            initialDataURL: trustListURL
        )
        return sut
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
        let res = try sut.checkCertificate(CertificateMock.validCertificate2).wait()
        XCTAssertEqual(res.iss, "IT")
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
        // Given
        let token = CertificateMock.validRecoveryCertificate
        let expectation = XCTestExpectation()

        // When
        sut.checkCertificate(token)
            .done { tokens in
                XCTAssertNoThrow(try self.sut.validateEntity(tokens))
                expectation.fulfill()
            }
            .cauterize()

        //Then
        wait(for: [expectation], timeout: 1)
    }
    
    func testValidateEntityValidCertificateNoPrefix() {
        // Given
        let token = CertificateMock.validCertificateNoPrefix
        let expectation = XCTestExpectation()

        // When
        sut.checkCertificate(token)
            .done { tokens in
                XCTAssertNoThrow(try self.sut.validateEntity(tokens))
                expectation.fulfill()
            }
            .cauterize()

        //Then
        wait(for: [expectation], timeout: 1)
    }
    
    func testValidateEntityValidExtendedKeyUsageGreece() {
        // Given
        let token = CertificateMock.validExtendedKeyUsageGreece
        let expectation = XCTestExpectation()

        // When
        sut.checkCertificate(token)
            .done { tokens in
                XCTAssertNoThrow(try self.sut.validateEntity(tokens))
                expectation.fulfill()
            }
            .cauterize()

        //Then
        wait(for: [expectation], timeout: 1)
    }
    
    func testCheckCertificateInvalidEntity() {
        do {
            let res = try sut.checkCertificate(CertificateMock.validCertificate2).wait()
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
            XCTAssertEqual(error.localizedDescription, "The data couldn’t be read because it is missing.")
        }
    }
    
    func testValidateEntityInvalidExtendedKeyUsagePoland() {
        do {
            let res = try sut.checkCertificate(CertificateMock.invalidExtendedKeyUsagePoland).wait()
            try sut.validateEntity(res)
            XCTFail("Should fail")
        } catch {
            XCTAssertEqual(error.localizedDescription, HCertError.illegalKeyUsage.localizedDescription)
        }
    }
    
    func testValidateEntityValidCertifcateRSA() {
        do {
            let res = try sut.checkCertificate(CertificateMock.validCertifcateRSA).wait()
            try sut.validateEntity(res)
            XCTFail("Should fail")
        } catch {
            XCTAssertEqual(error.localizedDescription, CertificateError.expiredCertifcate.localizedDescription)
        }
    }

    func testGetCertificateList() throws {
        // Store one certficate in list
        try keychain.store(
            CertificateList(
                certificates: [
                    ExtendedCBORWebToken(
                        vaccinationCertificate: try JSONDecoder().decode(CBORWebToken.self, from: Data.json("CBORWebToken")),
                        vaccinationQRCodeData: CertificateMock.validCertificate2)
                ],
                favoriteCertificateId: "1"
            )
        )

        // Get certificate list
        let list = try sut.getCertificateList().wait()

        XCTAssertEqual(list.favoriteCertificateId, "1")
        XCTAssertEqual(list.certificates.first?.isInvalid, false)
    }

    func testGetCertificateListWithInvalidation() throws {
        // Store one certficate in list
        try keychain.store(
            CertificateList(
                certificates: [
                    ExtendedCBORWebToken(
                        vaccinationCertificate: try JSONDecoder().decode(CBORWebToken.self, from: Data.json("CBORWebToken")),
                        vaccinationQRCodeData: CertificateMock.invalidCertificateInvalidSignature)
                ],
                favoriteCertificateId: "1"
            )
        )

        // Get certificate list
        let list = try sut.getCertificateList().wait()

        XCTAssertEqual(list.favoriteCertificateId, "1")
        XCTAssertEqual(list.certificates.first?.isInvalid, true)
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

    func testAdd_success() throws {
        // Given
        let tokens = [
            CBORWebToken.mockVaccinationCertificate.extended(),
            CBORWebToken.mockVaccinationCertificate.extended(),
            CBORWebToken.mockVaccinationCertificate.extended()
        ]
        let certificateList = CertificateList(
            certificates: tokens,
            favoriteCertificateId: nil
        )
        try keychain.store(certificateList)
        let expectation = XCTestExpectation()

        // When
        sut.add(tokens: tokens)
            .done { _ in
                let tokens = try self.keychain.fetchCertificateList().certificates
                XCTAssertEqual(tokens.count, 6)
                expectation.fulfill()
            }
            .catch { error in
                XCTFail("Must not fail.")
            }

        // Then
        wait(for: [expectation], timeout: 1)
    }

    func testAdd_error() throws {
        // Given
        let tokens = [
            CBORWebToken.mockVaccinationCertificate.extended(),
            CBORWebToken.mockVaccinationCertificate.extended(),
            CBORWebToken.mockVaccinationCertificate.extended()
        ]
        keychain.storeError = NSError(domain: "TEST", code: 0, userInfo: nil)
        let expectation = XCTestExpectation()

        // When
        sut.add(tokens: tokens)
            .done { _ in
                XCTFail("Must not succeed.")
            }
            .catch { error in
                expectation.fulfill()
            }

        // Then
        wait(for: [expectation], timeout: 1)
    }

    func testDeleteCertificate() throws {
        let cborWebToken = CBORWebToken.mockVaccinationCertificate
        let cert = ExtendedCBORWebToken(vaccinationCertificate: cborWebToken,
                                        vaccinationQRCodeData: "")
        
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
        let cert = ExtendedCBORWebToken(vaccinationCertificate: cborWebToken,
                                        vaccinationQRCodeData: "")

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
        let cert = ExtendedCBORWebToken(vaccinationCertificate: cborWebToken,
                                        vaccinationQRCodeData: "")

        // other booster notifications should stay when certificate gets deleted
        boosterLogic.updateBoosterCandidate(BoosterCandidate(certificate: ExtendedCBORWebToken(vaccinationCertificate: CBORWebToken.mockVaccinationCertificate.mockVaccinationUVCI("foo"),
                                                                                               vaccinationQRCodeData: "")))

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
        let token = try sut.checkCertificate(CertificateMock.validCertificate2).wait()
        XCTAssertEqual(token.hcert.dgc.uvci, "URN:UVCI:01DE/84503/1651139518/DXSGWLWL40SU8ZFKIYIBK30A4#S")
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
        let cert = ExtendedCBORWebToken(vaccinationCertificate: cborWebToken,
                                        vaccinationQRCodeData: "")
        let cert2 = CBORWebToken.mockVaccinationCertificate.extended(vaccinationQRCodeData: "1")
        _ = try sut.saveCertificateList(CertificateList(certificates: [cert, cert2])).wait()

        // Get certificate list
        var list = try sut.getCertificateList().wait()

        // Get the first Token
        var token1 = try XCTUnwrap(list.certificates.first)
        var token2 = try XCTUnwrap(list.certificates.last)
        let tokens = [token1, token2]
        XCTAssertNil(token1.wasExpiryAlertShown)
        XCTAssertNil(token2.wasExpiryAlertShown)
        // set that the expiry alert view is shown for this token
        _ = try sut.setExpiryAlert(shown: true, tokens: tokens).wait()

        // Get the list and check if the was expiry bool was shown is saved
        list = try sut.getCertificateList().wait()
        token1 = try XCTUnwrap(list.certificates.first)
        token2 = try XCTUnwrap(list.certificates.last)

        XCTAssertNotNil(token1.wasExpiryAlertShown)
        XCTAssertNotNil(token2.wasExpiryAlertShown)
        XCTAssertTrue(try XCTUnwrap(token1.wasExpiryAlertShown))
        XCTAssertTrue(try XCTUnwrap(token2.wasExpiryAlertShown))
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
        let cert = ExtendedCBORWebToken(vaccinationCertificate: cborWebToken,
                                        vaccinationQRCodeData: "")
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
            vaccinationQRCodeData: "")
        let cert2 = ExtendedCBORWebToken(
            vaccinationCertificate: try! JSONDecoder().decode(CBORWebToken.self, from: Data.json("CBORWebToken")),
            vaccinationQRCodeData: "")
        let list = CertificateList(certificates: [cert1, cert2])

        let res = sut.matchedCertificates(for: list)
        XCTAssertEqual(res.count, 1)
        XCTAssertEqual(res.first?.certificates.count, 2)
    }

    func testMatchedCertificatesDifferentPeople() throws {
        let cert1 = ExtendedCBORWebToken(
            vaccinationCertificate: try! JSONDecoder().decode(CBORWebToken.self, from: Data.json("CBORWebToken")),
            vaccinationQRCodeData: "")
        var token = try! JSONDecoder().decode(CBORWebToken.self, from: Data.json("CBORWebToken"))
        token.hcert.dgc.dob = Date()
        let cert2 = ExtendedCBORWebToken(
            vaccinationCertificate: token,
            vaccinationQRCodeData: "")
        let list = CertificateList(certificates: [cert1, cert2])

        let res = sut.matchedCertificates(for: list)
        XCTAssertEqual(res.count, 2)
        XCTAssertEqual(res.first?.certificates.count, 1)
    }

    func testScanCertificate() throws {
        let token = try sut.scanCertificate(CertificateMock.validCertificate2, isCountRuleEnabled: true, expirationRuleIsActive: true).wait()
        XCTAssertEqual((token as! ExtendedCBORWebToken).vaccinationCertificate.hcert.dgc.uvci, "URN:UVCI:01DE/84503/1651139518/DXSGWLWL40SU8ZFKIYIBK30A4#S")
    }

    func testScanCertificateFailsPositive() {
        do {
            let positivePCRTest = "HC1:6BFOXN*TS0BI$ZD8UHYK1EBQZWG8W4:D4WGF-36OLNAOMIZ4WYHZKCML94HK4XPQHIZC4.OI:OI4V2*LP8W2GHKW/F3IKJ5QH*AF/GJ5MQ0KS1OK.GZ/8V5P%C4CAW+DG$$02-7%KSSDCWEGNY0/-9RQPYE9/MVSYSOH6PO9:TUQJAJG9-*NIRICVELZUZM9EN9-O9FNHZO9HQ1*P1MX1+ZE$S9$R1YXL5Q1M35AHLRIN$S4IFN5F599M+BLA4BB%V%3NKQ777IT$M0QIRR97I2HOAXL92L0A KDNKBK4CJ0JQE6H0:WO$NI Q1610AJ27K2FVIP$I/XK$M8X64XDOXCR$35L/5R3FMIA4/B 3ELEE$JD/.D%-B9JAW/BT3E3Z84JBSD9Z3E8AE-QD89MT6KBLEH-BNQMWOCNKE$JDVPLZ2KD0KCZG/WR-RIR.8DZF+:247F./N WBJ JMABA4N$Y55JS+%QOC9H.19CTT595URS9W7 6 VI/U2 PTNZ56 PTS5N*JP.61KJ618S:1*KICQIDGGV+F"
            _ = try sut.scanCertificate(positivePCRTest, isCountRuleEnabled: true, expirationRuleIsActive: true).wait()
            XCTFail("Should fail")
        } catch {
            XCTAssertEqual(error.localizedDescription, CertificateError.positiveResult.localizedDescription)
        }
    }

    func testScanCertificateFailsExistingQRCode() {
        do {
            _ = try sut.scanCertificate(CertificateMock.validCertificate2, isCountRuleEnabled: true, expirationRuleIsActive: true).wait()
            _ = try sut.scanCertificate(CertificateMock.validCertificate2, isCountRuleEnabled: true, expirationRuleIsActive: true).wait()
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
        
        let validCert1 = CertificateMock.validCertificate2
        let validCert2 = CertificateMock.validRecoveryCertificate

        do {
            _ = try sut.scanCertificate(validCert1, isCountRuleEnabled: true, expirationRuleIsActive: true).wait()
            _ = try sut.scanCertificate(validCert2, isCountRuleEnabled: true, expirationRuleIsActive: true).wait()
            XCTFail("Should fail")
        } catch {
            XCTAssertEqual(error.localizedDescription, QRCodeError.warningCountOfCertificates.localizedDescription)
        }
    }
    
    func testCountRule_Disabled_WithDifferentPersons2() throws {
        let validCert1 = CertificateMock.validCertificate2
        let validCert2 = CertificateMock.validRecoveryCertificate
        _ = try sut.scanCertificate(validCert1, isCountRuleEnabled: true, expirationRuleIsActive: true).wait()
        _ = try sut.scanCertificate(validCert2, isCountRuleEnabled: false, expirationRuleIsActive: true).wait()
    }
    
    func testCountRule_Enabled_10TimesSamePerson() {
        let validCert1 = CertificateMock.validCertificate2
        let validCert2 = CertificateMock.validCertificate2.appending("B")
        let validCert3 = CertificateMock.validCertificate2.appending("C")
        let validCert4 = CertificateMock.validCertificate2.appending("D")
        let validCert5 = CertificateMock.validCertificate2.appending("E")
        let validCert6 = CertificateMock.validCertificate2.appending("F")
        let validCert7 = CertificateMock.validCertificate2.appending("G")
        let validCert8 = CertificateMock.validCertificate2.appending("H")
        let validCert9 = CertificateMock.validCertificate2.appending("I")
        let validCert10 = CertificateMock.validCertificate2.appending("J")

        do {
            _ = try sut.scanCertificate(validCert1, isCountRuleEnabled: true, expirationRuleIsActive: true).wait()
            _ = try sut.scanCertificate(validCert2, isCountRuleEnabled: true, expirationRuleIsActive: true).wait()
            _ = try sut.scanCertificate(validCert3, isCountRuleEnabled: true, expirationRuleIsActive: true).wait()
            _ = try sut.scanCertificate(validCert4, isCountRuleEnabled: true, expirationRuleIsActive: true).wait()
            _ = try sut.scanCertificate(validCert5, isCountRuleEnabled: true, expirationRuleIsActive: true).wait()
            _ = try sut.scanCertificate(validCert6, isCountRuleEnabled: true, expirationRuleIsActive: true).wait()
            _ = try sut.scanCertificate(validCert7, isCountRuleEnabled: true, expirationRuleIsActive: true).wait()
            _ = try sut.scanCertificate(validCert8, isCountRuleEnabled: true, expirationRuleIsActive: true).wait()
            _ = try sut.scanCertificate(validCert9, isCountRuleEnabled: true, expirationRuleIsActive: true).wait()
            _ = try sut.scanCertificate(validCert10, isCountRuleEnabled: true, expirationRuleIsActive: true).wait()
            XCTAssert(true)
        } catch {
            XCTFail("Should fail")
        }
    }
    
    func testCountRule_Disabled_10TimesSamePerson() {
        let validCert1 = CertificateMock.validCertificate2
        let validCert2 = CertificateMock.validCertificate2.appending("B")
        let validCert3 = CertificateMock.validCertificate2.appending("C")
        let validCert4 = CertificateMock.validCertificate2.appending("D")
        let validCert5 = CertificateMock.validCertificate2.appending("E")
        let validCert6 = CertificateMock.validCertificate2.appending("F")
        let validCert7 = CertificateMock.validCertificate2.appending("G")
        let validCert8 = CertificateMock.validCertificate2.appending("H")
        let validCert9 = CertificateMock.validCertificate2.appending("I")
        let validCert10 = CertificateMock.validCertificate2.appending("J")

        do {
            _ = try sut.scanCertificate(validCert1, isCountRuleEnabled: false, expirationRuleIsActive: true).wait()
            _ = try sut.scanCertificate(validCert2, isCountRuleEnabled: false, expirationRuleIsActive: true).wait()
            _ = try sut.scanCertificate(validCert3, isCountRuleEnabled: false, expirationRuleIsActive: true).wait()
            _ = try sut.scanCertificate(validCert4, isCountRuleEnabled: false, expirationRuleIsActive: true).wait()
            _ = try sut.scanCertificate(validCert5, isCountRuleEnabled: false, expirationRuleIsActive: true).wait()
            _ = try sut.scanCertificate(validCert6, isCountRuleEnabled: false, expirationRuleIsActive: true).wait()
            _ = try sut.scanCertificate(validCert7, isCountRuleEnabled: false, expirationRuleIsActive: true).wait()
            _ = try sut.scanCertificate(validCert8, isCountRuleEnabled: false, expirationRuleIsActive: true).wait()
            _ = try sut.scanCertificate(validCert9, isCountRuleEnabled: false, expirationRuleIsActive: true).wait()
            _ = try sut.scanCertificate(validCert10, isCountRuleEnabled: false, expirationRuleIsActive: true).wait()
            XCTAssert(true)
        } catch {
            XCTFail("Should fail")
        }
    }
    
    func testCountRule_Enabled_addingThirdCertWhichIsOfAnAlreadyAvailablePerson() {
        
        let person1Cert1 = CertificateMock.validCertificate3
        let person2Cert1 = CertificateMock.validCertificate4
        let person2Cert2 = CertificateMock.validCertificate6

        do {
            _ = try sut.scanCertificate(person1Cert1, isCountRuleEnabled: false, expirationRuleIsActive: true).wait()
            _ = try sut.scanCertificate(person2Cert1, isCountRuleEnabled: false, expirationRuleIsActive: true).wait()
            _ = try sut.scanCertificate(person2Cert2, isCountRuleEnabled: true, expirationRuleIsActive: true).wait()
            XCTAssert(true)
        } catch {
            print(error)
            XCTFail("Should fail")
        }
    }
    
    func testCountRule_Enabled_addingFourthCertWhichIsANewPerson() {
        
        let person1Cert1 = CertificateMock.validCertificate3
        let person2Cert1 = CertificateMock.validCertificate4
        let person2Cert2 = CertificateMock.validCertificate6
        let person3Cert1 = CertificateMock.validCertificate2

        do {
            _ = try sut.scanCertificate(person1Cert1, isCountRuleEnabled: false, expirationRuleIsActive: true).wait()
            _ = try sut.scanCertificate(person2Cert1, isCountRuleEnabled: false, expirationRuleIsActive: true).wait()
            _ = try sut.scanCertificate(person2Cert2, isCountRuleEnabled: false, expirationRuleIsActive: true).wait()
            _ = try sut.scanCertificate(person3Cert1, isCountRuleEnabled: true, expirationRuleIsActive: true).wait()
            XCTAssert(true)
        } catch {
            print(error)
            XCTFail("Should fail")
        }
    }
    
    func testScanExpiredCertificate_expirationRuleIsActive() {
        // GIVEN
        let expiredCert = CertificateMock.expiredCertificate
        let expecation = XCTestExpectation()
        // WHEN
        sut.scanCertificate(expiredCert, isCountRuleEnabled: false, expirationRuleIsActive: true)
            .catch{ error in
                // THEN
                if (error as? CertificateError) == .expiredCertifcate {
                    expecation.fulfill()
                }
            }
        wait(for: [expecation], timeout: 1.0)
    }
    
    func testScanExpiredCertificate_expirationRuleIsDeActive() {
        // GIVEN
        let expiredCert = CertificateMock.expiredCertificate
        let expecation = XCTestExpectation()
        // WHEN
        sut.scanCertificate(expiredCert, isCountRuleEnabled: false, expirationRuleIsActive: false)
            .done { scanResponse in
                // THEN
                if let token = scanResponse as? ExtendedCBORWebToken {
                    XCTAssertTrue(token.vaccinationCertificate.isExpired)
                    expecation.fulfill()
                }
            }.cauterize()
        wait(for: [expecation], timeout: 1.0)
    }
    
    func testScanNotExpiredCertificate_expirationRuleIsActive() {
        // GIVEN
        let expiredCert = CertificateMock.validCertificate2
        let expecation = XCTestExpectation()
        // WHEN
        sut.scanCertificate(expiredCert, isCountRuleEnabled: false, expirationRuleIsActive: true)
            .done { scanResponse in
                // THEN
                if let token = scanResponse as? ExtendedCBORWebToken {
                    XCTAssertFalse(token.vaccinationCertificate.isExpired)
                    expecation.fulfill()
                }
            }.cauterize()
        wait(for: [expecation], timeout: 1.0)
    }
    
    func testScanNotExpiredCertificate_expirationRuleIsDeActive() {
        // GIVEN
        let expiredCert = CertificateMock.validCertificate2
        let expecation = XCTestExpectation()
        // WHEN
        sut.scanCertificate(expiredCert, isCountRuleEnabled: false, expirationRuleIsActive: false)
            .done { scanResponse in
                // THEN
                if let token = scanResponse as? ExtendedCBORWebToken {
                    XCTAssertFalse(token.vaccinationCertificate.isExpired)
                    expecation.fulfill()
                }
            }.cauterize()
        wait(for: [expecation], timeout: 1.0)
    }

    func testReplace_token_does_not_exist() {
        // Given
        let token = CBORWebToken.mockVaccinationCertificate.extended(
            vaccinationQRCodeData: "token"
        )
        let expectation = XCTestExpectation()

        // When
        sut.replace(token)
            .done { _ in
                XCTFail("Must not succeed.")
            }
            .catch { _ in
                expectation.fulfill()
            }

        // Then
        wait(for: [expectation], timeout: 1)
    }

    func testReplace_token_does_exist() throws {
        // Given
        let expectation = XCTestExpectation()
        let uuid = UUID().uuidString
        var token = try JSONDecoder().decode(CBORWebToken.self, from: Data.json("CBORWebToken"))
        let certificateList = CertificateList(
            certificates: [.init(vaccinationCertificate: token, vaccinationQRCodeData: "ABCD")],
            favoriteCertificateId: "1"
        )
        try keychain.store(certificateList)
        token.iss = uuid
        var changedExtendedToken = ExtendedCBORWebToken(
            vaccinationCertificate: token,
            vaccinationQRCodeData: "ABCD"
        )
        changedExtendedToken.reissueProcessNewBadgeAlreadySeen = true

        // When
        sut.replace(changedExtendedToken)
            .done { _ in
                let certificates = try self.keychain.fetchCertificateList().certificates
                if let token = certificates.first(where: { $0 == changedExtendedToken }) {
                    XCTAssertEqual(token.vaccinationCertificate.iss, uuid)
                    XCTAssertEqual(token.reissueProcessNewBadgeAlreadySeen, true)
                    expectation.fulfill()
                }
            }
            .catch { _ in
                XCTFail()
            }

        // Then
        wait(for: [expectation], timeout: 1)
    }
}

private extension MockPersistence {
    func store(_ certificateList: CertificateList) throws {
        let data = try JSONEncoder().encode(certificateList)
        try store(KeychainPersistence.Keys.certificateList.rawValue, value: data)
    }

    func fetchCertificateList() throws -> CertificateList {
        guard let data = try? fetch(KeychainPersistence.Keys.certificateList.rawValue) as? Data else {
            throw NSError(domain: "TEST", code: 0, userInfo: nil)
        }
        let certificateList = try JSONDecoder().decode(CertificateList.self, from: data)
        return certificateList
    }
}
