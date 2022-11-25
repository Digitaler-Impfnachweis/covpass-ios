//
//  DigitalGreenCertificateExtensionTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCommon
import XCTest

class DigitalGreenCertificateExtensionTests: XCTestCase {
    private var sut: DigitalGreenCertificate!

    override func setUpWithError() throws {
        sut = .init(
            nam: .init(gn: nil, fn: nil, gnt: nil, fnt: ""),
            dob: nil,
            dobString: nil,
            v: nil,
            t: nil,
            r: nil,
            ver: ""
        )
    }

    override func tearDownWithError() throws {
        sut = nil
    }

    func testIs1of2Vaccination_no_vaccination() {
        // When
        let is1Of2 = sut.is1of2Vaccination

        // Then
        XCTAssertFalse(is1Of2)
    }

    func testIs1of2Vaccination_2_of_2() {
        // Given
        configureSut()

        // When
        let is1Of2 = sut.is1of2Vaccination

        // Then
        XCTAssertFalse(is1Of2)
    }

    private func configureSut(dn: Int = 2, sd: Int = 2, mp: String = "") {
        sut.v = [
            .init(
                tg: "",
                vp: "",
                mp: mp,
                ma: "",
                dn: dn,
                sd: sd,
                dt: Date(),
                co: "",
                is: "",
                ci: ""
            )
        ]
    }

    func testIs1of2Vaccination_2_of_1() {
        // Given
        configureSut(dn: 2, sd: 1)

        // When
        let is1Of2 = sut.is1of2Vaccination

        // Then
        XCTAssertFalse(is1Of2)
    }

    func testIs1of2Vaccination_1_of_1() {
        // Given
        configureSut(dn: 1, sd: 1)

        // When
        let is1Of2 = sut.is1of2Vaccination

        // Then
        XCTAssertFalse(is1Of2)
    }

    func testIs1of2Vaccination_1_of_2() {
        // Given
        configureSut(dn: 1, sd: 2)

        // When
        let is1Of2 = sut.is1of2Vaccination

        // Then
        XCTAssertTrue(is1Of2)
    }

    func testIsJohnsonAndJohnson2of2Vaccination() {
        // Given
        configureSut(dn: 2, sd: 2, mp: "EU/1/20/1525")

        // When
        let isJohnsonAndJohnson2of2Vaccination = sut.isJohnsonAndJohnson2of2Vaccination

        // Then
        XCTAssertTrue(isJohnsonAndJohnson2of2Vaccination)
    }

    func testJoinCertificates_empty() {
        // Given
        let sut: [DigitalGreenCertificate] = []

        // When
        let dgc = sut.joinCertificates()

        // Then
        XCTAssertNil(dgc)
    }

    func testJoinCertificates_certificate_one_certificate() {
        // Given
        let givenDgc = CBORWebToken.mockRecoveryCertificate.hcert.dgc
        let sut: [DigitalGreenCertificate] = [givenDgc]

        // When
        let dgc = sut.joinCertificates()

        // Then
        guard let dgc = dgc else {
            XCTFail("dgc must not be nil.")
            return
        }
        XCTAssertNil(dgc.v)
        XCTAssertEqual(dgc.r?.count, 1)
        XCTAssertNil(dgc.t)
    }

    func testJoinCertificates_certificate_holder_do_not_match() {
        // Given
        let dgc1 = CBORWebToken.mockRecoveryCertificate.hcert.dgc
        let dgc2 = CBORWebToken.mockVaccinationCertificateWithOtherName.hcert.dgc
        let sut: [DigitalGreenCertificate] = [dgc1, dgc2]

        // When
        let dgc = sut.joinCertificates()

        // Then
        XCTAssertNotNil(dgc)
    }

