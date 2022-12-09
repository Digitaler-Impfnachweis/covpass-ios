//
//  ValidatorOverviewViewModel.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import CertLogic
@testable import CovPassCheckApp
@testable import CovPassCommon
@testable import CovPassUI
import SwiftyJSON
import XCTest

private enum Constants {
    enum Keys {
        static var syncTitle = "validation_start_screen_scan_sync_message_title"
        static var syncMessage = "validation_start_screen_scan_sync_message_text"
        static let privacyFile = "PRIVACY INFO"
    }
}

class ValidatorOverviewViewModelTests: XCTestCase {
    private var audioPlayer: AudioPlayerMock!
    private var userDefaults: MockPersistence!
    private var router: ValidatorMockRouter!
    private var sut: ValidatorOverviewViewModel!
    private var certLogic: DCCCertLogicMock!
    private var repository: VaccinationRepositoryMock!
    private var certificateHolderStatus: CertificateHolderStatusModelMock!
    private var revocationRepository: CertificateRevocationRepositoryMock!
    private let invalidationRule = Rule(type: "Invalidation")
    private let maskRule = Rule(type: "Mask")
    private let acceptenceRule = Rule(type: "Acceptence")
    private let bZweiRule = Rule(type: "ImpfstatusBZwei")

    override func setUp() {
        super.setUp()
        revocationRepository = CertificateRevocationRepositoryMock()
        repository = VaccinationRepositoryMock()
        certLogic = DCCCertLogicMock()
        certificateHolderStatus = .init()
        audioPlayer = .init()
        router = .init()
        userDefaults = .init()
        prepareSut()
    }

    override func tearDown() {
        revocationRepository = nil
        repository = nil
        certLogic = nil
        certificateHolderStatus = nil
        audioPlayer = nil
        router = nil
        userDefaults = nil
        sut = nil
        super.tearDown()
    }

    private func prepareSut(lastUpdateTrustList: Date? = nil, lastUpdateDccrRules: Date? = nil) {
        if let lastUpdateTrustList = lastUpdateTrustList {
            userDefaults.lastUpdatedTrustList = lastUpdateTrustList
        }
        if let lastUpdateDccrRules = lastUpdateDccrRules {
            userDefaults.lastUpdatedDCCRules = lastUpdateDccrRules
        }
        sut = .init(
            router: router,
            repository: repository,
            revocationRepository: revocationRepository,
            certificateHolderStatus: certificateHolderStatus,
            certLogic: certLogic,
            userDefaults: userDefaults,
            privacyFile: Constants.Keys.privacyFile,
            audioPlayer: audioPlayer
        )
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
        for _ in 0 ... 10 {
            let random = Double.random(in: 0 ... 7199)
            sut.ntpOffset = random
            XCTAssert(sut.ntpOffset == random)
            XCTAssert(sut.timeHintIsHidden == true)
        }
    }

    func testRandomOffsetsWhereHintShouldBeNotHidden() throws {
        for _ in 0 ... 10 {
            let random = Double.random(in: 7200 ... 20000)
            sut.ntpOffset = random
            XCTAssert(sut.ntpOffset == random)
            XCTAssert(sut.timeHintIsHidden == false)
        }
    }

    func testRandomOffsetsWhereHintShouldBeHiddenPast() throws {
        for _ in 0 ... 10 {
            let random = Double.random(in: -7199 ... -0)
            sut.ntpOffset = random
            XCTAssert(sut.ntpOffset == random)
            XCTAssert(sut.timeHintIsHidden == true)
        }
    }

