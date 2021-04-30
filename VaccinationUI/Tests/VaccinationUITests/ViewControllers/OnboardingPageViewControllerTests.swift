//
//  OnboardingPageViewControllerTests.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

@testable import VaccinationUI
import XCTest

class OnboardingPageViewControllerTests: XCTestCase {
    var sut: OnboardingPageViewController!
    var viewModel: OnboardingPageViewModel!

    override func setUp() {
        super.setUp()
        viewModel = OnboardingPageViewModel(type: .page1)
        sut = OnboardingPageViewController.createFromStoryboard(bundle: UIConstants.bundle)
        sut.viewModel = viewModel
        sut.loadViewIfNeeded()
    }

    override func tearDown() {
        viewModel = nil
        sut = nil

        super.tearDown()
    }

    func testOutlets() {
        XCTAssertNotNil(sut.imageView)
        XCTAssertNotNil(sut.headline)
        XCTAssertNotNil(sut.descriptionText)
    }

    func testConfigureImageView() {
        XCTAssertEqual(sut.imageView.image, viewModel.image)
    }

    func testConfigureHeadline() {
        XCTAssertEqual(sut.headline.text, viewModel.title)
        XCTAssertEqual(sut.headline.font, viewModel.headlineFont)
        XCTAssertEqual(sut.headline.textColor, viewModel.headlineColor)
    }

    func testConfigureParagraphView() {
        XCTAssertTrue(sut.paragraphView.title.isHidden)
        XCTAssertEqual(sut.paragraphView.bodyText, viewModel.info)
        XCTAssertEqual(sut.paragraphView.bodyFont, viewModel.paragraphBodyFont)
        XCTAssertEqual(sut.paragraphView.body.font, UIFontMetrics.default.scaledFont(for: viewModel.paragraphBodyFont))
        XCTAssertTrue(sut.paragraphView.body.adjustsFontForContentSizeCategory)
        XCTAssertEqual(sut.paragraphView.contentView?.backgroundColor, viewModel.backgroundColor)
    }
    
    func testViewDidLoadActionExecuted() {
        // Given
        viewModel = OnboardingPageViewModel(type: .page1)
        sut = OnboardingPageViewController.createFromStoryboard(bundle: UIConstants.bundle)
        sut.viewModel = viewModel
        
        var viewDidLoadActionExecuted = false
        sut.viewDidLoadAction = {
            viewDidLoadActionExecuted = true
        }
        
        // When
        sut.loadViewIfNeeded()
        // Then
        XCTAssertTrue(viewDidLoadActionExecuted)
    }
}
