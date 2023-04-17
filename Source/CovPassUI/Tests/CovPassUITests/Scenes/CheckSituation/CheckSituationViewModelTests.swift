//
//  CheckSituationViewModel.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CovPassCommon
@testable import CovPassUI
import PromiseKit
import XCTest

class CheckSituationViewModelTests: XCTestCase {
    var offlineRevocationService: CertificateRevocationOfflineServiceMock!
    var repository: VaccinationRepositoryMock!
    var persistence: UserDefaultsPersistence!
    var router: CheckSituationRouterMock!
    var delegate: ViewModelDelegateMock!
    var sut: CheckSituationViewModel!

    override func setUp() {
        super.setUp()
        persistence = .init()
        offlineRevocationService = .init()
        repository = .init()
        router = CheckSituationRouterMock()
        delegate = ViewModelDelegateMock()
        configureSut()
    }

    private func configureSut() {
        let (_, resolver) = Promise<Void>.pending()
        sut = CheckSituationViewModel(userDefaults: persistence,
                                      router: router,
                                      resolver: resolver,
                                      offlineRevocationService: offlineRevocationService,
                                      repository: repository)
        sut.delegate = delegate
    }

    override func tearDown() {
        offlineRevocationService = nil
        delegate = nil
        repository = nil
        router = nil
        persistence = nil
        sut = nil
        super.tearDown()
    }

    func testSettingsContext() {
        // THEN
        XCTAssertEqual(sut.footerText, "app_information_offline_revocation_copy_1")
        XCTAssertEqual(sut.descriptionTextIsTop, true)
        XCTAssertEqual(sut.newBadgeIconIsHidden, true)
        XCTAssertEqual(sut.pageImageIsHidden, true)
        XCTAssertEqual(sut.buttonIsHidden, true)
        XCTAssertFalse(sut.offlineRevocationIsHidden)
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
        userDefaults.lastUpdatedTrustList = DateUtils.parseDate("2021-04-26T15:05:00")
        offlineRevocationService.lastSuccessfulUpdate = DateUtils.parseDate("2021-04-26T15:05:00")

        // Then
        XCTAssertEqual(sut.listTitle, "app_information_title_checkrules")
        XCTAssertEqual(sut.downloadStateHintIcon, .check)
        XCTAssertEqual(sut.downloadStateTextColor, .neutralWhite)
        XCTAssertEqual(sut.downloadStateHintColor, .resultGreen)
        XCTAssertEqual(sut.downloadStateHintTitle, "settings_rules_list_status_updated")
        XCTAssertEqual(sut.certificateProviderTitle, "settings_rules_list_issuer")
        XCTAssertEqual(sut.certificateProviderSubtitle, "Apr 26, 2021 at 3:05 PM")
        XCTAssertEqual(sut.loadingHintTitle, "settings_rules_list_loading_title")
        XCTAssertEqual(sut.offlineModusButton, "app_information_message_update_button")
        XCTAssertEqual(sut.cancelButtonTitle, "settings_rules_list_loading_cancel")
        XCTAssertFalse(sut.isLoading)
    }

    func testPropertiesWithLastUpdateWhileNothingToUpdate() {
        // Given
        var userDefaults = UserDefaultsPersistence()
        userDefaults.lastUpdatedTrustList = DateUtils.parseDate("2021-04-26T15:05:00")
        repository.shouldTrustListUpdate = false
        offlineRevocationService.shouldOfflineUpdate = false

        // Then
        XCTAssertEqual(sut.listTitle, "app_information_title_checkrules")
        XCTAssertEqual(sut.downloadStateHintIcon, .check)
        XCTAssertEqual(sut.downloadStateTextColor, .neutralWhite)
        XCTAssertEqual(sut.downloadStateHintColor, .resultGreen)
        XCTAssertEqual(sut.downloadStateHintTitle, "settings_rules_list_status_updated")
        XCTAssertEqual(sut.certificateProviderTitle, "settings_rules_list_issuer")
        XCTAssertEqual(sut.certificateProviderSubtitle, "Apr 26, 2021 at 3:05 PM")
        XCTAssertEqual(sut.loadingHintTitle, "settings_rules_list_loading_title")
        XCTAssertEqual(sut.offlineModusButton, "app_information_message_update_button")
        XCTAssertEqual(sut.cancelButtonTitle, "settings_rules_list_loading_cancel")
        XCTAssertFalse(sut.isLoading)
    }

    func testRefresh() {
        // Given
        let exp1 = expectation(description: "didUpdate viewModel before loading with isLoading false")
        let exp3 = expectation(description: "didRefresh didUpdateTrustListHandler")
        let exp5 = expectation(description: "didUpdate viewModel after loading with isLoading true")
        delegate.didUpdate = { exp1.fulfill() }
        repository.didUpdateTrustListHandler = {
            exp3.fulfill()
        }
        // When
        sut.refresh()

        delegate.didUpdate = { exp5.fulfill() }

        // Then
        XCTAssertTrue(sut.isLoading)
        wait(for: [exp1, exp3, exp5], timeout: 2, enforceOrder: true)
        XCTAssertFalse(sut.isLoading)
    }

    func testSkipOfflineDownloadIfDisabled() {
        // Given
        let exp1 = expectation(description: "didUpdate viewModel before loading with isLoading false")
        let exp3 = expectation(description: "didRefresh didUpdateTrustListHandler")
        let exp4 = expectation(description: "didUpdate viewModel after loading with isLoading true")
        persistence.isCertificateRevocationOfflineServiceEnabled = false
        offlineRevocationService.updateExpectation.isInverted = true
        delegate.didUpdate = { exp1.fulfill() }
        repository.didUpdateTrustListHandler = { exp3.fulfill() }

        // When
        sut.refresh()
        delegate.didUpdate = { exp4.fulfill() }

        // Then
        XCTAssertTrue(sut.isLoading)
        wait(for: [exp1, offlineRevocationService.updateExpectation, exp3, exp4], timeout: 2, enforceOrder: true)
        XCTAssertFalse(sut.isLoading)
    }

    func testDescriptionIsHidden_settings() {
        // When
        let isHidden = sut.descriptionIsHidden

        // Then
        XCTAssertFalse(isHidden)
    }
}
