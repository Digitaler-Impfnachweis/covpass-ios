//
//  CBORWebToken+GProofViewModelTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCheckApp
import CovPassCommon
import XCTest

class CBORWebToken_GProofViewModelTests: XCTestCase {
    func testVaccinationSubtitle_2_of_2_johnson_and_johnson() {
        // Given
        let sut = CBORWebToken
            .mockVaccinationCertificate
            .doseNumber(2)
            .seriesOfDoses(2)
            .medicalProduct(.johnsonjohnson)
            .mockVaccinationSetDate(Date())

        // When
        let subtitle = sut.vaccinationSubtitle

        // Then
        XCTAssertEqual(subtitle, "0 month(s) ago")
    }
}
