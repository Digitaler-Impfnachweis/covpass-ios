//
//  ParagraphViewTests.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassUI
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
        XCTAssertTrue(sut.titleLabel.adjustsFontForContentSizeCategory)
        XCTAssertTrue(sut.bodyLabel.adjustsFontForContentSizeCategory)
    }

    func testInitView() {
        XCTAssertNotNil(sut.titleLabel)
        XCTAssertNotNil(sut.bodyLabel)
    }

    func testSetTitleText() {
        // Given
        let expectedText = "Title".styledAs(.header_3)

        // When
        sut.updateView(title: expectedText)

        // Then
        XCTAssertEqual(sut.titleLabel.attributedText, expectedText)
    }

    func testSetBodyText() {
        // Given
        let expectedText = "Body".styledAs(.body)

        // When
        sut.updateView(title: expectedText)

        // Then
        XCTAssertEqual(sut.titleLabel.attributedText, expectedText)
    }

    func testAccessibility_titleSetOnly() {
        // Given
        let titleText = "Body"

        // When
        sut.updateView(title: titleText.styledAs(.header_3))

        // Then
        XCTAssertTrue(sut.isAccessibilityElement)
        XCTAssertEqual(sut.accessibilityLabel, "\(titleText)")
        XCTAssertNil(sut.accessibilityHint)
        XCTAssertEqual(sut.accessibilityTraits, .staticText)
    }

    func testAccessibility_bodySetOnly() {
        // Given
        let bodyText = "Some body text"

        // When
        sut.updateView(body: bodyText.styledAs(.body))
        
        // Then
        XCTAssertTrue(sut.isAccessibilityElement)
        XCTAssertEqual(sut.accessibilityLabel, nil)
        XCTAssertNil(sut.accessibilityHint)
        XCTAssertEqual(sut.accessibilityTraits, .staticText)
    }

    func testAccessibility_bothTitleAndBodyAreSet() {
        // Given
        let bodyText = "Some body text"
        let titleText = "Some title text"

        // When
        sut.updateView(title: titleText.styledAs(.header_3),
                       body: bodyText.styledAs(.body))

        // Then
        XCTAssertTrue(sut.isAccessibilityElement)
        XCTAssertEqual(sut.accessibilityLabel, "\(titleText)")
        XCTAssertEqual(sut.accessibilityValue, "\(bodyText)")
        XCTAssertNil(sut.accessibilityHint)
        XCTAssertEqual(sut.accessibilityTraits, .staticText)
    }

    func testVisibilityTrue_bothTexts() {
        // Given
        // When
        sut.updateView(title: testText.styledAs(.header_3),
                       body: testText.styledAs(.body))
        // Then
        XCTAssertFalse(sut.isHidden)
    }

    func testVisibilityTrue_titleText() {
        // Given
        // When
        sut.updateView(title: testText.styledAs(.header_3))
        // Then
        XCTAssertFalse(sut.isHidden)
    }

    func testVisibilityTrue_bodyText() {
        // Given
        // When
        sut.updateView(title: testText.styledAs(.header_3),
                       body: "".styledAs(.body))
        // Then
        XCTAssertFalse(sut.isHidden)
    }

    func testSetTitleAndBodyText() {
        let otherTestText = "Other test text"
        sut.updateView(title: otherTestText.styledAs(.header_3),
                       body: testText.styledAs(.body))
        XCTAssertEqual(sut.titleLabel.text, otherTestText)
        XCTAssertEqual(sut.bodyLabel.text, testText)
    }
}
