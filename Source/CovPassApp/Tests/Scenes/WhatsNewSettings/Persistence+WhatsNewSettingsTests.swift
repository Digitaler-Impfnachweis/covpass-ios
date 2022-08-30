//
//  Persistence+WhatsNewSettingsTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassApp
import CovPassCommon
import XCTest

class Persistence_WhatsNewSettingsTests: XCTestCase {
    private var sut: Persistence!
    override func setUpWithError() throws {
        sut = MockPersistence()
    }

    override func tearDownWithError() throws {
        sut = nil
    }

    func testDisableWhatsNew_default() throws {
        // When
        let isDisabled = sut.disableWhatsNew

        // Then
        XCTAssertFalse(isDisabled)
    }

    func testdisableWhatsNew_true() throws {
        // Given
        sut.disableWhatsNew = true

        // When
        let isDisabled = sut.disableWhatsNew

        // Then
        XCTAssertTrue(isDisabled)
    }
}
