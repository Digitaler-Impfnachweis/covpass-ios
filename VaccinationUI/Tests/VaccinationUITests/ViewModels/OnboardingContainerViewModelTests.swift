//
//  OnboardingContainerViewModelTests.swift
//
//
//  Copyright © 2021 IBM. All rights reserved.
//

@testable import VaccinationUI
import XCTest

class OnboardingContainerViewModelTests: XCTestCase {
    var sut: OnboardingContainerViewModel!

    override func setUp() {
        super.setUp()
        let pageModels = OnboardingPageViewModelType.allCases.map { OnboardingPageViewModel(type: $0) }
        sut = OnboardingContainerViewModel(items: pageModels)
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testSettings() {
        XCTAssertEqual(sut.startButtonTitle, "Weiter")
        XCTAssertEqual(sut.startButtonShadowColor, .clear)
    }
}
