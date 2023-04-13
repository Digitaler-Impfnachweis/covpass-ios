//
//  OnboardingPageViewModelTests.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassApp
import XCTest

class PassOnboardingPageViewModelTests: XCTestCase {
    var sut: PassOnboardingPageViewModel!

    override func setUp() {
        super.setUp()
        sut = PassOnboardingPageViewModel(type: .page1)
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testPage1Values() {
        sut = PassOnboardingPageViewModel(type: .page1)
        XCTAssertEqual(sut.image, .onboardingScreen1)
        XCTAssertEqual(sut.title, "vaccination_first_onboarding_page_title".localized)
        XCTAssertEqual(sut.info, "vaccination_first_onboarding_page_message".localized)
    }

    func testPage2Values() {
        sut = PassOnboardingPageViewModel(type: .page2)
        XCTAssertEqual(sut.image, .onboardingScreen2)
        XCTAssertEqual(sut.title, "vaccination_second_onboarding_page_title".localized)
        XCTAssertEqual(sut.info, "vaccination_second_onboarding_page_message".localized)
    }
}
