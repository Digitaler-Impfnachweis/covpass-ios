//
//  DigitalGreenCertificateExtensionTests.swift
//  
//
//  Created by Thomas Kuleßa on 11.05.22.
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

    func testPersonIsYoungerThan18_is_younger() {
        // Given
        let components = DateComponents(year: -18, second: 1)
        let dob = Calendar.current.date(byAdding: components, to: Date())
        sut.dob = dob

        // When
        let isYounger = sut.personIsYoungerThan18

        // Then
        XCTAssertTrue(isYounger)
    }

    func testPersonIsYoungerThan18_dob_is_nil() {
        // When
        let isYounger = sut.personIsYoungerThan18

        // Then
        XCTAssertFalse(isYounger)
    }

    func testPersonIsYoungerThan18_is_18() throws {
        // Given
        let components = DateComponents(year: -18)
        let dob = Calendar.current.date(byAdding: components, to: Date())
        sut.dob = dob

        // When
        let isYounger = sut.personIsYoungerThan18

        // Then
        XCTAssertFalse(isYounger)
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

    private func configureSut(dn: Int = 2, sd: Int = 2) {
        sut.v = [
            .init(
                tg: "",
                vp: "",
                mp: "",
                ma: "",
                dn: dn,
                sd: sd,
                dt: Date(),
                co: "",
                is: "",
                ci: "")
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
}

private let secondsPerHour: TimeInterval = 60*60
private let secondsPerDay: TimeInterval = 24*secondsPerHour
