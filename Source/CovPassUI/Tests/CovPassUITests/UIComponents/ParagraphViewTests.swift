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
        sut.attributedTitleText = expectedText

        // Then
        XCTAssertEqual(sut.titleLabel.attributedText, expectedText)
    }

    func testSetBodyText() {
        // Given
        let expectedText = "Body".styledAs(.body)

        // When
        sut.attributedTitleText = expectedText

        // Then
        XCTAssertEqual(sut.titleLabel.attributedText, expectedText)
    }

    func testAccessibility_titleSetOnly() {
        // Given
        let titleText = "Body"

        // When
        sut.attributedTitleText = titleText.styledAs(.header_3)
        sut.attributedBodyText = nil

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
        sut.attributedTitleText = nil
        sut.attributedSubtitleText = nil
        sut.attributedBodyText = bodyText.styledAs(.body)

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
        sut.attributedTitleText = titleText.styledAs(.header_3)
        sut.attributedBodyText = bodyText.styledAs(.body)

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
        sut.attributedTitleText = testText.styledAs(.header_3)
        sut.attributedBodyText = testText.styledAs(.body)
        // Then
        XCTAssertFalse(sut.isHidden)
    }

    func testVisibilityTrue_titleText() {
        // Given
        // When
        sut.attributedTitleText = testText.styledAs(.header_3)
        sut.attributedBodyText = nil
        // Then
        XCTAssertFalse(sut.isHidden)
    }

    func testVisibilityTrue_bodyText() {
        // Given
        // When
        sut.attributedTitleText = testText.styledAs(.header_3)
        sut.attributedBodyText = "".styledAs(.body)
        // Then
        XCTAssertFalse(sut.isHidden)
    }

    func testVisibilityFalse() {
        // Given
        // When
        sut.attributedTitleText = "".styledAs(.header_3)
        sut.attributedBodyText = "".styledAs(.body)
        // Then
        XCTAssertTrue(sut.isHidden)
    }

    func testSetTitleAndBodyText() {
        let otherTestText = "Other test text"
        sut.attributedTitleText = otherTestText.styledAs(.header_3)
        sut.attributedBodyText = testText.styledAs(.body)
        XCTAssertEqual(sut.titleLabel.text, otherTestText)
        XCTAssertEqual(sut.bodyLabel.text, testText)
    }
}
