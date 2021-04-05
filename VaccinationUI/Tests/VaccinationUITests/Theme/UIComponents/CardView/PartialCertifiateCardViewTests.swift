//
//  PartialCertifiateCardViewTests.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

@testable import VaccinationUI
import XCTest

class PartialCertifiateCardViewTests: XCTestCase {
    var sut: PartialCertifiateCardView!

    override func setUp() {
        super.setUp()
        sut = PartialCertifiateCardView()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testSutNotNil() {
        XCTAssertNotNil(sut)
    }

    func testInit() {
        XCTAssertNotNil(sut.headerView)
        XCTAssertNotNil(sut.actionView)
        XCTAssertNotNil(sut.continerView)
        XCTAssertNotNil(sut.actionButton)
    }
    
    func testCornerRadius() {
        sut.cornerRadius = 20
        XCTAssertEqual(sut.cornerRadius, sut.layer.cornerRadius)
    }
    
    func testBorderWidth() {
        sut.borderWidth = 20
        XCTAssertEqual(sut.borderWidth, sut.layer.borderWidth)
    }
    
    func testBorderColor() {
        sut.borderColor = UIColor.black
        XCTAssertTrue(sut.borderColor?.cgColor === sut.layer.borderColor)
    }
    
    func testCardBackgroundColor() {
        sut.cardBackgroundColor = UIColor.black
        XCTAssertTrue(sut.cardBackgroundColor === sut.backgroundColor)
    }
    
    func testCardTintColor() {
        sut.cardTintColor = UIColor.black
        XCTAssertTrue(sut.cardTintColor === sut.tintColor)
    }
}

