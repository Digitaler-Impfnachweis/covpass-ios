//
//  ParagraphViewTests.swift
//  
//
//  Copyright © 2021 IBM. All rights reserved.
//

@testable import VaccinationUI
import XCTest

class ParagraphViewTests: XCTestCase {
    var sut: ParagraphView!
    let testText = "TestText"

    override func setUp() {
        super.setUp()
        sut = ParagraphView()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testInitWithCoder() {
        let paragraphWithCoder = ParagraphView(coder: CoderMock.unarchivedCoder)
        XCTAssertNotNil(paragraphWithCoder?.contentView, "Paragraph contentView should exist.")
    }

    func testInitWithFrame() {
        let paragraphWithCoder = ParagraphView(frame: CGRect.zero)
        XCTAssertNotNil(paragraphWithCoder.contentView, "Paragraph contentView should exist.")
    }

    func testStyles() {
        XCTAssertEqual(sut.contentView?.backgroundColor, .clear)
        XCTAssertEqual(sut.body.backgroundColor, .clear)
        XCTAssertEqual(sut.title.font, UIFontMetrics.default.scaledFont(for: UIConstants.Font.semiBold))
        XCTAssertTrue(sut.title.adjustsFontForContentSizeCategory)
        XCTAssertEqual(sut.title.textColor, UIConstants.BrandColor.onBackground100)
        XCTAssertEqual(sut.body.font, UIFontMetrics.default.scaledFont(for: UIConstants.Font.regular))
        XCTAssertTrue(sut.body.adjustsFontForContentSizeCategory)
        XCTAssertEqual(sut.body.textColor, UIConstants.BrandColor.onBackground100)
        XCTAssertNotNil(sut.bodyFont)
    }

    func testInitView() {
        XCTAssertNotNil(sut.title)
        XCTAssertNotNil(sut.body)
        XCTAssertFalse(sut.hasTitle)
    }

    func testSetTitleText() {
        // Given
        // When
        sut.titleText = testText
        // Then
        XCTAssertEqual(sut.title.text, testText)
    }

    func testSetBodyText() {
        // Given
        // When
        sut.bodyText = testText
        // Then
        XCTAssertEqual(sut.body.text, testText)
    }

    func testAccessibility_titleSetOnly() {
        // Given
        let titleText = "Some title text"

        // When
        sut.titleText = titleText
        sut.bodyText = nil

        // Then
        XCTAssertTrue(sut.isAccessibilityElement)
        XCTAssertEqual(sut.accessibilityLabel, "\(titleText) ")
        XCTAssertNil(sut.accessibilityHint)
        XCTAssertEqual(sut.accessibilityTraits, .staticText)
    }

    func testAccessibility_bodySetOnly() {
        // Given
        let bodyText = "Some body text"

        // When
        sut.titleText = nil
        sut.bodyText = bodyText

        // Then
        XCTAssertTrue(sut.isAccessibilityElement)
        XCTAssertEqual(sut.accessibilityLabel, " \(bodyText)")
        XCTAssertNil(sut.accessibilityHint)
        XCTAssertEqual(sut.accessibilityTraits, .staticText)
    }

    func testAccessibility_bothTitleAndBodyAreSet() {
        // Given
        let bodyText = "Some body text"
        let titleText = "Some title text"

        // When
        sut.titleText = titleText
        sut.bodyText = bodyText

        // Then
        XCTAssertTrue(sut.isAccessibilityElement)
        XCTAssertEqual(sut.accessibilityLabel, "\(titleText) \(bodyText)")
        XCTAssertNil(sut.accessibilityHint)
        XCTAssertEqual(sut.accessibilityTraits, .staticText)
    }

    func testVisibilityTrue_bothTexts() {
        // Given
        // When
        sut.bodyText = testText
        sut.titleText = testText
        // Then
        XCTAssertFalse(sut.isHidden)
    }

    func testVisibilityTrue_titleText() {
        // Given
        // When
        sut.bodyText = ""
        sut.titleText = testText
        // Then
        XCTAssertFalse(sut.isHidden)
    }

    func testVisibilityTrue_bodyText() {
        // Given
        // When
        sut.bodyText = testText
        sut.titleText = ""
        // Then
        XCTAssertFalse(sut.isHidden)
    }

    func testVisibilityFalse() {
        // Given
        // When
        sut.bodyText = ""
        sut.titleText = ""
        // Then
        XCTAssertTrue(sut.isHidden)
    }

    func testSetBodyFont() {
        // Given
        guard let bodyFont1 = sut.bodyFont else {
            XCTFail("'bodyFont' should be setuped!")
            return
        }

        let testFont = UIFont(descriptor: bodyFont1.fontDescriptor, size: bodyFont1.fontDescriptor.pointSize + 3)
        XCTAssertNotEqual(UIFont(descriptor: bodyFont1.fontDescriptor, size: bodyFont1.fontDescriptor.pointSize), testFont)
        // When
        sut.bodyFont = testFont
        // Then
        guard let bodyFont2 = sut.bodyFont else {
            XCTAssert(false, "'bodyFont' should be setuped for this case")
            return
        }
        XCTAssertEqual(bodyFont2, testFont)
        XCTAssertEqual(sut.body.linkTextFont, testFont)
        XCTAssertTrue(sut.body.adjustsFontForContentSizeCategory)
        XCTAssertEqual(sut.body.font, UIFontMetrics.default.scaledFont(for: testFont))
    }

    func testSetTitleAndBodyText() {
        let otherTestText = "Other test text"
        sut.titleText = otherTestText
        sut.bodyText = testText
        XCTAssertEqual(sut.title.text, otherTestText)
        XCTAssertEqual(sut.body.text, testText)
    }

    func testTitleVisibility() {
        // When
        sut.hasTitle = false
        // Then
        XCTAssertNil(sut.title.superview)
    }
}
