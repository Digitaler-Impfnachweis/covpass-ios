//
//  PassConsentPageViewModelTests.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassApp
import CovPassUI
import XCTest

class PassConsentPageViewModelTests: XCTestCase {
    var sut: PassConsentPageViewModel!

    override func setUp() {
        super.setUp()
        sut = PassConsentPageViewModel(type: .page4, router: ConsentRouter(sceneCoordinator: SceneCoordinatorMock()))
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testInit() {
        XCTAssertEqual(sut.image, .onboardingScreen4)
        XCTAssertEqual(sut.title, "vaccination_fourth_onboarding_page_title".localized)
        XCTAssertEqual(sut.info, "vaccination_fourth_onboarding_page_message".localized)
        XCTAssertEqual(sut.dataPrivacyTitle, NSMutableAttributedString(string: "app_information_title_datenschutz".localized).styledAs(.header_3))
        XCTAssertFalse(sut.isScrolledToBottom)
        XCTAssertEqual(sut.toolbarState, .scrollAware)
    }

    func testToolbarState() {
        sut.isScrolledToBottom = true
        XCTAssertEqual(sut.toolbarState, .confirm("vaccination_fourth_onboarding_page_button_title".localized))
    }
}
