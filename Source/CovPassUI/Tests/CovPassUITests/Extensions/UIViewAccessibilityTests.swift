//
//  UIViewAccessibilityTests.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassUI
import XCTest

class UIViewAccessibilityTests: XCTestCase {
    var sut: UILabel!

    override func setUp() {
        super.setUp()
        sut = UILabel()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testEnableAccessibility() {
        // When
        sut.isAccessibilityElement = false
        sut.enableAccessibility()
        // Then
        XCTAssertTrue(sut.isAccessibilityElement)

        // When
        let testLabel = "Test label"
        sut.accessibilityLabel = nil
        sut.enableAccessibility(label: testLabel)
        // Then
        XCTAssertEqual(sut.accessibilityLabel, testLabel)

        // When
        let testHint = "Test hint"
        sut.accessibilityHint = nil
        sut.enableAccessibility(hint: testHint)
        // Then
        XCTAssertEqual(sut.accessibilityHint, testHint)

        // When
        let testTraits: UIAccessibilityTraits = .button
        sut.accessibilityTraits = .none
        sut.enableAccessibility(traits: testTraits)
        // Then
        XCTAssertEqual(sut.accessibilityTraits, testTraits)
    }

    func testDisableAccessibility() {
        // When
        sut.isAccessibilityElement = true
        sut.disableAccessibility()
        // Then
        XCTAssertFalse(sut.isAccessibilityElement)
    }
}
