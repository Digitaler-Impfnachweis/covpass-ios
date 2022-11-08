//
//  Persistence+ValidatorOverviewTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCheckApp
import CovPassCommon
import XCTest

class Persistence_ValidatorOverviewTests: XCTestCase {
    private var sut: Persistence!
    override func setUpWithError() throws {
        sut = MockPersistence()
    }

    override func tearDownWithError() throws {
        sut = nil
    }

    func testValidatorOverviewCheckType_default() {
        // When
        let scanType = sut.selectedCheckType

        // Then
        XCTAssertNotNil(scanType)
        XCTAssertEqual(scanType, CheckType.mask.rawValue)
    }

    func testValidatorOverviewCheckType_set() {
        // Given
        sut.selectedCheckType = CheckType.immunity.rawValue

        // When
        let scanType = sut.selectedCheckType

        // Then
        XCTAssertEqual(scanType, CheckType.immunity.rawValue)
    }

}
