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

    func testValidatorOverviewScanType_default() {
        // When
        let scanType = sut.validatorOverviewScanType

        // Then
        XCTAssertNil(scanType)
    }

    func testValidatorOverviewScanType_set() {
        // Given
        sut.validatorOverviewScanType = ._3G

        // When
        let scanType = sut.validatorOverviewScanType

        // Then
        XCTAssertEqual(scanType, ._3G)
    }

    func testValidatorOverviewBoosterAsTest_default() {
        // When
        let boosterAsTest = sut.validatorOverviewBoosterAsTest

        // Then
        XCTAssertFalse(boosterAsTest)
    }

    func testValidatorOverviewBoosterAsTest_set() {
        // Given
        sut.validatorOverviewBoosterAsTest = true

        // When
        let boosterAsTest = sut.validatorOverviewBoosterAsTest

        // Then
        XCTAssertTrue(boosterAsTest)
    }
}