    func testRandomOffsetsWhereHintShouldBeNotHiddenPast() throws {
        for _ in 0 ... 10 {
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
        waitForExpectations(timeout: 1.0, handler: nil)
    }

    func testShowNotificationsIfNeeded_dont_showDataPrivacy_never_shown_before() {
        // Given
        let privacyHash = Constants.Keys.privacyFile.sha256()
        userDefaults.privacyHash = nil
        router.showDataPrivacyExpectation.isInverted = true
        prepareSut()

        // When
        sut.showNotificationsIfNeeded()

        // Then
        wait(for: [router.showDataPrivacyExpectation], timeout: 0.1)
        XCTAssertEqual(userDefaults.privacyHash, privacyHash)
    }

    func testShowNotificationsIfNeeded_showDataPrivacy_was_shown_for_this_version() {
        // Given
        let privacyHash = Constants.Keys.privacyFile.sha256()
        router.showDataPrivacyExpectation.isInverted = true
        userDefaults.privacyHash = privacyHash

        // When
        sut.showNotificationsIfNeeded()

        // Then
        wait(for: [router.showDataPrivacyExpectation], timeout: 1)
    }

    func testShowNotificationsIfNeeded_showDataPrivacy_was_not_shown_for_this_version() {
        // Given
        let privacyHash = Constants.Keys.privacyFile.sha256()
        userDefaults.privacyHash = privacyHash + "A"

        // When
        XCTAssertNotEqual(userDefaults.privacyHash, privacyHash)
        sut.showNotificationsIfNeeded()

        // Then
        wait(for: [router.showDataPrivacyExpectation], timeout: 1)
        XCTAssertEqual(userDefaults.privacyHash, privacyHash)
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

    func testShowNotificationsIfNeeded_showNewRegulationsAnnouncementIfNeeded_never_shown_before() {
        // When
        sut.showNotificationsIfNeeded()

        // Then
        wait(for: [router.showNewRegulationsAnnouncementExpectation], timeout: 1)
    }

    func testShowNotificationsIfNeeded_showNewRegulationsAnnouncementIfNeeded_was_shown_before() {
        // Given
        router.showNewRegulationsAnnouncementExpectation.isInverted = true
        userDefaults.newRegulationsOnboardingScreenWasShown = true

        // When
        sut.showNotificationsIfNeeded()

        // Then
        wait(for: [router.showNewRegulationsAnnouncementExpectation], timeout: 1)
    }

    func testStartQRCodeValidation() {
        // When
        sut.checkMaskStatus()

        // Then
        wait(for: [
            router.scanQRCodeExpectation,
            audioPlayer.playCovPassCheckCertificateScannedIfEnabledExpectation
        ], timeout: 1)
    }

    func testStateSelection() {
        // When
        sut.chooseAction()

        // Then
        wait(for: [router.routeToStateSelectionExpectation], timeout: 1)
    }

    func test_scanAction_showMaskRequiredTechnicalError_unexpected() {
        // When
        sut.checkMaskStatus()

        // Then
        wait(for: [
            router.showMaskRulesInvalidExpectation
        ], timeout: 1)
    }

    func test_scanAction_showMaskRequiredTechnicalError_alternative() {
        // GIVEN
        certLogic.validateResult = []
        repository.checkedCert = CBORWebToken.mockVaccinationCertificate
        // When
        sut.checkMaskStatus()

        // Then
        wait(for: [
            router.showMaskRequiredBusinessRulesSecondScanAllowedExpectation
        ], timeout: 1)
    }

    func test_scanAction_showMaskRequiredBusinessRules() {
        // GIVEN
        certLogic.validateResult = [.init(rule: acceptenceRule, result: .fail)]
        repository.checkedCert = CBORWebToken.mockVaccinationCertificate
        // When
        sut.checkMaskStatus()

        // Then
        wait(for: [
            router.showMaskRequiredBusinessRulesExpectation
        ], timeout: 1)
    }

    func test_scanAction_showMaskRequiredBusinessRulesSecondScanAllowed() {
        // GIVEN
        certLogic.validateResult = [.init(rule: invalidationRule, result: .passed)]
        repository.checkedCert = CBORWebToken.mockVaccinationCertificate
        // When
        sut.checkMaskStatus()

        // Then
        wait(for: [
            router.showMaskRequiredBusinessRulesSecondScanAllowedExpectation
        ], timeout: 1)
    }

    func test_scanAction_showMaskRequiredBusinessRules_testCertificate() {
        // GIVEN
        certLogic.validateResult = [.init(rule: invalidationRule, result: .passed)]
        repository.checkedCert = CBORWebToken.mockTestCertificate
        // When
        sut.checkMaskStatus()

        // Then
        wait(for: [
            router.showMaskRequiredBusinessRulesExpectation
        ], timeout: 1)
    }

    func test_scanAction_showNoMaskRules() {
        // GIVEN
        certLogic.areRulesAvailable = false
        repository.checkedCert = CBORWebToken.mockVaccinationCertificate
        // When
        sut.checkMaskStatus()

        // Then
        wait(for: [
            router.showNoMaskRulesExpectation
        ], timeout: 1)
    }

    func test_scanAction_showMaskRequiredTechnicalError_alternative_revoked() {
        // GIVEN
        revocationRepository.isRevoked = true
        repository.checkedCert = CBORWebToken.mockVaccinationCertificate
        // When
        sut.checkMaskStatus()

        // Then
        wait(for: [
            router.showMaskRulesInvalidExpectation
        ], timeout: 1)
    }

    func test_scanAction_secondScan_differentPerson() {
        // GIVEN
        certLogic.validateResult = [.init(rule: invalidationRule, result: .passed),
                                    .init(rule: maskRule, result: .passed)]
        repository.checkedCert = CBORWebToken.mockVaccinationCertificateWithOtherName
        // When
        sut.checkMaskStatus(firstToken: CBORWebToken.mockRecoveryCertificate.extended(vaccinationQRCodeData: "1"))

        // Then
        wait(for: [
            router.showDifferentPersonExpectation
        ], timeout: 1)
    }

    func test_scanAction_secondScan_differentPerson_ignoring() {
        // GIVEN
        certLogic.validateResult = [.init(rule: invalidationRule, result: .passed),
                                    .init(rule: maskRule, result: .passed)]
        let firstToken = CBORWebToken.mockRecoveryCertificate.extended(vaccinationQRCodeData: "1")
        let secondToken = CBORWebToken.mockVaccinationCertificateWithOtherName.extended(vaccinationQRCodeData: "2")
        repository.checkedCert = secondToken.vaccinationCertificate
        // When
        sut.checkMaskStatus(firstToken: firstToken, secondToken: secondToken, ignoringPiCheck: true)

        // Then
        wait(for: [
            router.showMaskOptionalExpectation
        ], timeout: 1)
    }

    func test_scanAction_secondScan_differentPerson_ignoring_after_response() {
        // GIVEN
        certLogic.validateResult = [.init(rule: invalidationRule, result: .passed),
                                    .init(rule: maskRule, result: .passed)]
        let firstToken = CBORWebToken.mockRecoveryCertificate.extended(vaccinationQRCodeData: "1")
        let secondToken = CBORWebToken.mockVaccinationCertificateWithOtherName.extended(vaccinationQRCodeData: "2")
        repository.checkedCert = secondToken.vaccinationCertificate
        router.showDifferentPersonResult = .ignore(firstToken, secondToken, nil)
        // When
        sut.checkMaskStatus(firstToken: firstToken)

        // Then
        wait(for: [
            router.showDifferentPersonExpectation,
            router.showMaskOptionalExpectation
        ], timeout: 1)
    }

    func test_maskCheck_secondScan_sameCert() {
        // GIVEN
        let token = CBORWebToken.mockVaccinationCertificate
            .extended()
        let additionalToken = CBORWebToken.mockVaccinationCertificate
            .extended(vaccinationQRCodeData: "1")
        repository.checkedCert = token.vaccinationCertificate
        router.scanQRCodeResponse = "1"
        // When
        sut.checkMaskStatus(firstToken: additionalToken)
        // Then
        wait(for: [
            router.secondScanSameTokenExpectation
        ], timeout: 1)
    }

    func test_scanAction_showMaskOptional() {
        // GIVEN
        certLogic.validateResult = [.init(rule: invalidationRule, result: .passed),
                                    .init(rule: maskRule, result: .passed)]
        repository.checkedCert = CBORWebToken.mockVaccinationCertificate
        // When
        sut.checkMaskStatus()

        // Then
        wait(for: [
            router.showMaskOptionalExpectation
        ], timeout: 1)
    }

    func test_checkImmunityStatus_vaccinationCycleIsComplete() {
        // GIVEN
        userDefaults.checkSituation = CheckSituationType.withinGermany.rawValue
        certLogic.validateResult = [.init(rule: invalidationRule, result: .passed),
                                    .init(rule: bZweiRule, result: .passed)]
        repository.checkedCert = CBORWebToken.mockVaccinationCertificate
        // When
        sut.checkImmunityStatus()
        // Then
        wait(for: [
            router.showVaccinationCycleCompleteExpectation
        ], timeout: 1)
    }

    func test_checkImmunityStatus_vaccinationCycleIsComplete_but_invalidation_fails() {
        // GIVEN
        userDefaults.checkSituation = CheckSituationType.withinGermany.rawValue
        certLogic.validateResult = [.init(rule: invalidationRule, result: .fail),
                                    .init(rule: bZweiRule, result: .passed)]
        repository.checkedCert = CBORWebToken.mockVaccinationCertificate
        // When
        sut.checkImmunityStatus()
        // Then
        wait(for: [
            router.showIfsg22aCheckErrorExpectation
        ], timeout: 1)
    }

    func test_checkImmunityStatus_vaccinationCycleIsNOTComplete() {
        // GIVEN
        userDefaults.checkSituation = CheckSituationType.withinGermany.rawValue
        certLogic.validateResult = [.init(rule: invalidationRule, result: .passed),
                                    .init(rule: bZweiRule, result: .fail)]
        repository.checkedCert = CBORWebToken.mockVaccinationCertificate
        // When
        sut.checkImmunityStatus()
        // Then
        wait(for: [
            router.showIfsg22aNotCompleteExpectation
        ], timeout: 1)
    }

    func test_checkImmunityStatus_certificate_is_revoked() {
        // GIVEN
        userDefaults.checkSituation = CheckSituationType.withinGermany.rawValue
        revocationRepository.isRevoked = true
        repository.checkedCert = CBORWebToken.mockVaccinationCertificate
        // When
        sut.checkImmunityStatus()
        // Then
        wait(for: [
            router.showIfsg22aCheckErrorExpectation
        ], timeout: 1)
    }

    func test_checkImmunityStatus_secondScan_differentPerson() {
        // GIVEN
        userDefaults.checkSituation = CheckSituationType.withinGermany.rawValue
        certLogic.validateResult = [.init(rule: invalidationRule, result: .passed),
                                    .init(rule: maskRule, result: .passed)]
        let token = CBORWebToken
            .mockVaccinationCertificateWithOtherName
            .extended(vaccinationQRCodeData: "1")
        let secondToken = CBORWebToken
            .mockRecoveryCertificate
            .extended(vaccinationQRCodeData: "2")
        repository.checkedCert = token.vaccinationCertificate
        // When
        sut.checkImmunityStatusWithinGermany(secondToken: secondToken)
        // Then
        wait(for: [
            router.showIfsg22aCheckDifferentPersonExpectation
        ], timeout: 1)
    }

    func test_checkImmunityStatus_secondScan_differentPerson_ignoring_after_reponse() {
        // GIVEN
        userDefaults.checkSituation = CheckSituationType.withinGermany.rawValue
        certLogic.validateResult = [.init(rule: invalidationRule, result: .passed),
                                    .init(rule: maskRule, result: .passed)]
        let secondToken = CBORWebToken
            .mockVaccinationCertificateWithOtherName
            .extended(vaccinationQRCodeData: "1")
        let firstToken = CBORWebToken
            .mockRecoveryCertificate
            .extended(vaccinationQRCodeData: "2")
        router.showIfsg22aCheckDifferentPersonResponse = .value(.ignore(firstToken, secondToken, nil))
        repository.checkedCert = firstToken.vaccinationCertificate
        // When
        sut.checkImmunityStatusWithinGermany(secondToken: secondToken)
        // Then
        wait(for: [
            router.showIfsg22aCheckDifferentPersonExpectation,
            router.showVaccinationCycleCompleteExpectation
        ], timeout: 1, enforceOrder: true)
    }

    func test_checkImmunityStatus_secondScan_differentPerson_ignoring() {
        // GIVEN
        userDefaults.checkSituation = CheckSituationType.withinGermany.rawValue
        certLogic.validateResult = [.init(rule: invalidationRule, result: .passed),
                                    .init(rule: maskRule, result: .passed)]
        let token = CBORWebToken
            .mockVaccinationCertificateWithOtherName
            .extended(vaccinationQRCodeData: "1")
        let secondToken = CBORWebToken
            .mockRecoveryCertificate
            .extended(vaccinationQRCodeData: "2")
        repository.checkedCert = token.vaccinationCertificate
        // When
        sut.checkImmunityStatusWithinGermany(secondToken: secondToken, ignoringPiCheck: true)
        // Then
        wait(for: [
            router.showVaccinationCycleCompleteExpectation
        ], timeout: 1)
    }

    func test_checkImmunityStatus_thirdScan_differentPerson() {
        // GIVEN
        userDefaults.checkSituation = CheckSituationType.withinGermany.rawValue
        certLogic.validateResult = [.init(rule: invalidationRule, result: .passed),
                                    .init(rule: maskRule, result: .passed)]
        let thirdToken = CBORWebToken
            .mockVaccinationCertificateWithOtherName
            .extended(vaccinationQRCodeData: "1")
        let secondToken = CBORWebToken
            .mockRecoveryCertificate
            .extended(vaccinationQRCodeData: "2")
        let firstToken = CBORWebToken
            .mockRecoveryCertificate
            .extended(vaccinationQRCodeData: "3")
        repository.checkedCert = thirdToken.vaccinationCertificate
        // When
        sut.checkImmunityStatusWithinGermany(firstToken: firstToken, secondToken: secondToken)
        // Then
        wait(for: [
            router.showIfsg22aCheckDifferentPersonExpectation
        ], timeout: 1)
    }

    func test_checkImmunityStatus_thirdScan_differentPerson_ignoring_after_reponse() {
        // GIVEN
        userDefaults.checkSituation = CheckSituationType.withinGermany.rawValue
        certLogic.validateResult = [.init(rule: invalidationRule, result: .passed),
                                    .init(rule: maskRule, result: .passed)]
        let thirdToken = CBORWebToken
            .mockVaccinationCertificateWithOtherName
            .extended(vaccinationQRCodeData: "1")
        let secondToken = CBORWebToken
            .mockRecoveryCertificate
            .extended(vaccinationQRCodeData: "2")
        let firstToken = CBORWebToken
            .mockRecoveryCertificate
            .extended(vaccinationQRCodeData: "3")
        router.showIfsg22aCheckDifferentPersonResponse = .value(.ignore(firstToken, secondToken, thirdToken))
        repository.checkedCert = thirdToken.vaccinationCertificate
        // When
        sut.checkImmunityStatusWithinGermany(firstToken: firstToken, secondToken: secondToken)
        // Then
        wait(for: [
            router.showIfsg22aCheckDifferentPersonExpectation,
            router.showVaccinationCycleCompleteExpectation
        ], timeout: 1, enforceOrder: true)
    }

    func test_checkImmunityStatus_thirdScan_differentPerson_ignoring() {
        // GIVEN
        userDefaults.checkSituation = CheckSituationType.withinGermany.rawValue
        certLogic.validateResult = [.init(rule: invalidationRule, result: .passed),
                                    .init(rule: maskRule, result: .passed)]
        let thirdToken = CBORWebToken
            .mockVaccinationCertificateWithOtherName
            .extended(vaccinationQRCodeData: "1")
        let secondToken = CBORWebToken
            .mockRecoveryCertificate
            .extended(vaccinationQRCodeData: "2")
        let firstToken = CBORWebToken
            .mockRecoveryCertificate
            .extended(vaccinationQRCodeData: "3")
        repository.checkedCert = thirdToken.vaccinationCertificate
        // When
        sut.checkImmunityStatusWithinGermany(firstToken: firstToken, secondToken: secondToken, thirdToken: thirdToken, ignoringPiCheck: true)
        // Then
        wait(for: [
            router.showVaccinationCycleCompleteExpectation
        ], timeout: 1)
    }

    func test_checkImmunityStatus_secondScan_sameCertType() {
        // GIVEN
        userDefaults.checkSituation = CheckSituationType.withinGermany.rawValue
        let token = CBORWebToken.mockVaccinationCertificate
            .extended(vaccinationQRCodeData: "1")
        let additionalToken = CBORWebToken.mockVaccinationCertificate
            .extended(vaccinationQRCodeData: "2")
        repository.checkedCert = token.vaccinationCertificate
        // When
        sut.checkImmunityStatusWithinGermany(secondToken: additionalToken)
        // Then
        wait(for: [
            router.showIfsg22aNotCompleteExpectation
        ], timeout: 1)
    }

    func test_checkImmunityStatus_secondScan_sameCert() {
        // GIVEN
        userDefaults.checkSituation = CheckSituationType.withinGermany.rawValue
        let token = CBORWebToken.mockVaccinationCertificate
            .extended(vaccinationQRCodeData: "1")
        let additionalToken = CBORWebToken.mockVaccinationCertificate
            .extended(vaccinationQRCodeData: "1")
        repository.checkedCert = token.vaccinationCertificate
        router.scanQRCodeResponse = "1"
        // When
        sut.checkImmunityStatusWithinGermany(secondToken: additionalToken)
        // Then
        wait(for: [
            router.secondScanSameTokenExpectation
        ], timeout: 1)
    }

    func test_checkImmunityStatus_error() {
        // GIVEN
        userDefaults.checkSituation = CheckSituationType.withinGermany.rawValue
        // When
        sut.checkImmunityStatus()
        // Then
        wait(for: [
            router.showIfsg22aCheckErrorExpectation
        ], timeout: 1)
    }

    func test_checkImmunityStatus_entering_germany_valid() {
        // GIVEN
        userDefaults.checkSituation = CheckSituationType.enteringGermany.rawValue
        repository.checkedCert = CBORWebToken.mockVaccinationCertificate
        // When
        sut.checkImmunityStatus()
        // Then
        wait(for: [
            router.showTravelRulesValidExpectation
        ], timeout: 1)
    }

    func test_checkImmunityStatus_entering_germany_valid_revoked() {
        // GIVEN
        userDefaults.checkSituation = CheckSituationType.enteringGermany.rawValue
        revocationRepository.isRevoked = true
        let token = CBORWebToken.mockVaccinationCertificate
        repository.checkedCert = token
        // When
        sut.checkImmunityStatus()
        // Then
        wait(for: [
            router.showTravelRulesInvalidExpectation
        ], timeout: 1)
    }

    func test_checkImmunityStatus_entering_germany_invalid() {
        // GIVEN
        userDefaults.checkSituation = CheckSituationType.enteringGermany.rawValue
        // When
        sut.checkImmunityStatus()
        // Then
        wait(for: [
            router.showTravelRulesInvalidExpectation
        ], timeout: 1)
    }

    func test_checkImmunityStatus_entering_germany_see_no_rules_available_popup() {
        // GIVEN
        userDefaults.checkSituation = CheckSituationType.enteringGermany.rawValue
        certificateHolderStatus.areTravelRulesAvailableForGermanyResponse = false
        // When
        sut.checkImmunityStatus()
        // Then
        wait(for: [
            router.showTravelRulesNotAvailableExpectation
        ], timeout: 1)
    }

    func test_selectedCheckType_mask() {
        // When
        sut.selectedCheckType = .mask
        // Then
        XCTAssertEqual(userDefaults.selectedCheckType, CheckType.mask.rawValue)
    }

    func test_selectedCheckType_immunity() {
        // When
        sut.selectedCheckType = .immunity
        // Then
        XCTAssertEqual(userDefaults.selectedCheckType, CheckType.immunity.rawValue)
    }

    func test_selectedCheckType_immunity_checkSituationNotSeenBefore() {
        // GIVEN
        UserDefaults.standard.set(nil, forKey: UserDefaults.keyCheckSituation)
        // When
        sut.selectedCheckType = .immunity
        // Then
        wait(for: [
            router.routeToChooseCheckSituationExpectation
        ], timeout: 1)
    }

    func test_selectedCheckType_immunity_checkSituationSeenBefore() {
        // GIVEN
        UserDefaults.standard.set(CheckSituationType.withinGermany.rawValue, forKey: UserDefaults.keyCheckSituation)
        router.routeToChooseCheckSituationExpectation.isInverted = true
        // When
        sut.selectedCheckType = .immunity
        // Then
        wait(for: [
            router.routeToChooseCheckSituationExpectation
        ], timeout: 1)
    }

    func test_routeToRulesUpdate() {
        // When
        sut.routeToRulesUpdate()

        // Then
        wait(for: [
            router.routeToRulesUpdateExpectation
        ], timeout: 1)
    }

    func test_showNotificationsIfNeeded_announcement_already_shown() throws {
        // Given
        userDefaults.disableWhatsNew = false
        userDefaults.announcementVersion = Bundle.main.shortVersionString ?? ""
        router.showAnnouncementExpectation.isInverted = true

        // When
        sut.showNotificationsIfNeeded()

        // Then
        wait(for: [router.showAnnouncementExpectation], timeout: 1)
    }

    func test_showNotificationsIfNeeded_announcement_not_shown() throws {
        // Given
        userDefaults.disableWhatsNew = false
        userDefaults.announcementVersion = ""

        // When
        sut.showNotificationsIfNeeded()

        // Then
        wait(for: [router.showAnnouncementExpectation], timeout: 1)
    }

    func test_showNotificationsIfNeeded_announcement_disabled() throws {
        // Given
        userDefaults.disableWhatsNew = true
        userDefaults.announcementVersion = ""
        router.showAnnouncementExpectation.isInverted = true

        // When
        sut.showNotificationsIfNeeded()

        // Then
        wait(for: [router.showAnnouncementExpectation], timeout: 1)
    }
}
