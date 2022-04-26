//
//  ValidatorOverviewViewModel.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCheckApp
@testable import CovPassCommon
@testable import CovPassUI
import XCTest

private enum Constants {
    enum Keys {
        static var syncTitle = "validation_start_screen_scan_sync_message_title"
        static var syncMessage = "validation_start_screen_scan_sync_message_text"
        static let privacyFile = "PRIVACY INFO"
    }
}

class ValidatorOverviewViewModelTests: XCTestCase {
    private var userDefaults: MockPersistence!
    private var router: ValidatorMockRouter!
    private var sut: ValidatorOverviewViewModel!
    
    override func setUp() {
        super.setUp()
        router = .init()
        userDefaults = .init()
        prepareSut()
    }
    
    override func tearDown() {
        router = nil
        userDefaults = nil
        sut = nil
       super.tearDown()
    }
    
    func testInitDate() throws {
        let title: String = Localizer.localized(Constants.Keys.syncTitle, bundle: Bundle.main)
        XCTAssert(sut.ntpOffset == 0.0)
        XCTAssert(sut.timeHintIcon == .warning)
        XCTAssert(sut.timeHintTitle == title)
        XCTAssert(sut.timeHintIsHidden == true)
    }
    
    func testNow() throws {
        let date = Date()
        sut.ntpDate = date
        sut.ntpOffset = 10
        let title: String = Localizer.localized(Constants.Keys.syncTitle, bundle: Bundle.main)
        let subTitle = String(format: Localizer.localized(Constants.Keys.syncMessage, bundle: Bundle.main),
                              sut.ntpDateFormatted)
        XCTAssert(sut.ntpDate == date)
        XCTAssert(sut.ntpOffset == 10.0)
        XCTAssert(sut.timeHintIcon == .warning)
        XCTAssert(sut.timeHintSubTitle == subTitle)
        XCTAssert(sut.timeHintTitle == title)
        XCTAssert(sut.timeHintIsHidden == true)
    }
    
    func testBeforeTwoHours() throws {
        let date = Date()
        sut.ntpDate = date
        sut.ntpOffset = -7200
        let title: String = Localizer.localized(Constants.Keys.syncTitle, bundle: Bundle.main)
        let subTitle = String(format: Localizer.localized(Constants.Keys.syncMessage, bundle: Bundle.main),
                              sut.ntpDateFormatted)
        XCTAssert(sut.ntpDate == date)
        XCTAssert(sut.ntpOffset == -7200)
        XCTAssert(sut.timeHintIcon == .warning)
        XCTAssert(sut.timeHintSubTitle == subTitle)
        XCTAssert(sut.timeHintTitle == title)
        XCTAssert(sut.timeHintIsHidden == false)
    }
    
    func testAfterTwoHours() throws {
        let date = Date()
        sut.ntpDate = date
        sut.ntpOffset = 7200
        let title: String = Localizer.localized(Constants.Keys.syncTitle, bundle: Bundle.main)
        let subTitle = String(format: Localizer.localized(Constants.Keys.syncMessage, bundle: Bundle.main),
                              sut.ntpDateFormatted)
        XCTAssert(sut.ntpDate == date)
        XCTAssert(sut.ntpOffset == 7200)
        XCTAssert(sut.timeHintIcon == .warning)
        XCTAssert(sut.timeHintSubTitle == subTitle)
        XCTAssert(sut.timeHintTitle == title)
        XCTAssert(sut.timeHintIsHidden == false)
    }
    
    func testRandomOffsetsWhereHintShouldBeHidden() throws {
        for _ in 0...10 {
            let random = Double.random(in: 0...7199)
            sut.ntpOffset = random
            XCTAssert(sut.ntpOffset == random)
            XCTAssert(sut.timeHintIsHidden == true)
        }
    }
    
    func testRandomOffsetsWhereHintShouldBeNotHidden() throws {
        for _ in 0...10 {
            let random = Double.random(in: 7200...20000)
            sut.ntpOffset = random
            XCTAssert(sut.ntpOffset == random)
            XCTAssert(sut.timeHintIsHidden == false)
        }
    }
    
    func testRandomOffsetsWhereHintShouldBeHiddenPast() throws {
        for _ in 0...10 {
            let random = Double.random(in: -7199 ... -0)
            sut.ntpOffset = random
            XCTAssert(sut.ntpOffset == random)
            XCTAssert(sut.timeHintIsHidden == true)
        }
    }
    
    func testRandomOffsetsWhereHintShouldBeNotHiddenPast() throws {
        for _ in 0...10 {
            let random = Double.random(in: -20000 ... -7200)
            sut.ntpOffset = random
            XCTAssert(sut.ntpOffset == random)
            XCTAssert(sut.timeHintIsHidden == false)
        }
    }
    
    func testTick() throws {
        let expectationOfTick = expectation(description: "Tick method has to be called and completed")
        let fakeDate = Date()
        let fakeOffset = TimeInterval(-100)
        sut.ntpDate = fakeDate
        sut.ntpOffset = fakeOffset
        sut.tick { [self] in
            let dateHasChanged: Bool = sut.ntpDate != fakeDate
            let offsetHasChanged: Bool = sut.ntpOffset != fakeOffset
            XCTAssert(dateHasChanged && offsetHasChanged)
            expectationOfTick.fulfill()
        }
        self.waitForExpectations(timeout: 1.0, handler: nil)
    }

