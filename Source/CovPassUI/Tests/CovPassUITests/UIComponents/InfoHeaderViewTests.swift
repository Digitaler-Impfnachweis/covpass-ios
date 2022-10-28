//
//  InfoHeaderViewTests.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import XCTest

@testable import CovPassUI

class InfoHeaderViewTests: XCTestCase {
    var sut: InfoHeaderView!

    override func setUp() {
        super.setUp()

        sut = InfoHeaderView()
    }

    override func tearDown() {
        sut = nil

        super.tearDown()
    }

    func testInit() {
        sut.attributedTitleText = NSAttributedString(string: "Test string")
        sut.image = .cancel

        XCTAssertEqual(sut.textLabel.attributedText, NSAttributedString(string: "Test string"))
        XCTAssertEqual(sut.actionButton.innerButton.imageView?.image, .cancel)
        XCTAssertEqual(sut.layoutMargins, .init(top: .zero, left: .space_24, bottom: .zero, right: .space_14))
    }

    func testTextLabel() throws {
        // When
        let textLabel = try XCTUnwrap(sut.textLabel)

        // Then
        XCTAssertTrue(textLabel.accessibilityTraits.contains(.header))
    }
}
