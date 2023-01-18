//
//  CBORWebTokenTests.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCommon

import Foundation
import XCTest

class CBORWebTokenTests: XCTestCase {
    var sut: CBORWebToken!

    override func setUpWithError() throws {
        sut = .mockVaccinationCertificate
    }

    override func tearDownWithError() throws {
        sut = nil
    }

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

    func testIssIsDE() {
        // GIVEN
        var certificate = CBORWebToken.mockVaccinationCertificate
        certificate.iss = "DE"

        // WHEN
        let isGermanCert = certificate.isGermanIssuer

        // THEN
        XCTAssertEqual(isGermanCert, true)
    }

    func testIssIsNotDE() {
        // GIVEN
        var certificate = CBORWebToken.mockVaccinationCertificate
        certificate.iss = "FOO"

        // WHEN
        let isGermanCert = certificate.isGermanIssuer

        // THEN
        XCTAssertEqual(isGermanCert, false)
    }

    func testExpiredMoreThan90Days_expired() {
        // Given
        sut.exp = Date().add(days: -90)

        // When
        let expiredMoreThan90Days = sut.expiredMoreThan90Days

        // Then
        XCTAssertTrue(expiredMoreThan90Days)
    }

    func testExpiredForLessOrEqual90Days_expired_less_than_90_days_ago() {
        // Given
        sut.exp = Date(timeIntervalSinceNow: -1)

        // When
        let isExpired = sut.expiredForLessOrEqual90Days

        // Then
        XCTAssertTrue(isExpired)
    }

    func testExpiredForLessOrEqual90Days_not_expired() {
        // Given
        sut.exp = .distantFuture

        // When
        let isExpired = sut.expiredForLessOrEqual90Days

        // Then
        XCTAssertFalse(isExpired)
    }

    func testExpiredForLessOrEqual90Days_expired_more_than_90_days_ago() {
        // Given
        sut.exp = .distantPast

        // When
        let isExpired = sut.expiredForLessOrEqual90Days

        // Then
        XCTAssertFalse(isExpired)
    }

    func testExpiredForLessOrEqual90Days_exp_is_nil() {
        // Given
        sut.exp = nil

        // When
        let isExpired = sut.expiredForLessOrEqual90Days

        // Then
        XCTAssertFalse(isExpired)
    }

    func testWillExpireInLessOrEqual28Days_already_expired() {
        // Given
        sut.exp = Date(timeIntervalSinceNow: -1)

        // When
        let willExpire = sut.willExpireInLessOrEqual28Days

        // Then
        XCTAssertFalse(willExpire)
    }

    func testWillExpireInLessOrEqual28Days_will_expire() {
        // Given
        sut.exp = Date(timeIntervalSinceNow: 28 * secondsPerDay)

        // When
        let willExpire = sut.willExpireInLessOrEqual28Days

        // Then
        XCTAssertTrue(willExpire)
    }

    func testWillExpireInLessOrEqual28Days_will_expire_after_28_days() {
        // Given
        sut.exp = Date(timeIntervalSinceNow: 30 * secondsPerDay)

        // When
        let willExpire = sut.willExpireInLessOrEqual28Days

        // Then
        XCTAssertFalse(willExpire)
    }

    func testWillExpireInLessOrEqual28Days_exp_is_nil() {
        // Given
        sut.exp = nil

        // When
        let willExpire = sut.willExpireInLessOrEqual28Days

        // Then
        XCTAssertFalse(willExpire)
    }
}

private let secondsPerHour: TimeInterval = 60 * 60
private let secondsPerDay: TimeInterval = 24 * secondsPerHour
