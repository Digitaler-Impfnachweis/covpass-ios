//
//  BoosterCandidateTests.swift
//  
//
//  Created by Thomas Kuleßa on 09.02.22.
//

import XCTest
import CovPassCommon

class BoosterCandidateTests: XCTestCase {
    private var extendedCBORWebToken: ExtendedCBORWebToken!
    private var sut: BoosterCandidate!

    override func setUpWithError() throws {
        extendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        sut = BoosterCandidate(certificate: extendedCBORWebToken)
    }

    override func tearDownWithError() throws {
        extendedCBORWebToken = nil
        sut = nil
    }

    func testVaccinationIdentifier() {
        // Given
        let expectedVaccinationIdentifier = extendedCBORWebToken.vaccinationCertificate.hcert.dgc.uvci

        // When
        let vaccinationIdentifier = sut.vaccinationIdentifier

        // Then
        XCTAssertEqual(vaccinationIdentifier, expectedVaccinationIdentifier)
    }

    func testState() {
        // When
        let state = sut.state

        // Then
        XCTAssertEqual(state, .none)
    }

    func testValidationRules() {
        // When
        let validationRules = sut.validationRules

        // Then
        XCTAssertTrue(validationRules.isEmpty)
    }

    func testBoosterCandidateEquatable_equal() {
        // Given
        let suts: [BoosterCandidate] = [
            .init(certificate: CBORWebToken.mockVaccinationCertificate.extended()),
            .init(certificate: CBORWebToken.mockVaccinationCertificate.extended())
        ]

        // When & Then
        XCTAssertEqual(suts[0], suts[1])
    }

    func testBoosterCandidateEquatable_not_equal_name() {
        // Given
        let differentName = Name(gn: nil, fn: nil, gnt: "ANGELIKA", fnt: "MUSTERMANN")
        var otherExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        otherExtendedCBORWebToken.vaccinationCertificate.hcert.dgc.nam = differentName
        let suts: [BoosterCandidate] = [
            sut,
            .init(certificate: otherExtendedCBORWebToken)
        ]

        // When & Then
        XCTAssertNotEqual(suts[0], suts[1])
    }

    func testBoosterCandidateEquatable_not_equal_date_of_birth() {
        // Given
        let differentDate = Date(timeIntervalSinceReferenceDate: 0)
        var otherExtendedCBORWebToken = CBORWebToken.mockVaccinationCertificate.extended()
        otherExtendedCBORWebToken.vaccinationCertificate.hcert.dgc.dob = differentDate
        let suts: [BoosterCandidate] = [
            sut,
            .init(certificate: otherExtendedCBORWebToken)
        ]

        // When & Then
        XCTAssertNotEqual(suts[0], suts[1])
    }
}
