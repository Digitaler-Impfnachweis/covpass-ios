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
        XCTAssertEqual(sut.contentView?.layoutMargins, .init(top: .space_18, left: .space_24, bottom: .space_40, right: .space_24))
        XCTAssertEqual(sut.contentView?.backgroundColor, .brandBase)
        XCTAssertEqual(sut.contentView?.layer.cornerRadius, 14)
        XCTAssertEqual(sut.contentView?.layer.shadowColor, UIColor.neutralBlack.cgColor)
        XCTAssertEqual(sut.contentView?.layer.shadowRadius, 16)
        XCTAssertEqual(sut.contentView?.layer.shadowOpacity, Float(0.2))
        XCTAssertEqual(sut.contentView?.layer.shadowOffset, .init(width: 0, height: -4))
        XCTAssertEqual(sut.actionButton.style, .secondary)
        XCTAssertEqual(sut.actionButton.icon, .scan)
    }
}