    func testUpdateTitle_offlineMessageCertificates_and_offlineMessageRules_not_nil() {
        // Given
        let expectedTitle = Localizer.localized(
            "validation_start_screen_offline_modus_note_update",
            bundle: Bundle.main
        )
        prepareSut(
            lastUpdateTrustList: .init(timeIntervalSinceReferenceDate: 0),
            lastUpdateDccrRules: .init(timeIntervalSinceReferenceDate: 0)
        )

        // When
        let title = sut.updateTitle

        // Then
        XCTAssertEqual(title, expectedTitle)
    }

    func testUpdateTitle_offlineMessageCertificates_and_offlineMessageRules_nil() throws {
        // Given
        let userDefaults = UserDefaultsPersistence()
        try userDefaults.delete(UserDefaults.keyLastUpdatedDCCRules)
        try userDefaults.delete(UserDefaults.keyLastUpdatedTrustList)
        prepareSut()

        // When
        let title = sut.updateTitle

        // Then
        XCTAssertTrue(title.isEmpty)
    }

    private func prepareSut(lastUpdateTrustList: Date? = nil, lastUpdateDccrRules: Date? = nil, appVersion: String? = nil) {
        let repository = VaccinationRepositoryMock()
        let certLogic = DCCCertLogicMock()
        if let lastUpdateTrustList = lastUpdateTrustList {
            userDefaults.lastUpdatedTrustList = lastUpdateTrustList
        }
        if let lastUpdateDccrRules = lastUpdateDccrRules {
            userDefaults.lastUpdatedDCCRules = lastUpdateDccrRules
        }
        sut = .init(
            router: router,
            repository: repository,
            revocationRepository: CertificateRevocationRepositoryMock(),
            certLogic: certLogic,
            userDefaults: userDefaults,
            privacyFile: Constants.Keys.privacyFile,
            appVersion: appVersion
        )
    }

    func testUpdateTitle_offlineMessageCertificates_not_nil() {
        // Given
        let expectedTitle = Localizer.localized(
            "validation_start_screen_offline_modus_note_update",
            bundle: Bundle.main
        )
        prepareSut(lastUpdateTrustList: .init(timeIntervalSinceReferenceDate: 0))

        // When
        let title = sut.updateTitle

        // Then
        XCTAssertEqual(title, expectedTitle)
    }

    func testUpdateTitle_offlineMessageRules_not_nil() {
        // Given
        let expectedTitle = Localizer.localized(
            "validation_start_screen_offline_modus_note_update",
            bundle: Bundle.main
        )
        prepareSut(lastUpdateDccrRules: .init(timeIntervalSinceReferenceDate: 0))

        // When
        let title = sut.updateTitle

        // Then
        XCTAssertEqual(title, expectedTitle)
    }

    func testShowNotificationsIfNeeded_showDataPrivacy_never_shown_before() {
        // Given
        let privacyHash = Constants.Keys.privacyFile.sha256()
        prepareSut()
        
        // When
        sut.showNotificationsIfNeeded()

        // Then
        wait(for: [router.showDataPrivacyExpectation], timeout: 1)
        XCTAssertEqual(userDefaults.privacyHash, privacyHash)
    }

    func testShowNotificationsIfNeeded_showDataPrivacy_was_shown_for_this_version() {
        // Given
        let privacyHash = Constants.Keys.privacyFile.sha256()
        router.showDataPrivacyExpectation.isInverted = true
        userDefaults.privacyShownForAppVersion = "0.1"
        userDefaults.privacyHash = privacyHash
        prepareSut(appVersion: "0.1")

        // When
        sut.showNotificationsIfNeeded()

        // Then
        wait(for: [router.showDataPrivacyExpectation], timeout: 1)
    }

    func testShowNotificationsIfNeeded_showDataPrivacy_was_not_shown_for_this_version() {
        // Given
        let privacyHash = Constants.Keys.privacyFile.sha256()
        userDefaults.privacyShownForAppVersion = "0.1"
        userDefaults.privacyHash = privacyHash
        prepareSut(appVersion: "0.2")

        // When
        sut.showNotificationsIfNeeded()

        // Then
        wait(for: [router.showDataPrivacyExpectation], timeout: 1)
        XCTAssertEqual(userDefaults.privacyShownForAppVersion, "0.2")
    }

    func testShowNotificationsIfNeeded_showDataPrivacy_was_shown_for_other_version() {
        // Given
        let privacyHash = Constants.Keys.privacyFile.sha256()
        userDefaults.privacyHash = "".sha256()
        prepareSut()

        // When
        sut.showNotificationsIfNeeded()

        // Then
        wait(for: [router.showDataPrivacyExpectation], timeout: 1)
        XCTAssertEqual(userDefaults.privacyHash, privacyHash)
    }
}
