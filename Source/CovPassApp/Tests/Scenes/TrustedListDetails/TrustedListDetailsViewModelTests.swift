//
//  TrustedListDetailsViewModelTests.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassApp
@testable import CovPassUI
import CovPassCommon
import XCTest

class TrustedListDetailsViewModelTests: XCTestCase {
    
    var sut: TrustedListDetailsViewModel!
    var vaccinationRepository: VaccinationRepositoryMock!
    var certLogic: DCCCertLogicMock!
    var delegate: ViewModelDelegateMock!
    
    override func setUp() {
        super.setUp()
        vaccinationRepository = VaccinationRepositoryMock()
        certLogic = DCCCertLogicMock()
        delegate = ViewModelDelegateMock()
        sut = TrustedListDetailsViewModel(repository: vaccinationRepository,
                                          certLogic: certLogic)
        sut.delegate = delegate
    }
    
    override func tearDown() {
        sut = nil
        vaccinationRepository = nil
        delegate = nil
        certLogic = nil
        super.tearDown()
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

        // Then
        XCTAssertEqual(sut.title, "Update checking rules")
        XCTAssertEqual(sut.oflineModusDescription, "To check the validity of certificates, the app requires up-to-date lists of trusted certificate issuers as well as the current Covid-19 rules in the relevant travel countries.\n\nThese lists are updated automatically on a daily basis. You can also manually update them here at any time.")
        XCTAssertEqual(sut.listTitle, "Checking rules")
        XCTAssertEqual(sut.downloadStateHintIcon, .warning)
        XCTAssertEqual(sut.downloadStateTextColor, .neutralBlack)
        XCTAssertEqual(sut.downloadStateHintColor, .warningAlternative)
        XCTAssertEqual(sut.downloadStateHintTitle, "Update required")
        XCTAssertEqual(sut.entryRulesTitle, "Entry rules")
        XCTAssertEqual(sut.entryRulesSubtitle, "Apr 26, 2021 at 3:05 PM")
        XCTAssertEqual(sut.domesticRulesTitle, "Domestic rules")
        XCTAssertEqual(sut.domesticRulesSubtitle, "Apr 26, 2021 at 3:05 PM")
        XCTAssertEqual(sut.valueSetsTitle, "Rule features")
        XCTAssertEqual(sut.valueSetsSubtitle, "Apr 26, 2021 at 3:05 PM")
        XCTAssertEqual(sut.certificateProviderTitle, "Certificate issuer")
        XCTAssertEqual(sut.certificateProviderSubtitle, "Apr 26, 2021 at 3:05 PM")
        XCTAssertEqual(sut.countryListTitle, "Country lists")
        XCTAssertEqual(sut.countryListSubtitle, "Apr 26, 2021 at 3:05 PM")
        XCTAssertEqual(sut.loadingHintTitle, "Lists are being updated...")
        XCTAssertEqual(sut.offlineModusButton, "Update")
        XCTAssertEqual(sut.cancelButtonTitle, "Cancel")
        XCTAssertFalse(sut.isLoading)
    }
    
    func testPropertiesWithLastUpdateWhileNothingToUpdate() {
        // Given
        var userDefaults = UserDefaultsPersistence()
        userDefaults.lastUpdatedDCCRules = DateUtils.parseDate("2021-04-26T15:05:00")
        userDefaults.lastUpdatedValueSets = DateUtils.parseDate("2021-04-26T15:05:00")
        userDefaults.lastUpdatedTrustList = DateUtils.parseDate("2021-04-26T15:05:00")
        vaccinationRepository.shouldTrustListUpdate = false
        certLogic.rulesShouldUpdate = false
        certLogic.valueSetsShouldUpdate = false
        
        // Then
        XCTAssertEqual(sut.title, "Update checking rules")
        XCTAssertEqual(sut.oflineModusDescription, "To check the validity of certificates, the app requires up-to-date lists of trusted certificate issuers as well as the current Covid-19 rules in the relevant travel countries.\n\nThese lists are updated automatically on a daily basis. You can also manually update them here at any time.")
        XCTAssertEqual(sut.listTitle, "Checking rules")
        XCTAssertEqual(sut.downloadStateHintIcon, .check)
        XCTAssertEqual(sut.downloadStateTextColor, .neutralWhite)
        XCTAssertEqual(sut.downloadStateHintColor, .resultGreen)
        XCTAssertEqual(sut.downloadStateHintTitle, "Up to date")
        XCTAssertEqual(sut.entryRulesTitle, "Entry rules")
        XCTAssertEqual(sut.entryRulesSubtitle, "Apr 26, 2021 at 3:05 PM")
        XCTAssertEqual(sut.domesticRulesTitle, "Domestic rules")
        XCTAssertEqual(sut.domesticRulesSubtitle, "Apr 26, 2021 at 3:05 PM")
        XCTAssertEqual(sut.valueSetsTitle, "Rule features")
        XCTAssertEqual(sut.valueSetsSubtitle, "Apr 26, 2021 at 3:05 PM")
        XCTAssertEqual(sut.certificateProviderTitle, "Certificate issuer")
        XCTAssertEqual(sut.certificateProviderSubtitle, "Apr 26, 2021 at 3:05 PM")
        XCTAssertEqual(sut.countryListTitle, "Country lists")
        XCTAssertEqual(sut.countryListSubtitle, "Apr 26, 2021 at 3:05 PM")
        XCTAssertEqual(sut.loadingHintTitle, "Lists are being updated...")
        XCTAssertEqual(sut.offlineModusButton, "Update")
        XCTAssertEqual(sut.cancelButtonTitle, "Cancel")
        XCTAssertFalse(sut.isLoading)
    }
    
    func testRefresh() {
        // Given
        let exp1 = expectation(description: "didUpdate viewModel before loading with isLoading false")
        let exp2 = expectation(description: "didRefresh didUpdateRules")
        let exp3 = expectation(description: "didRefresh didUpdateTrustListHandler")
        let exp4 = expectation(description: "didUpdate viewModel after loading with isLoading true")
        delegate.didUpdate = { exp1.fulfill() }
        certLogic.didUpdateRules = { exp2.fulfill() }
        vaccinationRepository.didUpdateTrustListHandler = { exp3.fulfill() }
        
        // When
        sut.refresh()
        delegate.didUpdate = { exp4.fulfill() }

        // Then
        XCTAssertTrue(sut.isLoading)
        wait(for: [exp1, exp2, exp3, exp4], timeout: 2, enforceOrder: true)
        XCTAssertFalse(sut.isLoading)
    }
    
    func testCancel() {
        // Given
        let exp2 = expectation(description: "didRefresh didUpdateRules")
        let exp3 = expectation(description: "didRefresh didUpdateTrustListHandler")
        exp3.isInverted = true
        certLogic.didUpdateRules = {
            print("1")
            exp2.fulfill()
            
        }
        vaccinationRepository.didUpdateTrustListHandler = {
            exp3.fulfill()
        }
        sut.refresh()

        
        // When
        sut.cancel()


        // Then
        wait(for: [exp2, exp3], timeout: 0.1, enforceOrder: true)
    }
    
}
