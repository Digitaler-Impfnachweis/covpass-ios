//
//  QRContainerViewTests.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import XCTest

@testable import CovPassUI

class QRContainerViewTests: XCTestCase {
    var sut: QRContainerView!

    override func setUp() {
        super.setUp()

        sut = QRContainerView()
    }

    override func tearDown() {
        sut = nil

        super.tearDown()
    }

    func testInit() {
        XCTAssertEqual(sut.contentView?.layoutMargins, .init(top: .space_10, left: .space_10, bottom: .space_10, right: .space_10))
        XCTAssertEqual(sut.contentView?.layer.cornerRadius, 10)
        XCTAssertEqual(sut.contentView?.layer.masksToBounds, true)
    }

    func testUpdateViews() {
        sut.image = .arrowBack
        sut.title = "Test title"
        sut.subtitle = "Test subtitle"

        XCTAssertEqual(sut.imageView.image, .arrowBack)
        XCTAssertEqual(sut.contentView?.backgroundColor, .neutralWhite)

        XCTAssertEqual(sut.titleLabel.attributedText, "Test title".styledAs(.header_2).colored(.neutralBlack))
        XCTAssertFalse(sut.titleLabel.isHidden)

        XCTAssertEqual(sut.subtitleLabel.attributedText, "Test subtitle".styledAs(.body).colored(.neutralBlack))
        XCTAssertFalse(sut.subtitleLabel.isHidden)
    }
}
