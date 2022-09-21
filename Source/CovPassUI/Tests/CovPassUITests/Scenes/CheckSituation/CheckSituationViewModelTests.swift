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
    var repository: VaccinationRepositoryMock!
    var certLogic: DCCCertLogicMock!
    var persistence: UserDefaultsPersistence!
    var router: CheckSituationRouterMock!
    var delegate: ViewModelDelegateMock!
    var sut: CheckSituationViewModel!
    
    override func setUp() {
        super.setUp()
        persistence = .init()
        offlineRevocationService = .init()
        certLogic = .init()
        repository = .init()
        router = CheckSituationRouterMock()
        delegate = ViewModelDelegateMock()
        configureSut()
    }

    private func configureSut(context: CheckSituationViewModelContextType = .settings) {
        let (_, resolver) = Promise<Void>.pending()
        sut = CheckSituationViewModel(context: context,
                                      userDefaults: persistence,
                                      router: router,
                                      resolver: resolver,
                                      offlineRevocationService: offlineRevocationService,
                                      repository: repository,
                                      certLogic: certLogic)
        sut.delegate = delegate
    }
    
    override func tearDown() {
        offlineRevocationService = nil
        certLogic = nil
        delegate = nil
        repository = nil
        router = nil
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
        XCTAssertEqual(sut.footerText, "app_information_message_update")
        XCTAssertEqual(sut.doneButtonTitle, "check_context_onboarding_button")
        XCTAssertEqual(sut.descriptionTextIsTop, true)
        XCTAssertEqual(sut.pageTitleIsHidden, true)
        XCTAssertEqual(sut.newBadgeIconIsHidden, true)
        XCTAssertEqual(sut.pageImageIsHidden, true)
        XCTAssertEqual(sut.buttonIsHidden, true)
        XCTAssertFalse(sut.offlineRevocationIsHidden)
    }

    func testOfflineRevocationIsHidden_information_context() {
        // Given
        sut.context = .information
        
        // When
        let isHidden = sut.offlineRevocationIsHidden
        
        // Then
        XCTAssertTrue(isHidden)
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
    
    func testToggleOfflineRevocation_disable_user_confirmed() {
        // Given
        persistence.isCertificateRevocationOfflineServiceEnabled = true
        router.disableOfflineRevocation = true
        
        // When
        sut.toggleOfflineRevocation()
        
        // Then
        wait(for: [offlineRevocationService.resetExpectation], timeout: 1)
        XCTAssertFalse(persistence.isCertificateRevocationOfflineServiceEnabled)
    }

    func testToggleOfflineRevocation_disable_user_does_not_confirm() {
        // Given
        persistence.isCertificateRevocationOfflineServiceEnabled = true
        router.disableOfflineRevocation = false
        let expectation = XCTestExpectation()
        expectation.expectedFulfillmentCount = 2
        delegate.didUpdate = { expectation.fulfill() }

        // When
        sut.toggleOfflineRevocation()

        // Then
        wait(for: [expectation], timeout: 1)
        XCTAssertTrue(persistence.isCertificateRevocationOfflineServiceEnabled)
    }
    
    func testPropertiesInitial() throws {
        let userDefaults = UserDefaultsPersistence()
        try userDefaults.delete(UserDefaults.keyLastUpdatedDCCRules)
        try userDefaults.delete(UserDefaults.keyLastUpdatedTrustList)
        XCTAssertFalse(sut.isLoading)
    }
    
    func testPropertiesWithLastUpdate() {
        // Given
        var userDefaults = UserDefaultsPersistence()
        userDefaults.lastUpdatedDCCRules = DateUtils.parseDate("2021-04-26T15:05:00")
        userDefaults.lastUpdatedValueSets = DateUtils.parseDate("2021-04-26T15:05:00")
        userDefaults.lastUpdatedTrustList = DateUtils.parseDate("2021-04-26T15:05:00")
        offlineRevocationService.lastSuccessfulUpdate = DateUtils.parseDate("2021-04-26T15:05:00")

        // Then
        XCTAssertEqual(sut.listTitle, "app_information_title_checkrules")
        XCTAssertEqual(sut.downloadStateHintIcon, .warning)
        XCTAssertEqual(sut.downloadStateTextColor, .neutralBlack)
        XCTAssertEqual(sut.downloadStateHintColor, .warningAlternative)
        XCTAssertEqual(sut.downloadStateHintTitle, "settings_rules_list_status_outofdate")
        XCTAssertEqual(sut.entryRulesTitle, "settings_rules_list_entry")
        XCTAssertEqual(sut.entryRulesSubtitle, "Apr 26, 2021 at 3:05 PM")
        XCTAssertEqual(sut.domesticRulesUpdateTitle, "settings_rules_list_domestic")
        XCTAssertEqual(sut.domesticRulesUpdateSubtitle, "Apr 26, 2021 at 3:05 PM")
        XCTAssertEqual(sut.valueSetsTitle, "settings_rules_list_features")
        XCTAssertEqual(sut.valueSetsSubtitle, "Apr 26, 2021 at 3:05 PM")
        XCTAssertEqual(sut.certificateProviderTitle, "settings_rules_list_issuer")
        XCTAssertEqual(sut.certificateProviderSubtitle, "Apr 26, 2021 at 3:05 PM")
        XCTAssertEqual(sut.countryListTitle, "settings_rules_list_countries")
        XCTAssertEqual(sut.countryListSubtitle, "Apr 26, 2021 at 3:05 PM")
        XCTAssertEqual(sut.authorityListTitle, "settings_rules_list_authorities")
        XCTAssertEqual(sut.authorityListSubtitle, "Apr 26, 2021 at 3:05 PM")
        XCTAssertEqual(sut.loadingHintTitle, "settings_rules_list_loading_title")
        XCTAssertEqual(sut.offlineModusButton, "app_information_message_update_button")
        XCTAssertEqual(sut.cancelButtonTitle, "settings_rules_list_loading_cancel")
        XCTAssertFalse(sut.isLoading)
    }
    
    func testPropertiesWithLastUpdateWhileNothingToUpdate() {
        // Given
        var userDefaults = UserDefaultsPersistence()
        userDefaults.lastUpdatedDCCRules = DateUtils.parseDate("2021-04-26T15:05:00")
        userDefaults.lastUpdatedValueSets = DateUtils.parseDate("2021-04-26T15:05:00")
        userDefaults.lastUpdatedTrustList = DateUtils.parseDate("2021-04-26T15:05:00")
        repository.shouldTrustListUpdate = false
        certLogic.rulesShouldBeUpdated = false
        certLogic.valueSetsShouldBeUpdated = false
        offlineRevocationService.shouldOfflineUpdate = false

        // Then
        XCTAssertEqual(sut.listTitle, "app_information_title_checkrules")
        XCTAssertEqual(sut.downloadStateHintIcon, .check)
        XCTAssertEqual(sut.downloadStateTextColor, .neutralWhite)
        XCTAssertEqual(sut.downloadStateHintColor, .resultGreen)
        XCTAssertEqual(sut.downloadStateHintTitle, "settings_rules_list_status_updated")
        XCTAssertEqual(sut.entryRulesTitle, "settings_rules_list_entry")
        XCTAssertEqual(sut.entryRulesSubtitle, "Apr 26, 2021 at 3:05 PM")
        XCTAssertEqual(sut.domesticRulesUpdateTitle, "settings_rules_list_domestic")
        XCTAssertEqual(sut.domesticRulesUpdateSubtitle, "Apr 26, 2021 at 3:05 PM")
        XCTAssertEqual(sut.valueSetsTitle, "settings_rules_list_features")
        XCTAssertEqual(sut.valueSetsSubtitle, "Apr 26, 2021 at 3:05 PM")
        XCTAssertEqual(sut.certificateProviderTitle, "settings_rules_list_issuer")
        XCTAssertEqual(sut.certificateProviderSubtitle, "Apr 26, 2021 at 3:05 PM")
        XCTAssertEqual(sut.countryListTitle, "settings_rules_list_countries")
        XCTAssertEqual(sut.countryListSubtitle, "Apr 26, 2021 at 3:05 PM")
        XCTAssertEqual(sut.loadingHintTitle, "settings_rules_list_loading_title")
        XCTAssertEqual(sut.offlineModusButton, "app_information_message_update_button")
        XCTAssertEqual(sut.cancelButtonTitle, "settings_rules_list_loading_cancel")
        XCTAssertFalse(sut.isLoading)
    }
    
    func testRefresh() {
        // Given
        let exp1 = expectation(description: "didUpdate viewModel before loading with isLoading false")
        let exp2 = expectation(description: "didRefresh didUpdateRules")
        let exp3 = expectation(description: "didRefresh didUpdateValueSets")
        let exp4 = expectation(description: "didRefresh didUpdateTrustListHandler")
        let exp5 = expectation(description: "didUpdate viewModel after loading with isLoading true")
        delegate.didUpdate = { exp1.fulfill() }
        certLogic.didUpdateRules = { exp2.fulfill() }
        certLogic.didUpdateValueSets = { exp3.fulfill() }
        repository.didUpdateTrustListHandler = { exp4.fulfill() }
        
        // When
        sut.refresh()
        delegate.didUpdate = { exp5.fulfill() }

        // Then
        XCTAssertTrue(sut.isLoading)
        wait(for: [exp1, exp2, exp3, offlineRevocationService.updateExpectation, exp4, exp5], timeout: 2, enforceOrder: true)
        XCTAssertFalse(sut.isLoading)
    }
    
    func testCancel() {
        // Given
        let exp2 = expectation(description: "didRefresh didUpdateRules")
        let exp3 = expectation(description: "didRefresh didUpdateTrustListHandler")
        exp3.isInverted = true
        offlineRevocationService.updateExpectation.isInverted = true
        certLogic.didUpdateRules = {
            print("1")
            exp2.fulfill()
            
        }
        repository.didUpdateTrustListHandler = {
            exp3.fulfill()
        }
        sut.refresh()

        
        // When
        sut.cancel()


        // Then
        XCTAssertFalse(sut.isLoading)
        wait(for: [exp2, exp3, offlineRevocationService.updateExpectation], timeout: 0.1, enforceOrder: true)
    }
    
    func testSkipOfflineDownloadIfDisabled() {
        // Given
        let exp1 = expectation(description: "didUpdate viewModel before loading with isLoading false")
        let exp2 = expectation(description: "didRefresh didUpdateRules")
        let exp3 = expectation(description: "didRefresh didUpdateTrustListHandler")
        let exp4 = expectation(description: "didUpdate viewModel after loading with isLoading true")
        persistence.isCertificateRevocationOfflineServiceEnabled = false
        offlineRevocationService.updateExpectation.isInverted = true
        delegate.didUpdate = { exp1.fulfill() }
        certLogic.didUpdateRules = { exp2.fulfill() }
        repository.didUpdateTrustListHandler = { exp3.fulfill() }
        
        
        // When
        sut.refresh()
        delegate.didUpdate = { exp4.fulfill() }

        // Then
        XCTAssertTrue(sut.isLoading)
        wait(for: [exp1, exp2, offlineRevocationService.updateExpectation, exp3, exp4], timeout: 2, enforceOrder: true)
        XCTAssertFalse(sut.isLoading)
    }
    
    func testErrorNoInternet() {
        // GIVEN
        certLogic.throwErrorOnUpdateRules = true
        
        // WHEN
        sut.refresh()

        // THEN
        wait(for: [router.noInternetExpecation], timeout: 2)
    }
    
    func testErroOtherCallsAreNotDisturbed() {
        // GIVEN
        certLogic.throwErrorOnUpdateRules = true
        persistence.isCertificateRevocationOfflineServiceEnabled = true
        let exp1 = expectation(description: "didUpdate viewModel before loading with isLoading false")
        let exp2 = expectation(description: "didRefresh didUpdateRules")
        let exp3 = expectation(description: "didRefresh didUpdateValueSets")
        let exp4 = expectation(description: "didRefresh didUpdateTrustListHandler")
        let exp5 = expectation(description: "didUpdate viewModel after loading with isLoading true")
        exp2.isInverted = true
        delegate.didUpdate = {
            exp1.fulfill()
        }
        certLogic.didUpdateRules = {
            exp2.fulfill()
        }
        certLogic.didUpdateValueSets = {
            exp3.fulfill()
        }
        repository.didUpdateTrustListHandler = {
            exp4.fulfill()
        }
        
        // When
        sut.refresh()
        delegate.didUpdate = {
            exp5.fulfill()
        }

        // Then
        XCTAssertTrue(sut.isLoading)
        wait(for: [exp1, router.noInternetExpecation, exp2, exp3, offlineRevocationService.updateExpectation, exp4, exp5], timeout: 3, enforceOrder: true)
        XCTAssertFalse(sut.isLoading)
    }

    func testDescriptionIsHidden_settings() {
        // When
        let isHidden = sut.descriptionIsHidden

        // Then
        XCTAssertTrue(isHidden)
    }

    func testDescriptionIsHidden_information() {
        // Given
        configureSut(context: .information)

        // When
        let isHidden = sut.descriptionIsHidden

        // Then
        XCTAssertFalse(isHidden)
    }
}
