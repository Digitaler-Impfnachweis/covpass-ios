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
        XCTAssertEqual(sut.qrContainerView?.layoutMargins, .init(top: .space_8, left: .space_8, bottom: .space_8, right: .space_8))
        XCTAssertEqual(sut.qrContainerView?.layer.cornerRadius, 0)
        XCTAssertEqual(sut.qrContainerView?.layer.masksToBounds, true)
    }

    func testUpdateViews() {
        sut.image = .arrowBack
        sut.titleLabel.attributedText = "Test title".styledAs(.header_2).colored(.neutralBlack)
        sut.subtitleLabel.attributedText = "Test subtitle".styledAs(.body).colored(.neutralBlack)
        sut.image = .arrowBack // Trigger updateviews

        XCTAssertEqual(sut.imageView.image, .arrowBack)
        XCTAssertNil(sut.qrContainerView?.backgroundColor)

        XCTAssertFalse(sut.titleLabel.isHidden)
        XCTAssertFalse(sut.subtitleLabel.isHidden)
    }
}
