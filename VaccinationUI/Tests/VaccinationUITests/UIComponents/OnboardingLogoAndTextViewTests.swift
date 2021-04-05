//
//  OnboardingLogoAndTextViewTests.swift
// 
//
//  Copyright © 2021 IBM. All rights reserved.
//

import Foundation
@testable import VaccinationUI
import XCTest

class OnboardingLogoAndTextViewTests: XCTestCase {
    var sut: OnboardingLogoAndTextView!

    override func setUp() {
        super.setUp()
        sut = OnboardingLogoAndTextView()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testInit() {
        XCTAssertNotNil(sut.contentView, "OnboardingLogoAndTextView ContentView should exist")

        let viewWithCoder = OnboardingLogoAndTextView(coder: CoderMock.unarchivedCoder)
        viewWithCoder?.awakeFromNib()
        viewWithCoder?.prepareForInterfaceBuilder()
        XCTAssertNotNil(viewWithCoder, "OnboardingLogoAndTextView should exist")
        XCTAssertNotNil(viewWithCoder!.contentView, "OnboardingLogoAndTextView ContentView should exist")
    }

    func testStyles() {
        XCTAssertEqual(sut.contentView?.backgroundColor, UIConstants.BrandColor.brandBase)
        XCTAssertEqual(sut.textLabel.font, UIFont.ibmPlexSansRegular(with: 14))
        XCTAssertEqual(sut.textLabel.textColor, UIConstants.BrandColor.onBrandBase)
        XCTAssertEqual(sut.logoContentView.layer.cornerRadius, sut.logoContentView.frame.size.width / 2)
    }

    func testLogoAndTextViewMargin() {
        // Given
        let spacing: CGFloat = 23

        // When
        guard let margin = sut.margins[0] as? RelatedViewMargin else {
            XCTAssert(false, "There should be a margin to a LogoAndTextView")
            return
        }

        // Then
        XCTAssertTrue(margin.relatedViewType is OnboardingLogoAndTextView.Type, "The margin relatedViewType should be a LogoAndTextView")
        XCTAssertEqual(margin.type, MarginType.bottom, "The margin type should be bottom")
        XCTAssertEqual(margin.constant, spacing, "The margin spacing should be \(spacing)")
    }

//    func testFixedSpacerMargin() {
//        // Given
//        let spacing: CGFloat = 52
//
//        // When
//        guard let margin = sut.margins[1] as? RelatedViewMargin else {
//            XCTAssert(false, "There should be a margin to a FixedSpacer")
//            return
//        }
//
//        // Then
//        XCTAssertTrue(margin.relatedViewType is FixedSpacer.Type, "The margin relatedViewType should be a FixedSpacer")
//        XCTAssertEqual(margin.type, MarginType.bottom, "The margin type should be bottom")
//        XCTAssertEqual(margin.constant, spacing, "The margin spacing should be \(spacing)")
//    }
}
