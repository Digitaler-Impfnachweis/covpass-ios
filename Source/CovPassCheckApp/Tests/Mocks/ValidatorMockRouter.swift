//
//  ValidatorRouterMock.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassCheckApp
import CovPassCommon
import CovPassUI
import PromiseKit
import XCTest

class ValidatorMockRouter: ValidatorOverviewRouterProtocol {
    var sceneCoordinator: SceneCoordinator = SceneCoordinatorMock()
    var showDataPrivacyExpectation = XCTestExpectation(description: "showDataPrivacyExpectation")
    var showGproofExpectation = XCTestExpectation(description: "showGproofExpectation")
    var scanQRCodeExpectation = XCTestExpectation(description: "scanQRCodeExpectation")
    var routeToStateSelectionExpectation = XCTestExpectation(description: "routeToStateSelection")
    var showDifferentPersonExpectation = XCTestExpectation(description: "showDifferentPersonExpectation")
    var showDifferentPersonResult = ValidatorDetailSceneResult.startOver
    var showVaccinationCycleCompleteExpectation = XCTestExpectation(description: "showVaccinationCycleCompleteExpectation")
    var showIfsg22aCheckDifferentPersonExpectation = XCTestExpectation(description: "showIfsg22aCheckDifferentPersonExpectation")
    var showIfsg22aCheckDifferentPersonResponse: Promise<ValidatorDetailSceneResult> = .value(.close)
    var showIfsg22aNotCompleteExpectation = XCTestExpectation(description: "showIfsg22aCheckSecondScanAllowedExpectation")
    var showIfsg22aCheckErrorExpectation = XCTestExpectation(description: "showIfsg22aCheckTechnicalErrorExpectation")
    var showIfsg22aIncompleteResultExpectation = XCTestExpectation(description: "showIfsg22aIncompleteResultExpectation")
    var routeToChooseCheckSituationExpectation = XCTestExpectation(description: "routeToChooseCheckSituationExpectation")
    var showTravelRulesValidExpectation = XCTestExpectation(description: "showTravelRulesValidExpectation")
    var showTravelRulesInvalidExpectation = XCTestExpectation(description: "showTravelRulesInvalidExpectation")
    var showTravelRulesNotAvailableExpectation = XCTestExpectation(description: "showTravelRulesNotAvailableExpectation")
    var routeToRulesUpdateExpectation = XCTestExpectation(description: "routeToRulesUpdateExpectation")
    var showAnnouncementExpectation = XCTestExpectation(description: "showAnnouncementExpectation")
    var showTravelRulesNotAvailableResponse: Promise<Void> = .value
    var secondScanSameTokenExpectation = XCTestExpectation(description: "secondScanSameTokenTypeExpectation")
    var thirdScanSameTokenExpectation = XCTestExpectation(description: "secondScanSameTokenTypeExpectation")
    var scanQRCodeResponse: String = ""

    func showSundownInfo() -> Promise<Void> {
        .value
    }

    func sameTokenScanned() -> Promise<ValidatorDetailSceneResult> {
        secondScanSameTokenExpectation.fulfill()
        return .value(.rescan)
    }

    func showAnnouncement() -> PromiseKit.Promise<Void> {
        showAnnouncementExpectation.fulfill()
        return .value
    }

    func showTravelRulesNotAvailable() -> Promise<Void> {
        showTravelRulesNotAvailableExpectation.fulfill()
        return showTravelRulesNotAvailableResponse
    }

    func showTravelRulesValid(token _: ExtendedCBORWebToken) -> Promise<ValidatorDetailSceneResult> {
        showTravelRulesValidExpectation.fulfill()
        return .value(.close)
    }

    func showTravelRulesInvalid(token _: ExtendedCBORWebToken?, rescanIsHidden _: Bool) -> Promise<ValidatorDetailSceneResult> {
        showTravelRulesInvalidExpectation.fulfill()
        return .value(.close)
    }

    func routeToChooseCheckSituation() -> PromiseKit.Promise<Void> {
        routeToChooseCheckSituationExpectation.fulfill()
        return .value
    }

    func showAppInformation(userDefaults _: Persistence) {}

    func showCheckSituation(userDefaults _: Persistence) -> Promise<Void> {
        .value
    }

    func showGproof(boosterAsTest _: Bool) {
        showGproofExpectation.fulfill()
    }

    func scanQRCode() -> Promise<QRCodeImportResult> {
        scanQRCodeExpectation.fulfill()
        return .value(.scanResult(.success(scanQRCodeResponse)))
    }

    func showDataPrivacy() -> Promise<Void> {
        showDataPrivacyExpectation.fulfill()
        return .value
    }

    func routeToRulesUpdate(userDefaults _: Persistence) -> Promise<Void> {
        routeToRulesUpdateExpectation.fulfill()
        return .value
    }

    func routeToStateSelection() -> Promise<Void> {
        routeToStateSelectionExpectation.fulfill()
        return .value
    }

    func showVaccinationCycleComplete(token _: ExtendedCBORWebToken) -> Promise<ValidatorDetailSceneResult> {
        showVaccinationCycleCompleteExpectation.fulfill()
        return .value(.close)
    }

    func showIfsg22aCheckDifferentPerson(tokens _: [CovPassCommon.ExtendedCBORWebToken]) -> Promise<ValidatorDetailSceneResult> {
        showIfsg22aCheckDifferentPersonExpectation.fulfill()
        return showIfsg22aCheckDifferentPersonResponse
    }

    func showIfsg22aNotComplete(tokens _: [CovPassCommon.ExtendedCBORWebToken]) -> Promise<ValidatorDetailSceneResult> {
        showIfsg22aNotCompleteExpectation.fulfill()
        return .value(.close)
    }

    func showIfsg22aCheckError(token _: ExtendedCBORWebToken?, rescanIsHidden _: Bool) -> Promise<ValidatorDetailSceneResult> {
        showIfsg22aCheckErrorExpectation.fulfill()
        return .value(.close)
    }

    func showIfsg22aIncompleteResult() -> Promise<ValidatorDetailSceneResult> {
        showIfsg22aIncompleteResultExpectation.fulfill()
        return .value(.close)
    }
}
