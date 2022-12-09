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
    var showNewRegulationsAnnouncementExpectation = XCTestExpectation(description: "showNewRegulationsAnnouncementExpectation")
    var routeToStateSelectionExpectation = XCTestExpectation(description: "routeToStateSelection")
    var showMaskRequiredBusinessRulesExpectation = XCTestExpectation(description: "showMaskRequiredBusinessRules")
    var showMaskRequiredBusinessRulesSecondScanAllowedExpectation = XCTestExpectation(description: "showMaskRequiredBusinessRulesSecondScanAllowed")
    var showMaskRequiredTechnicalErrorExpectation = XCTestExpectation(description: "showMaskRequiredTechnicalError")
    var showMaskOptionalExpectation = XCTestExpectation(description: "showMaskOptional")
    var showNoMaskRulesExpectation = XCTestExpectation(description: "showNoMaskRulesE")
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
    var showMaskRulesInvalidExpectation = XCTestExpectation(description: "showMaskRulesInvalidExpectation")
    var routeToRulesUpdateExpectation = XCTestExpectation(description: "routeToRulesUpdateExpectation")
    var showAnnouncementExpectation = XCTestExpectation(description: "showAnnouncementExpectation")
    var showTravelRulesNotAvailableResponse: Promise<Void> = .value
    var secondScanSameTokenExpectation = XCTestExpectation(description: "secondScanSameTokenTypeExpectation")
    var thirdScanSameTokenExpectation = XCTestExpectation(description: "secondScanSameTokenTypeExpectation")
    var scanQRCodeResponse: String = ""

    func thirdScanSameToken(secondToken: ExtendedCBORWebToken, firstToken: ExtendedCBORWebToken) -> Promise<ValidatorDetailSceneResult> {
        thirdScanSameTokenExpectation.fulfill()
        return .value(.thirdScan(secondToken, firstToken))
    }

    func secondScanSameToken(token: ExtendedCBORWebToken) -> Promise<ValidatorDetailSceneResult> {
        secondScanSameTokenExpectation.fulfill()
        return .value(.secondScan(token))
    }

    func showAnnouncement() -> PromiseKit.Promise<Void> {
        showAnnouncementExpectation.fulfill()
        return .value
    }

    func showMaskRulesInvalid(token _: ExtendedCBORWebToken?) -> Promise<ValidatorDetailSceneResult> {
        showMaskRulesInvalidExpectation.fulfill()
        return .value(.close)
    }

    func showTravelRulesNotAvailable() -> Promise<Void> {
        showTravelRulesNotAvailableExpectation.fulfill()
        return showTravelRulesNotAvailableResponse
    }

    func showTravelRulesValid(token _: ExtendedCBORWebToken) -> Promise<ValidatorDetailSceneResult> {
        showTravelRulesValidExpectation.fulfill()
        return .value(.close)
    }

    func showTravelRulesInvalid(token _: ExtendedCBORWebToken?) -> Promise<ValidatorDetailSceneResult> {
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

    func showNewRegulationsAnnouncement() -> Promise<Void> {
        showNewRegulationsAnnouncementExpectation.fulfill()
        return .value
    }

    func routeToStateSelection() -> Promise<Void> {
        routeToStateSelectionExpectation.fulfill()
        return .value
    }

    func showMaskRequiredBusinessRules(token _: ExtendedCBORWebToken) -> Promise<ValidatorDetailSceneResult> {
        showMaskRequiredBusinessRulesExpectation.fulfill()
        return .value(.close)
    }

    func showMaskRequiredBusinessRulesSecondScanAllowed(token _: ExtendedCBORWebToken) -> Promise<ValidatorDetailSceneResult> {
        showMaskRequiredBusinessRulesSecondScanAllowedExpectation.fulfill()
        return .value(.close)
    }

    func showMaskRequiredTechnicalError(token _: ExtendedCBORWebToken?) -> Promise<ValidatorDetailSceneResult> {
        showMaskRequiredTechnicalErrorExpectation.fulfill()
        return .value(.close)
    }

    func showMaskOptional(token _: ExtendedCBORWebToken) -> Promise<ValidatorDetailSceneResult> {
        showMaskOptionalExpectation.fulfill()
        return .value(.close)
    }

    func showNoMaskRules(token _: ExtendedCBORWebToken) -> Promise<ValidatorDetailSceneResult> {
        showNoMaskRulesExpectation.fulfill()
        return .value(.close)
    }

    func showMaskCheckDifferentPerson(firstToken _: ExtendedCBORWebToken, secondToken _: ExtendedCBORWebToken) -> Promise<ValidatorDetailSceneResult> {
        showDifferentPersonExpectation.fulfill()
        return .value(showDifferentPersonResult)
    }

    func showVaccinationCycleComplete(token _: ExtendedCBORWebToken) -> Promise<ValidatorDetailSceneResult> {
        showVaccinationCycleCompleteExpectation.fulfill()
        return .value(.close)
    }

    func showIfsg22aCheckDifferentPerson(firstToken _: ExtendedCBORWebToken, secondToken _: ExtendedCBORWebToken, thirdToken _: ExtendedCBORWebToken?) -> Promise<ValidatorDetailSceneResult> {
        showIfsg22aCheckDifferentPersonExpectation.fulfill()
        return showIfsg22aCheckDifferentPersonResponse
    }

    func showIfsg22aNotComplete(token _: ExtendedCBORWebToken, secondToken _: ExtendedCBORWebToken?) -> Promise<ValidatorDetailSceneResult> {
        showIfsg22aNotCompleteExpectation.fulfill()
        return .value(.close)
    }

    func showIfsg22aCheckError(token _: ExtendedCBORWebToken?) -> Promise<ValidatorDetailSceneResult> {
        showIfsg22aCheckErrorExpectation.fulfill()
        return .value(.close)
    }

    func showIfsg22aIncompleteResult() -> Promise<ValidatorDetailSceneResult> {
        showIfsg22aIncompleteResultExpectation.fulfill()
        return .value(.close)
    }
}
