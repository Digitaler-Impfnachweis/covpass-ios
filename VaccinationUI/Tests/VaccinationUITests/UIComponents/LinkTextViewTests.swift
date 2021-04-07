//
//  LinkTextViewTests.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

@testable import VaccinationUI
import XCTest
///
/// Find all occurences in code with regular expression (?<=#).+::.+(?=#)
///

class LinkTextViewTests: LinkActionTests {
    var sut: LinkTextView!

    override func setUp() {
        super.setUp()
        sut = LinkTextView()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testInit() {
        XCTAssertFalse(sut.isEditable)
        XCTAssertTrue(sut.isSelectable)
        XCTAssertTrue(sut.isUserInteractionEnabled)
        XCTAssertEqual(sut.backgroundColor, .clear)
        XCTAssertEqual(sut.linkColor, UIConstants.BrandColor.brandAccent70)
        XCTAssertEqual(sut.textColor, UIConstants.BrandColor.onBackground100)
        XCTAssertEqual(sut.textContainerInset, .zero)
        XCTAssertEqual(sut.textContainer.lineFragmentPadding, 0)
        XCTAssertFalse(sut.isScrollEnabled)
    }

    func testDefaultStyle() {
        XCTAssertFalse(sut.isCentered)
        XCTAssertTrue(sut.linkIsSemiBold)
        XCTAssertEqual(sut.linkColor, UIConstants.BrandColor.brandAccent70)
        XCTAssertEqual(sut.style, .light)
    }

    func testLinkTextFontSetter() {
        // Given
        let newFont = UIConstants.Font.regular

        // When
        sut.linkTextFont = newFont

        // Then
        XCTAssertEqual(sut.font, UIFontMetrics.default.scaledFont(for: newFont))
    }

    func testLinkColorSetter() {
        let newColor = UIColor.red
        sut.linkColor = newColor
        let attrColor = sut.linkTextAttributes[NSAttributedString.Key.foregroundColor] as? UIColor
        XCTAssertEqual(attrColor, newColor)
    }

    func testConstants() {
        XCTAssertEqual(LinkTextView.Constants.delimiter, "#")
        XCTAssertEqual(LinkTextView.Constants.separator, "::")
    }

    func test_linkActionParts() {
        for (string, result) in samples {
            let textComponents = sut.linkActionParts(for: string)
            XCTAssertEqual(textComponents.regularText.count, result.stringLength(for: string, keysAndValues: textComponents.linkKeyValue))
            XCTAssertEqual(textComponents.linkKeyValue.count, result.numberOfKeysAndValues)
        }
    }

    func testTextAttirbutes_DefaultValues() {
        sut.linkText = "Test text"
        let attributes = sut.attributedText.attributes(at: 0, effectiveRange: nil)

        guard let font = attributes[NSAttributedString.Key.font] as? UIFont, let foregroundColor = attributes[NSAttributedString.Key.foregroundColor] as? UIColor, let backgroundColor = attributes[NSAttributedString.Key.backgroundColor] as? UIColor, let paragraphStyle = attributes[NSAttributedString.Key.paragraphStyle] as? NSParagraphStyle else {
            XCTFail("'attributes' should be set up for 'attributedText'!")
            return
        }

        XCTAssertEqual(paragraphStyle.alignment, .left)
        XCTAssertEqual(paragraphStyle.lineBreakMode, .byWordWrapping)
        XCTAssertEqual(paragraphStyle.lineSpacing, UIConstants.Size.TextLineSpacing)

        XCTAssertTrue(sut.adjustsFontForContentSizeCategory)
        XCTAssertEqual(font, UIFontMetrics.default.scaledFont(for: UIConstants.Font.regular))
        XCTAssertEqual(foregroundColor, sut.textColor)
        XCTAssertEqual(backgroundColor, UIColor.clear)
    }

    func testTextAttirbutes_CustomValues() {
        // Given
        let customLinkTextFont = UIConstants.Font.regular
        sut.linkTextFont = customLinkTextFont
        let isCentered = true
        sut.isCentered = isCentered

        // When
        sut.linkText = "Test text"

        // Then
        let attributes = sut.attributedText.attributes(at: 0, effectiveRange: nil)

        guard let font = attributes[NSAttributedString.Key.font] as? UIFont, let foregroundColor = attributes[NSAttributedString.Key.foregroundColor] as? UIColor, let backgroundColor = attributes[NSAttributedString.Key.backgroundColor] as? UIColor, let paragraphStyle = attributes[NSAttributedString.Key.paragraphStyle] as? NSParagraphStyle else {
            XCTFail("'attributes' should be set up for 'attributedText'!")
            return
        }

        XCTAssertEqual(paragraphStyle.alignment, .center)
        XCTAssertEqual(paragraphStyle.lineBreakMode, .byWordWrapping)
        XCTAssertEqual(paragraphStyle.lineSpacing, UIConstants.Size.TextLineSpacing)

        XCTAssertTrue(sut.adjustsFontForContentSizeCategory)
        XCTAssertEqual(font, UIFontMetrics.default.scaledFont(for: customLinkTextFont))
        XCTAssertEqual(foregroundColor, sut.textColor)
        XCTAssertEqual(backgroundColor, UIColor.clear)
    }
}
