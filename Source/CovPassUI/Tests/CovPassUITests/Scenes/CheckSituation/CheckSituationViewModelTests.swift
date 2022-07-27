//
//  CheckSituationViewModel.swift
//  
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//


@testable import CovPassUI
import CovPassCommon
import XCTest
import PromiseKit

class CheckSituationViewModelTests: XCTestCase {

    var offlineRevocationService: CertificateRevocationOfflineServiceMock!
    var persistence: UserDefaultsPersistence!
    var sut: CheckSituationViewModel!

    override func setUp() {
        super.setUp()
        let (_, resolver) = Promise<Void>.pending()
        persistence = .init()
        offlineRevocationService = .init()
        sut = CheckSituationViewModel(context: .settings,
                                      userDefaults: persistence,
                                      resolver: resolver,
                                      offlineRevocationService: offlineRevocationService)
    }
    
    override func tearDown() {
        offlineRevocationService = nil
        persistence = nil
        sut = nil
        super.tearDown()
    }
    
    func testSettingsContext() {
        //WHEN
        sut.context = .settings

        //THEN
        XCTAssertEqual(sut.pageTitle, "check_context_onboarding_title")
        XCTAssertEqual(sut.newBadgeText, "check_context_onboarding_tag")
        XCTAssertEqual(sut.pageImage, .illustration4)
        XCTAssertEqual(sut.domesticRulesTitle, "check_context_onboarding_option2_title")
        XCTAssertEqual(sut.travelRulesTitle, "check_context_onboarding_option1_title")
        XCTAssertEqual(sut.domesticRulesDescription, "check_context_onboarding_option2_subtitle")
        XCTAssertEqual(sut.travelRulesDescription, "check_context_onboarding_option1_subtitle")
        XCTAssertEqual(sut.footerText, "check_context_onboarding_footnote")
        XCTAssertEqual(sut.doneButtonTitle, "check_context_onboarding_button")
        XCTAssertEqual(sut.descriptionTextIsTop, true)
        XCTAssertEqual(sut.pageTitleIsHidden, true)
        XCTAssertEqual(sut.newBadgeIconIsHidden, true)
        XCTAssertEqual(sut.pageImageIsHidden, true)
        XCTAssertEqual(sut.buttonIsHidden, true)
        XCTAssertFalse(sut.offlineRevocationIsHidden)
    }
    
    func testOnboardingContext() {
        // WHEN
        sut.context = .onboarding
        
        //THEN
        XCTAssertEqual(sut.pageTitle, "check_context_onboarding_title")
        XCTAssertEqual(sut.newBadgeText, "check_context_onboarding_tag")
        XCTAssertEqual(sut.pageImage, .illustration4)
        XCTAssertEqual(sut.domesticRulesTitle, "check_context_onboarding_option2_title")
        XCTAssertEqual(sut.travelRulesTitle, "check_context_onboarding_option1_title")
        XCTAssertEqual(sut.domesticRulesDescription, "check_context_onboarding_option2_subtitle")
        XCTAssertEqual(sut.travelRulesDescription, "check_context_onboarding_option1_subtitle")
        XCTAssertEqual(sut.footerText, "check_context_onboarding_footnote")
        XCTAssertEqual(sut.doneButtonTitle, "check_context_onboarding_button")
        XCTAssertEqual(sut.descriptionTextIsTop, false)
        XCTAssertEqual(sut.pageTitleIsHidden, false)
        XCTAssertEqual(sut.newBadgeIconIsHidden, false)
        XCTAssertEqual(sut.pageImageIsHidden, false)
        XCTAssertEqual(sut.buttonIsHidden, false)
        XCTAssertTrue(sut.offlineRevocationIsHidden)
    }

    func testOfflineRevocationIsHidden_information_context() {
        // Given
        sut.context = .information

        // When
        let isHidden = sut.offlineRevocationIsHidden

        // Then
        XCTAssertTrue(isHidden)
    }
    
    func testFetchSelectedRule() {
        // GIVEN
        var persistence = UserDefaultsPersistence()
        persistence.selectedLogicType = .de

        // WHEN
        let selectedType = sut.selectedRule
        
        // THEN
        XCTAssertEqual(selectedType, .de)
    }
    
    func testStoreSelectedRule() {
        // GIVEN
        sut.selectedRule = .eu

        // WHEN
        let persistence = UserDefaultsPersistence()
        let selectedType = persistence.selectedLogicType

        // THEN
        XCTAssertEqual(selectedType, .eu)
    }

    func testOfflineRevocationIsEnabled_true() {
        // Given
        persistence.isCertificateRevocationOfflineServiceEnabled = true

        // When
        let isEnabled = sut.offlineRevocationIsEnabled

        // Then
        XCTAssertTrue(isEnabled)
    }

    func testOfflineRevocationIsEnabled_false() {
        // Given
        persistence.isCertificateRevocationOfflineServiceEnabled = false

        // When
        let isEnabled = sut.offlineRevocationIsEnabled

        // Then
        XCTAssertFalse(isEnabled)
    }

    func testToggleOfflineRevocation_enable() {
        // Given
        persistence.isCertificateRevocationOfflineServiceEnabled = false

        // When
        sut.toggleOfflineRevocation()

        // Then
        wait(for: [offlineRevocationService.updateExpectation], timeout: 1)
        XCTAssertTrue(persistence.isCertificateRevocationOfflineServiceEnabled)
    }

    func testToggleOfflineRevocation_disable() {
        // Given
        persistence.isCertificateRevocationOfflineServiceEnabled = true

        // When
        sut.toggleOfflineRevocation()

        // Then
        wait(for: [offlineRevocationService.resetExpectation], timeout: 1)
        XCTAssertFalse(persistence.isCertificateRevocationOfflineServiceEnabled)
    }
}
