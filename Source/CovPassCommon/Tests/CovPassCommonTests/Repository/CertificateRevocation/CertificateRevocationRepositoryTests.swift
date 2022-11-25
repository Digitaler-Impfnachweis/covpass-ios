//
//  CertificateRevocationRepositoryTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Compression
@testable import CovPassCommon
import XCTest

class CertificateRevocationRepositoryTests: XCTestCase {
    private var client: CertificateRevocationDataSourceMock!
    private var sut: CertificateRevocationRepository!
    private var userDefaults: UserDefaultsPersistence!

    override func setUpWithError() throws {
        client = .init()
        userDefaults = UserDefaultsPersistence()
        client.kidListResponse = .validKidListResponse()
        sut = .init(client: client)
    }

    override func tearDownWithError() throws {
        userDefaults = nil
        client = nil
        sut = nil
    }

    func testIsRevoked_token_without_qrcode() {
        // Given
        let token = CBORWebToken.mockVaccinationCertificate.extended()
        let expectation = XCTestExpectation()
        client.getKIDListExpectation.isInverted = true

        // When
        sut.isRevoked(token)
            .done { isRevoked in
                XCTAssertFalse(isRevoked)
                expectation.fulfill()
            }

        // Then
        wait(for: [expectation, client.getKIDListExpectation], timeout: 3)
    }

    func testIsRevoked_kid_lst_call_fails() throws {
        // Given
        let token = try ExtendedCBORWebToken.revokedVaccinationCertificate()
        let expectation = XCTestExpectation()
        client.getKIDListError = NSError(domain: "", code: 0)
        client.optionsIndexListExpectation.isInverted = true

        // When
        sut.isRevoked(token)
            .done { isRevoked in
                XCTAssertFalse(isRevoked)
                expectation.fulfill()
            }

        // Then
        wait(for: [
            expectation,
            client.getKIDListExpectation,
            client.optionsIndexListExpectation
        ], timeout: 1)
    }

    func testIsRevoked_kid_lst_does_not_contain_kid() throws {
        // Given
        let token = try ExtendedCBORWebToken.revokedVaccinationCertificate()
        let expectation = XCTestExpectation()
        client.optionsIndexListExpectation.isInverted = true
        client.kidListResponse = .init()

        // When
        sut.isRevoked(token)
            .done { isRevoked in
                XCTAssertFalse(isRevoked)
                expectation.fulfill()
            }

        // Then
        wait(for: [
            expectation,
            client.getKIDListExpectation,
            client.optionsIndexListExpectation
        ], timeout: 1)
    }

    func testIsRevoked_options_index_lst_call_failed() throws {
        // Given
        let token = try ExtendedCBORWebToken.revokedVaccinationCertificate()
        let expectation = XCTestExpectation()
        client.optionsIndexListError = NSError(domain: "", code: 0)
        client.getIndexListExpectation.isInverted = true

        // When
        sut.isRevoked(token)
            .done { isRevoked in
                XCTAssertFalse(isRevoked)
                expectation.fulfill()
            }

        // Then
        wait(for: [
            expectation,
            client.optionsIndexListExpectation,
            client.getIndexListExpectation
        ], timeout: 1)
    }

    func testIsRevoked_get_index_lst_call_failed() throws {
        // Given
        let token = try ExtendedCBORWebToken.revokedVaccinationCertificate()
        let expectation = XCTestExpectation()
        client.getIndexListError = NSError(domain: "", code: 0)
        client.getIndexListExpectation.expectedFulfillmentCount = 1
        client.optionsChunkListExpectation.isInverted = true

        // When
        sut.isRevoked(token)
            .done { isRevoked in
                XCTAssertFalse(isRevoked)
                expectation.fulfill()
            }

        // Then
        wait(for: [
            expectation,
            client.getIndexListExpectation,
            client.optionsChunkListExpectation
        ], timeout: 1)
    }

    func testIsRevoked_get_index_lst_call_does_not_contain_byte1_and_byte2() throws {
        // Given
        let token = try ExtendedCBORWebToken.revokedVaccinationCertificate()
        let expectation = XCTestExpectation()
        client.getIndexListExpectation.expectedFulfillmentCount = 3
        client.optionsIndexListExpectation.expectedFulfillmentCount = 3
        client.optionsChunkListExpectation.isInverted = true
        client.indexListResponse = .init()

        // When
        sut.isRevoked(token)
            .done { isRevoked in
                XCTAssertFalse(isRevoked)
                expectation.fulfill()
            }

        // Then
        wait(for: [
            expectation,
            client.getIndexListExpectation,
            client.optionsIndexListExpectation,
            client.optionsChunkListExpectation
        ], timeout: 1)
    }

    func testIsRevoked_options_chunk_lst_fails() throws {
        // Given
        let token = try ExtendedCBORWebToken.revokedVaccinationCertificate()
        let expectation = XCTestExpectation()
        client.optionsChunkListError = NSError(domain: "", code: 0)
        client.getChunkListExpectation.isInverted = true

        // When
        sut.isRevoked(token)
            .done { isRevoked in
                XCTAssertFalse(isRevoked)
                expectation.fulfill()
            }

        // Then
        wait(for: [
            expectation,
            client.optionsChunkListExpectation,
            client.getChunkListExpectation
        ], timeout: 4)
    }

    func testIsRevoked_get_chunk_lst_fails() throws {
        // Given
        let token = try ExtendedCBORWebToken.revokedVaccinationCertificate()
        let expectation = XCTestExpectation()
        client.getChunkListError = NSError(domain: "", code: 0)

        // When
        sut.isRevoked(token)
            .done { isRevoked in
                XCTAssertFalse(isRevoked)
                expectation.fulfill()
            }

        // Then
        wait(for: [
            expectation,
            client.getChunkListExpectation
        ], timeout: 1)
    }

