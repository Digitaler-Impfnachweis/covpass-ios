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
    var showSameCertTypeExpectation = XCTestExpectation(description: "showSameCertTypeExpectation")
    var showDifferentPersonResult = DifferentPersonResult.startover
    var showVaccinationCycleCompleteExpectation = XCTestExpectation(description: "showVaccinationCycleCompleteExpectation")
    var showIfsg22aCheckDifferentPersonExpectation = XCTestExpectation(description: "showIfsg22aCheckDifferentPersonExpectation")
    var showIfsg22aNotCompleteExpectation = XCTestExpectation(description: "showIfsg22aCheckSecondScanAllowedExpectation")
    var showIfsg22aCheckErrorExpectation = XCTestExpectation(description: "showIfsg22aCheckTechnicalErrorExpectation")
    var showIfsg22aIncompleteResultExpectation = XCTestExpectation(description: "showIfsg22aIncompleteResultExpectation")
    var routeToChooseCheckSituationExpectation = XCTestExpectation(description: "routeToChooseCheckSituationExpectation")
    var showTravelRulesValidExpectation = XCTestExpectation(description: "showTravelRulesValidExpectation")
    var showTravelRulesInvalidExpectation = XCTestExpectation(description: "showTravelRulesInvalidExpectation")
    var showTravelRulesNotAvailableExpectation = XCTestExpectation(description: "showTravelRulesNotAvailableExpectation")
    var showTravelRulesNotAvailableResponse: Promise<Void> = .value

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
        return .value(.scanResult(.success("")))
    }

    func showDataPrivacy() -> Promise<Void> {
        showDataPrivacyExpectation.fulfill()
        return .value
    }

    func routeToRulesUpdate(userDefaults _: Persistence) -> Promise<Void> {
        .value
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

    func showMaskCheckDifferentPerson(token1OfPerson _: ExtendedCBORWebToken, token2OfPerson _: ExtendedCBORWebToken) -> Promise<DifferentPersonResult> {
        showDifferentPersonExpectation.fulfill()
        return .value(showDifferentPersonResult)
    }

    func showMaskCheckSameCertType() {
        showSameCertTypeExpectation.fulfill()
    }

    func showVaccinationCycleComplete(token _: ExtendedCBORWebToken) -> Promise<ValidatorDetailSceneResult> {
        showVaccinationCycleCompleteExpectation.fulfill()
        return .value(.close)
    }

    func showIfsg22aCheckDifferentPerson(token1OfPerson _: ExtendedCBORWebToken, token2OfPerson _: ExtendedCBORWebToken) -> Promise<ValidatorDetailSceneResult> {
        showIfsg22aCheckDifferentPersonExpectation.fulfill()
        return .value(.close)
    }

    func showIfsg22aNotComplete(token _: ExtendedCBORWebToken, secondToken _: ExtendedCBORWebToken?) -> Promise<ValidatorDetailSceneResult> {
        showIfsg22aNotCompleteExpectation.fulfill()
        return .value(.close)
    }

    func showIfsg22aCheckError(token _: ExtendedCBORWebToken?) -> Promise<ValidatorDetailSceneResult> {
        showIfsg22aCheckErrorExpectation.fulfill()
        return .value(.close)
    }

    func showIfsg22aIncompleteResult(token _: ExtendedCBORWebToken) -> Promise<ValidatorDetailSceneResult> {
        showIfsg22aIncompleteResultExpectation.fulfill()
        return .value(.close)
    }
}
