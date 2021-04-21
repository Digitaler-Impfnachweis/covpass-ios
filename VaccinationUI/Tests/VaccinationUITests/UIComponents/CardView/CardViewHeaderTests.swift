//
//  CardViewHeaderTests.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

@testable import VaccinationUI
import XCTest

class CardViewHeaderTests: XCTestCase {
    var sut: CardViewHeader!

    override func setUp() {
        super.setUp()
        sut = CardViewHeader()
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
        XCTAssertNotNil(sut.subtitleLabel)
        XCTAssertNotNil(sut.leftButton)
    }
    
    func testButtonImage() {
        let image = UIImage()
        sut.buttonImage = image
        XCTAssertTrue(sut.buttonImage === sut.leftButton.currentImage)
    }
    
    func testButtonAction() {
        var buttonTapped = false
        sut.action = {
            buttonTapped = true
        }
        sut.infoButtonPressed(button: UIButton())
        XCTAssertTrue(buttonTapped)
    }
}

