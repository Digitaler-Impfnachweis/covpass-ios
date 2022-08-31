//
//  Persistence+AcousticFeedbackSettingsTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCheckApp
import CovPassCommon
import XCTest

class Persistence_AcousticFeedbackSettingsTests: XCTestCase {
    private var sut: Persistence!
    override func setUpWithError() throws {
        sut = MockPersistence()
    }

    override func tearDownWithError() throws {
        sut = nil
    }

    func testEnableAcousticFeedback_default() {
        // When
        let isEnabled = sut.enableAcousticFeedback

        // Then
        XCTAssertFalse(isEnabled)
    }

    func testEnableAcousticFeedback_set() {
        // Given
        sut.enableAcousticFeedback = true
        
        // When
        let isEnabled = sut.enableAcousticFeedback

        // Then
        XCTAssertTrue(isEnabled)
    }
}
