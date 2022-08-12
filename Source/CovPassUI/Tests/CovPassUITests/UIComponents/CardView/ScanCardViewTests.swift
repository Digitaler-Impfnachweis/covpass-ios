//
//  ScanCardViewTests.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import XCTest

@testable import CovPassUI

class ScanCardViewTests: XCTestCase {
    var sut: ScanCardView!

    override func setUp() {
        super.setUp()

        sut = ScanCardView()
    }

    override func tearDown() {
        sut = nil

        super.tearDown()
    }

    func testInit() {
        XCTAssertEqual(sut.contentView?.layoutMargins, .init(top: 0, left: 0, bottom: 0, right: 0))
        XCTAssertEqual(sut.contentView?.backgroundColor, .brandBase)
        XCTAssertEqual(sut.contentView?.layer.cornerRadius, 14)
        XCTAssertEqual(sut.contentView?.layer.shadowColor, UIColor.neutralBlack.cgColor)
        XCTAssertEqual(sut.contentView?.layer.shadowRadius, 16)
        XCTAssertEqual(sut.contentView?.layer.shadowOpacity, Float(0.2))
        XCTAssertEqual(sut.contentView?.layer.shadowOffset, .init(width: 0, height: -4))
        XCTAssertEqual(sut.actionButton.style, .secondary)
        XCTAssertEqual(sut.actionButton.icon, .scan)
    }

    func testUpdateAccessibility() {
        // Given
        let text = NSAttributedString(string: "TEXT")
        sut.switchTextLabel.attributedText = text

        // When
        sut.updateAccessibility()

        // Then
        let elements = sut.switchWrapperView.accessibilityElements
        XCTAssertEqual(elements?.count, 1)
        XCTAssertEqual(elements?.first as? UISwitch, sut.uiSwitch)
        XCTAssertEqual(sut.uiSwitch.accessibilityAttributedLabel, text)
        XCTAssertFalse(sut.switchTextLabel.isAccessibilityElement)
    }
}
