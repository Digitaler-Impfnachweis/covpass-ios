//
//  CardViewActionTests.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassUI
import XCTest

class CardViewActionTests: XCTestCase {
    var sut: CardViewAction!

    override func setUp() {
        super.setUp()
        sut = CardViewAction()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testSutNotNil() {
        XCTAssertNotNil(sut)
    }

    func testInit() {
        XCTAssertNotNil(sut.titleLabel)
        XCTAssertNotNil(sut.contentView)
        XCTAssertNotNil(sut.actionButton)
        XCTAssertNotNil(sut.stateImageView)
    }

    func testButtonImage() {
        let image = UIImage()
        sut.buttonImage = image
        XCTAssertTrue(sut.buttonImage === sut.actionButton.currentImage)
    }

    func testButtonAction() {
        var buttonTapped = false
        sut.action = {
            buttonTapped = true
        }
        sut.actionButtonPressed(button: UIButton())
        XCTAssertTrue(buttonTapped)
    }
}
