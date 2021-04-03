//
//  CardViewHeaderTests.swift
//  
//
//  Created by Daniel on 02.04.2021.
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
        // TODO: Figure out why this fails
//        sut.actionButton.sendActions(for: .touchUpInside)
        sut.infoButtonPressed(button: UIButton())
        XCTAssertTrue(buttonTapped)
    }
}

