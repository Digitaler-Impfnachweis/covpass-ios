//
//  HeadlineTests.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

@testable import VaccinationUI
import XCTest

class HeadlineTests: XCTestCase {
    var sut: Headline!

    override func setUp() {
        super.setUp()
        sut = Headline(frame: .zero)
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
        let sut = Headline(coder: CoderMock.unarchivedCoder)
        XCTAssertNotNil(sut?.contentView)
    }

    func testOutlets() {
        XCTAssertNotNil(sut.textableView)
    }

    func testInitView() {
        XCTAssertEqual(sut.isTransparent, false)
        XCTAssertEqual(sut.font, UIFont.ibmPlexSansSemiBold(with: 20))
        XCTAssertEqual(sut.textColor, UIConstants.BrandColor.onBackground100)

        XCTAssertTrue(sut.textableView.adjustsFontForContentSizeCategory)
        XCTAssertEqual(sut.textableView.font, UIFontMetrics.default.scaledFont(for: UIFont.ibmPlexSansSemiBold(with: 20) ?? UIFont.systemFont(ofSize: 20)))
        XCTAssertEqual(sut.textableView.numberOfLines, 0)

        XCTAssertTrue(sut.textableView.adjustsFontForContentSizeCategory)
        XCTAssertEqual(sut.textableView.numberOfLines, 0)
    }

    func testMargins() {
        // Given
        let view = Headline()
        guard let relatedMargins = view.margins as? [RelatedViewMargin] else {
            XCTFail("No related margins was set.")
            return
        }

        // When
        guard let marginToParagraphViewIndex = relatedMargins.firstIndex(where: { $0.relatedViewType == ParagraphView.self }) else {
            XCTFail("There should be a margin to the HUIParagraphView")
            return
        }
        let marginToParagraphView = relatedMargins[marginToParagraphViewIndex] as Margin

        // Then
        XCTAssertEqual(marginToParagraphView.type, MarginType.bottom)
        XCTAssertEqual(marginToParagraphView.constant, 24)
    }
}
