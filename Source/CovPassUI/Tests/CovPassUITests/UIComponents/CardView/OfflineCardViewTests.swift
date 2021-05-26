//
//  OfflineCardViewTests.swift
//  
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import XCTest

@testable import CovPassUI

class OfflineCardViewTests: XCTestCase {
    var sut: OfflineCardView!

    override func setUp() {
        super.setUp()

        sut = OfflineCardView()
    }

    override func tearDown() {
        sut = nil

        super.tearDown()
    }

    func testInit() {
        XCTAssertEqual(sut.contentView?.layoutMargins, .init(top: .space_18, left: .space_24, bottom: .space_18, right: .space_24))
        XCTAssertEqual(sut.contentView?.backgroundColor, .brandAccent10)
        XCTAssertEqual(sut.contentView?.layer.cornerRadius, 14)
    }
}
