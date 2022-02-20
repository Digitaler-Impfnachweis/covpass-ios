//
//  CheckSituationViewModel.swift
//  
//
//  Created by Fatih Karakurt on 26.01.22.
//


@testable import CovPassUI
import CovPassCommon
import XCTest
import PromiseKit

class CheckSituationViewModelTests: XCTestCase {

    var sut: CheckSituationViewModel!

    override func setUp() {
        super.setUp()
        let (_, resolver) = Promise<Void>.pending()
        sut = CheckSituationViewModel(context: .settings,
                                      userDefaults: UserDefaultsPersistence(),
                                      resolver: resolver)
    }
    
    override func tearDown() {
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
}
