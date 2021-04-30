//
//  OnboardingPageViewModelTests.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

@testable import VaccinationUI
import XCTest

class OnboardingPageViewModelTests: XCTestCase {
    var sut: OnboardingPageViewModel!

    override func setUp() {
        super.setUp()
        sut = OnboardingPageViewModel(type: .page1)
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testSettings() {
        XCTAssertEqual(sut.imageAspectRatio, 375 / 220)
        XCTAssertEqual(sut.imageWidth, UIScreen.main.bounds.width)
        XCTAssertEqual(sut.imageHeight, sut.imageWidth / sut.imageAspectRatio)
        XCTAssertEqual(sut.imageContentMode, .scaleAspectFit)
        XCTAssertEqual(sut.headlineFont, UIConstants.Font.onboardingHeadlineFont)
        XCTAssertEqual(sut.headlineColor, .black)
        XCTAssertEqual(sut.paragraphBodyFont, UIConstants.Font.regularLarger)
        XCTAssertEqual(sut.backgroundColor, .backgroundPrimary)
    }

    func testPage1Values() {
        sut = OnboardingPageViewModel(type: .page1)
        XCTAssertEqual(sut.image, UIImage(named: UIConstants.IconName.OnboardingScreen1, in: UIConstants.bundle, compatibleWith: nil))
        XCTAssertEqual(sut.title, "vaccination_first_onboarding_page_title".localized)
        XCTAssertEqual(sut.info, "vaccination_first_onboarding_page_message".localized)
    }

    func testPage2Values() {
        sut = OnboardingPageViewModel(type: .page2)
        XCTAssertEqual(sut.image, UIImage(named: UIConstants.IconName.OnboardingScreen2, in: UIConstants.bundle, compatibleWith: nil))
        XCTAssertEqual(sut.title, "vaccination_second_onboarding_page_title".localized)
        XCTAssertEqual(sut.info, "vaccination_second_onboarding_page_message".localized)
    }

    func testPage3Values() {
        sut = OnboardingPageViewModel(type: .page3)
        XCTAssertEqual(sut.image, UIImage(named: UIConstants.IconName.OnboardingScreen3, in: UIConstants.bundle, compatibleWith: nil))
        XCTAssertEqual(sut.title, "vaccination_third_onboarding_page_title".localized)
        XCTAssertEqual(sut.info, "vaccination_third_onboarding_page_message".localized)
    }
}
