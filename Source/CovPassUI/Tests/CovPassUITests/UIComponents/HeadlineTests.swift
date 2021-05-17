//
//  HeadlineTests.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassUI
import XCTest

class HeadlineTests: XCTestCase {
    var sut: PlainLabel!

    override func setUp() {
        super.setUp()
        sut = PlainLabel(frame: .zero)
        sut.initView()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testInitWithFrame() {
        XCTAssertNotNil(sut.contentView)
    }

    func testInitWithCoder() {
        let sut = PlainLabel(coder: CoderMock.unarchivedCoder)
        XCTAssertNotNil(sut?.contentView)
    }

    func testOutlets() {
        XCTAssertNotNil(sut.textableView)
    }

    func testInitView() {
        XCTAssertTrue(sut.textableView.adjustsFontForContentSizeCategory)
        XCTAssertEqual(sut.textableView.numberOfLines, 0)

        XCTAssertTrue(sut.textableView.adjustsFontForContentSizeCategory)
        XCTAssertEqual(sut.textableView.numberOfLines, 0)
    }
}
