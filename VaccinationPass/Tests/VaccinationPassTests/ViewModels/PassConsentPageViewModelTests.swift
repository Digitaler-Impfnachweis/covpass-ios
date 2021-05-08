//
//  PassConsentPageViewModelTests.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

@testable import VaccinationPass
import XCTest

class PassConsentPageViewModelTests: XCTestCase {
    var sut: PassConsentPageViewModel!

    override func setUp() {
        super.setUp()
        sut = PassConsentPageViewModel(type: .page4)
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testInit() {
        XCTAssertEqual(sut.image, .onboardingScreen4)
        XCTAssertEqual(sut.title, "vaccination_fourth_onboarding_page_title".localized)
        XCTAssertEqual(sut.info, "vaccination_fourth_onboarding_page_message".localized)
        XCTAssertEqual(sut.dataPrivacyTitle, NSMutableAttributedString(string: "vaccination_fourth_onboarding_page_second_selection".localized).addLink(url: "https://www.digitaler-impfnachweis-app.de/webviews/client-app/privacy/", in: "Datenschutzerklärung").styledAs(.body))
        XCTAssertFalse(sut.isGranted)
        XCTAssertEqual(sut.toolbarState, .disabledWithText("confirmation_fourth_onboarding_page_button_title".localized))
    }

    func testToolbarState() {
        sut.isGranted = true
        XCTAssertEqual(sut.toolbarState, .confirm("confirmation_fourth_onboarding_page_button_title".localized))
    }
}
