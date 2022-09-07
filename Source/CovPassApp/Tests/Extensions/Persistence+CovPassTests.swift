//
//  Persistence+CovPass.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassApp
import CovPassCommon
import XCTest

class Persistence_CovPass: XCTestCase {
    private var sut: Persistence!

    override func setUpWithError() throws {
        sut = MockPersistence()
    }

    override func tearDownWithError() throws {
        sut = nil
    }

    func testNewRegulationsOnboardingScreenWasShown_default() {
        // When
        let wasShown = sut.newRegulationsOnboardingScreenWasShown

        // Then
        XCTAssertFalse(wasShown)
    }

    func testNewRegulationsOnboardingScreenWasShown_set() {
        // Given
        sut .newRegulationsOnboardingScreenWasShown = true

        // When
        let wasShown = sut.newRegulationsOnboardingScreenWasShown

        // Then
        XCTAssertTrue(wasShown)
    }
}