    func testJoinCertificates_multiple_certifcates() {
        // Given
        var dgc1 = CBORWebToken.mockRecoveryCertificate.hcert.dgc
        dgc1.t = [testOldest, testOldest, testMiddle]

        var dgc2 = CBORWebToken.mockVaccinationCertificate.hcert.dgc
        dgc2.t = [testOldest, testLatest, testMiddle, testOldest]
        dgc2.r = [recoveryMiddle, recoveryLatest, recoveryMiddle, recoveryOldest, recoveryMiddle]

        var dgc3 = CBORWebToken.mockTestCertificate.hcert.dgc
        dgc3.v = [vaccinationMiddle, vaccinationLatest, vaccinationOldest]

        let sut: [DigitalGreenCertificate] = [dgc1, dgc2, dgc3]

        // When
        let dgc = sut.joinCertificates()

        // Then
        XCTAssertEqual(dgc?.v?.count, 1)
        XCTAssertEqual(dgc?.v?.first?.ci, vaccinationLatest.ci)
        XCTAssertNotEqual(dgc?.v?.first?.ci, vaccinationMiddle.ci)
        XCTAssertNotEqual(dgc?.v?.first?.ci, vaccinationOldest.ci)
        XCTAssertEqual(dgc?.r?.count, 1)
        XCTAssertEqual(dgc?.r?.first?.ci, recoveryLatest.ci)
        XCTAssertNotEqual(dgc?.r?.first?.ci, recoveryMiddle.ci)
        XCTAssertNotEqual(dgc?.r?.first?.ci, recoveryOldest.ci)
        XCTAssertEqual(dgc?.t?.count, 1)
        XCTAssertEqual(dgc?.t?.first?.ci, testLatest.ci)
        XCTAssertNotEqual(dgc?.t?.first?.ci, testMiddle.ci)
        XCTAssertNotEqual(dgc?.t?.first?.ci, testOldest.ci)
    }

    func test_joinCertificates_all_multiple_certifcates() {
        // Given
        let token = CBORWebToken.mockRecoveryCertificate
        token.hcert.dgc.r?.first?.fr = .init()
        var dgc1 = token.hcert.dgc
        dgc1.t = [testOldest, testMiddle]

        let token2 = CBORWebToken.mockVaccinationCertificate
        token2.hcert.dgc.v?.first?.dt = .init()
        var dgc2 = token2.hcert.dgc
        dgc2.t = [testLatest]
        dgc2.r = [recoveryMiddle, recoveryLatest, recoveryOldest]

        let token3 = CBORWebToken.mockTestCertificate
        token3.hcert.dgc.t?.first?.sc = .init()
        var dgc3 = token3.hcert.dgc
        dgc3.v = [vaccinationMiddle, vaccinationLatest, vaccinationOldest]

        let sut: [DigitalGreenCertificate] = [dgc1, dgc2, dgc3]

        // When
        let dgc = sut.joinCertificates(latestOnly: false)

        // Then
        XCTAssertEqual(dgc?.v?.count, 4)
        XCTAssertEqual(dgc?.v?.first?.ci, vaccinationLatest.ci)
        XCTAssertEqual(dgc?.v?.last?.ci, vaccinationOldest.ci)
        XCTAssertEqual(dgc?.r?.count, 4)
        XCTAssertEqual(dgc?.r?.first?.ci, recoveryLatest.ci)
        XCTAssertEqual(dgc?.r?.last?.ci, recoveryOldest.ci)
        XCTAssertEqual(dgc?.t?.count, 4)
        XCTAssertEqual(dgc?.t?.first?.ci, testLatest.ci)
        XCTAssertEqual(dgc?.t?.last?.ci, testOldest.ci)
    }
}

private let vaccinationLatest = Vaccination(tg: "", vp: "", mp: "", ma: "", dn: 0, sd: 0, dt: .init(), co: "", is: "", ci: "latest")
private let vaccinationMiddle = Vaccination(tg: "", vp: "", mp: "", ma: "", dn: 0, sd: 0, dt: .init() - 100, co: "", is: "", ci: "middle")
private let vaccinationOldest = Vaccination(tg: "", vp: "", mp: "", ma: "", dn: 0, sd: 0, dt: .init() - 1000, co: "", is: "", ci: "oldest")
private let recoveryLatest = Recovery(tg: "", fr: .init(), df: .init(), du: .init(), co: "", is: "", ci: "1")
private let recoveryMiddle = Recovery(tg: "", fr: .init() - 1, df: .init(), du: .init(), co: "", is: "", ci: "2")
private let recoveryOldest = Recovery(tg: "", fr: .init() - 1000, df: .init(), du: .init(), co: "", is: "", ci: "3")
private let testLatest = Test(tg: "", tt: "", sc: .init() + 10000, tr: "", tc: nil, co: "", is: "", ci: "4")
private let testMiddle = Test(tg: "", tt: "", sc: .init() + 100, tr: "", tc: nil, co: "", is: "", ci: "5")
private let testOldest = Test(tg: "", tt: "", sc: .init() - 10000, tr: "", tc: nil, co: "", is: "", ci: "6")

private let secondsPerHour: TimeInterval = 60 * 60
private let secondsPerDay: TimeInterval = 24 * secondsPerHour