    func testIsRevoked_chunk_lst_does_not_contain_signature() throws {
        // Given
        let token = try ExtendedCBORWebToken.revokedVaccinationCertificate()
        let expectation = XCTestExpectation()
        client.chunkListResponse = .init(hashes: [])

        // When
        sut.isRevoked(token)
            .done { isRevoked in
                XCTAssertFalse(isRevoked)
                expectation.fulfill()
            }

        // Then
        wait(for: [
            expectation,
            client.getChunkListExpectation
        ], timeout: 1)
    }

    func testIsRevoked_success() throws {
        // Given
        let token = try ExtendedCBORWebToken.revokedVaccinationCertificate()
        let expectation = XCTestExpectation()
        client.optionsChunkListExpectation.expectedFulfillmentCount = 2
        client.getChunkListExpectation.expectedFulfillmentCount = 2

        // When
        sut.isRevoked(token)
            .done { isRevoked in
                XCTAssertTrue(isRevoked)
                expectation.fulfill()
            }

        // Then
        wait(for: [
            client.getKIDListExpectation,
            client.optionsIndexListExpectation,
            client.getIndexListExpectation,
            client.optionsChunkListExpectation,
            client.getChunkListExpectation,
            expectation
        ], timeout: 4, enforceOrder: true)
    }

    func testIsRevoked_success_bytes_in_second_index_lst_request() throws {
        // Given
        let token = try ExtendedCBORWebToken.revokedVaccinationCertificate()
        let expectation = XCTestExpectation()
        client.optionsIndexListExpectation.expectedFulfillmentCount = 2
        client.getIndexListExpectation.expectedFulfillmentCount = 2
        client.kidListResponse = .kidListResponseSignatureIsSecond()
        client.indexListResponse = .indexListResponseOnlySignatureHash()

        // When
        sut.isRevoked(token)
            .done { isRevoked in
                XCTAssertTrue(isRevoked)
                expectation.fulfill()
            }

        // Then
        wait(for: [
            expectation,
            client.getIndexListExpectation,
            client.optionsIndexListExpectation
        ], timeout: 1)
    }

    func testIsRevoked_success_with_uci_hash() throws {
        // Given
        let token = try ExtendedCBORWebToken.revokedVaccinationCertificate()
        let expectation = XCTestExpectation()
        client.kidListResponse = .kidListResponseUCIHasPriority()

        // When
        sut.isRevoked(token)
            .done { isRevoked in
                XCTAssertTrue(isRevoked)
                expectation.fulfill()
            }

        // Then
        wait(for: [expectation], timeout: 1)
    }

    func testIsRevoked_success_with_uci_country_hash() throws {
        // Given
        let token = try ExtendedCBORWebToken.revokedVaccinationCertificate()
        let expectation = XCTestExpectation()
        client.kidListResponse = .kidListResponseUCICountryHasPriority()

        // When
        sut.isRevoked(token)
            .done { isRevoked in
                XCTAssertTrue(isRevoked)
                expectation.fulfill()
            }

        // Then
        wait(for: [expectation], timeout: 1)
    }
}

private extension ExtendedCBORWebToken {
    static func revokedVaccinationCertificate() throws -> ExtendedCBORWebToken {
        let decodedQRCode = try Base45Coder.decode(revokedVaccinationCertificateQRCode.stripPrefix())
        let decompressedQRCode = Compression.decompress(Data(decodedQRCode))!
        let message = try CoseSign1Message(decompressedPayload: decompressedQRCode)
        let messagePayload = try message.toJSON()
        let cborWebToken = try JSONDecoder().decode(CBORWebToken.self, from: messagePayload)
        let extendedCborWebToken = ExtendedCBORWebToken(
            vaccinationCertificate: cborWebToken,
            vaccinationQRCodeData: revokedVaccinationCertificateQRCode
        )
        return extendedCborWebToken
    }
}

private let revokedVaccinationCertificateQRCode = "HC1:6BFOXN%TSMAHN-HR S7OQLQ7P:I/F8RT8ELBXG4:WFUZETSJ$PI$PD92PZ.2AN9I6T5XH4PIQJAZGA+1V2:U:PI/E2$4JY/K5+C$/IU7JB+2D-4Q/S6AL**INOV6$0+BN$MVYWV7Y4/9TYXV2+A8ALK%I9YV1*85AL5:4A93QHBIFTQ13:CAGGBYPL0QIRR97I2HOAXL92L0. KOKGTM8$M8SNCT64BR7Z6NC8P$WA3AA9EPBDSM+QFE4:/6N9R%EPXCROGO3HOWGOKEQ395Z4IUHL+$G-B5ET42HPHEP58R/8HNTICZUM.D6PP2*98WU0T9X5QPDQFY1OSMNV1L8V1D1O M*GE7WUPXUJY1V9E$P12EE0:U53F061/Q6S5V2:U T68BH 6B7GWJOCPBBG9LKC328RGHI8BOXLERX6VP8GVVUMPW73FKKNEFP0767H761$DCB2GH.U*MA-8L7D7DON%FK8:LIFHBKS6VSA%DFUI3H08.B5SE"

private let trustKey = """
-----BEGIN PUBLIC KEY-----
MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAE6Ft4aTjScTpsvY0tg2Lx0AK0Ih3Z
2VKXnyBvoZxngB9cXmNtTg+Va3fY3QJduf+OXaWsE34xvMTIHxw+MpOLkw==
-----END PUBLIC KEY-----
"""
