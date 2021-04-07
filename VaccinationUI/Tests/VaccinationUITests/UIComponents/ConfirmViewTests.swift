//
//  ConfirmViewTests.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

@testable import VaccinationUI
import XCTest

class ConfirmViewTests: XCTestCase {
    var sut: ConfirmView!

    override func setUp() {
        super.setUp()
        sut = ConfirmView(frame: .zero)
        sut.initView()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testInitWithFrame() {
        XCTAssertNotNil(sut.contentView)
    }

    func testInitWithCoder() {
        let sut = ConfirmView(coder: CoderMock.unarchivedCoder)
        XCTAssertNotNil(sut?.contentView)
    }

    func testOutlets() {
        XCTAssertNotNil(sut.detailLabel)
        XCTAssertNotNil(sut.infoLabel)
        XCTAssertNotNil(sut.imageView)
    }

    func testStyle() {
        XCTAssertEqual(sut.detailLabel.textColor, UIConstants.BrandColor.onBackground100)
        XCTAssertEqual(sut.infoLabel.textColor, UIConstants.BrandColor.onBackground70)
        XCTAssertTrue(sut.infoLabel.isHidden)
    }

    func testSetDetailTextObserving() {
        let testString = "Test Detail"
        sut.detail = testString
        XCTAssertEqual(sut.detailLabel.text, testString)
    }

    func testSetInfoTextObserving() {
        // Given
        let testInfoString1 = "Test Info Text"
        // When
        sut.info = testInfoString1
        // Then
        XCTAssertEqual(sut.infoLabel.text, testInfoString1)
        XCTAssertFalse(sut.infoLabel.isHidden)

        // Given
        let testInfoString2: String? = nil
        // When
        sut.info = testInfoString2
        // Then
        XCTAssertEqual(sut.infoLabel.text, testInfoString2)
        XCTAssertTrue(sut.infoLabel.isHidden)
    }

    func testPlaceholderType() {
        let placeholderImage = UIImage(named: UIConstants.IconName.PlusIcon, in: UIConstants.bundle, compatibleWith: nil)
        sut.kind = .placeholder(image: placeholderImage)
        XCTAssertEqual(sut.imageView.image, placeholderImage?.withRenderingMode(.alwaysTemplate))
        XCTAssertEqual(sut.imageView.tintColor, UIConstants.BrandColor.onBackground50)
        XCTAssertEqual(sut.imageWidthConstraint.constant, UIConstants.Size.PlaceholderImageWidth)
        XCTAssertEqual(sut.imageHeightConstraint.constant, UIConstants.Size.PlaceholderImageHeight)
        XCTAssertEqual(sut.detailLabel.font, UIFontMetrics.default.scaledFont(for: UIConstants.Font.semiBoldLarger))
    }

    func testAdjustsFontForContentSizeCategory() {
        XCTAssertEqual(sut.detailLabel.numberOfLines, 0)
        XCTAssertTrue(sut.detailLabel.adjustsFontForContentSizeCategory)
        XCTAssertEqual(sut.detailLabel.font, UIFontMetrics.default.scaledFont(for: UIConstants.Font.regularLarger))

        XCTAssertEqual(sut.infoLabel.numberOfLines, 0)
        XCTAssertTrue(sut.infoLabel.adjustsFontForContentSizeCategory)
        XCTAssertEqual(sut.infoLabel.font, UIFontMetrics.default.scaledFont(for: UIConstants.Font.regular))
    }

    func testSetDetailLabelFont() {
        // Given
        let firstFont = UIFont.systemFont(ofSize: 15)
        // When
        sut.setDetailLabel(font: firstFont)
        // Then
        XCTAssertEqual(sut.detailLabel.font, UIFontMetrics.default.scaledFont(for: firstFont))

        // second case
        // Given
        let secondFont = UIFont.systemFont(ofSize: 18)
        XCTAssertNotEqual(firstFont, secondFont)
        // When
        sut.setDetailLabel(font: secondFont)
        // Then
        XCTAssertEqual(sut.detailLabel.font, UIFontMetrics.default.scaledFont(for: secondFont))
    }
}
