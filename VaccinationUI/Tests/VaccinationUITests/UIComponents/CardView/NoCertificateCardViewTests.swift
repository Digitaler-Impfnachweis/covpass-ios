//
//  NoCertificateCardViewTests.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

@testable import VaccinationUI
import XCTest

class NoCertificateCardViewTests: XCTestCase {
    var sut: NoCertificateCardView!

    override func setUp() {
        super.setUp()
        sut = NoCertificateCardView()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }
    
    func testSutNotNil() {
        XCTAssertNotNil(sut)
    }

    func testInit() {
        XCTAssertNotNil(sut.topImageView)
        XCTAssertNotNil(sut.titleLabel)
        XCTAssertNotNil(sut.textLable)
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

