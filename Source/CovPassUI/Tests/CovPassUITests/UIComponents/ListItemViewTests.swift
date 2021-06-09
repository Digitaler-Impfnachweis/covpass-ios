//
//  ListItemViewTests.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import XCTest

@testable import CovPassUI

class ListItemViewTests: XCTestCase {
    var sut: ListItemView!

    override func setUp() {
        super.setUp()

        sut = ListItemView()
    }

    override func tearDown() {
        sut = nil

        super.tearDown()
    }

    func testInit() {
        XCTAssertEqual(sut.contentView?.layoutMargins, .init(top: .space_12, left: .space_24, bottom: .space_12, right: .space_24))
        XCTAssertEqual(sut.backgroundColor, .neutralWhite)
        XCTAssertEqual(sut.textLabel.text, "")
        XCTAssertEqual(sut.imageView.image, .chevronRight)
        XCTAssertEqual(sut.seperatorView.backgroundColor, .onBackground20)
        XCTAssertTrue(sut.seperatorView.isHidden)
    }

    func testSeparator() {
        sut.showSeperator = true

        XCTAssertFalse(sut.seperatorView.isHidden)
    }
}
