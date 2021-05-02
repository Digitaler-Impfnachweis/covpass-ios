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
        XCTAssertEqual(sut.backgroundColor, .backgroundPrimary)
    }

    func testPage1Values() {
        sut = OnboardingPageViewModel(type: .page1)
        XCTAssertEqual(sut.image, .onboardingScreen1)
        XCTAssertEqual(sut.title, "vaccination_first_onboarding_page_title".localized)
        XCTAssertEqual(sut.info, "vaccination_first_onboarding_page_message".localized)
    }

    func testPage2Values() {
        sut = OnboardingPageViewModel(type: .page2)
        XCTAssertEqual(sut.image, .onboardingScreen2)
        XCTAssertEqual(sut.title, "vaccination_second_onboarding_page_title".localized)
        XCTAssertEqual(sut.info, "vaccination_second_onboarding_page_message".localized)
    }

    func testPage3Values() {
        sut = OnboardingPageViewModel(type: .page3)
        XCTAssertEqual(sut.image, .onboardingScreen3)
        XCTAssertEqual(sut.title, "vaccination_third_onboarding_page_title".localized)
        XCTAssertEqual(sut.info, "vaccination_third_onboarding_page_message".localized)
    }
}
