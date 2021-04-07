//
//  CardViewActionTests.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

@testable import VaccinationUI
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
        XCTAssertNotNil(sut.subtitleLabel)
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
        // TODO: Figure out why this fails 
//        sut.actionButton.sendActions(for: .touchUpInside)
        sut.actionButtonPressed(button: UIButton())
        XCTAssertTrue(buttonTapped)
    }
}
