//
//  GProofValidationResult+GProofViewModelTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCheckApp
import CovPassCommon
import XCTest

class GProofValidationResult_GProofViewModelTests: XCTestCase {
    func testVaccinationTitle_2_of_2_johnson_and_johnson() {
        // Given
        let token = CBORWebToken
            .mockVaccinationCertificate
            .doseNumber(2)
            .seriesOfDoses(2)
            .medicalProduct(.johnsonjohnson)
            .extended()
        let sut: GProofValidationResult? = GProofValidationResult(
            token: token,
            error: nil,
            result: nil
        )

        // When
        let title = sut.vaccinationTitle(initialTokenIsBoosted: false)

        // Then
        XCTAssertEqual(title, "Basic immunisation")
    }
}
