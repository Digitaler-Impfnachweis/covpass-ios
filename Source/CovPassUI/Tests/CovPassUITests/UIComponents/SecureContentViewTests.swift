//
//  SecureContentViewTests.swift
//  
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import XCTest

@testable import CovPassUI

class SecureContentViewTests: XCTestCase {
    var sut: SecureContentView!

    override func setUp() {
        super.setUp()

        sut = SecureContentView()
    }

    override func tearDown() {
        sut = nil

        super.tearDown()
    }

    func testInit() {
        XCTAssertEqual(sut.stackView.spacing, .space_16)
        XCTAssertEqual(sut.textStackView.spacing, .space_2)
        XCTAssertEqual(sut.imageView.tintColor, .brandAccent)
    }

    func testUpdateView() {
        sut.titleAttributedString = NSAttributedString(string: "Test title")
        sut.bodyAttributedString = NSAttributedString(string: "Test body")

        XCTAssertEqual(sut.titleLabel.attributedText, NSAttributedString(string: "Test title"))
        XCTAssertEqual(sut.bodyLabel.attributedText, NSAttributedString(string: "Test body"))
        XCTAssertTrue(sut.isAccessibilityElement)
    }
}
