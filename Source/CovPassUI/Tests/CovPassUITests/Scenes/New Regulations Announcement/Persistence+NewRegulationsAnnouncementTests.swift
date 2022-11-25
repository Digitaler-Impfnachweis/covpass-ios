//
//  Persistence+NewRegulationsAnnouncementTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
@testable import CovPassUI
import XCTest

final class Persistence_NewRegulationsAnnouncementTests: XCTestCase {
    private var sut: Persistence!
    override func setUpWithError() throws {
        sut = MockPersistence()
    }

    override func tearDownWithError() throws {
        sut = nil
    }

    func testNewRegulationsOnboardingScreenWasShown_default() throws {
        // When
        let newRegulationsOnboardingScreenWasShown = sut.newRegulationsOnboardingScreenWasShown

        // Then
        XCTAssertFalse(newRegulationsOnboardingScreenWasShown)
    }

    func testNewRegulationsOnboardingScreenWasShown__true() throws {
        // Given
        sut.newRegulationsOnboardingScreenWasShown = true

        // When
        let newRegulationsOnboardingScreenWasShown = sut.newRegulationsOnboardingScreenWasShown

        // Then
        XCTAssertTrue(newRegulationsOnboardingScreenWasShown)
    }
}
