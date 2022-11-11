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
    var showIfsg22aNoCheckRulesExpectation = XCTestExpectation(description: "showIfsg22aCheckRulesExpectation")
    var showIfsg22aCheckDifferentPersonExpectation = XCTestExpectation(description: "showIfsg22aCheckDifferentPersonExpectation")
    var showIfsg22aCheckSameCertExpectation = XCTestExpectation(description: "showIfsg22aCheckSameCertTypeExpectation")
    var showIfsg22aNotCompleteExpectation = XCTestExpectation(description: "showIfsg22aCheckSecondScanAllowedExpectation")
    var showIfsg22aCheckErrorExpectation = XCTestExpectation(description: "showIfsg22aCheckTechnicalErrorExpectation")
    var showIfsg22aCheckTestIsNotAllowedExpectation = XCTestExpectation(description: "showIfsg22aCheckTestIsNotAllowedExpectation")
    var showIfsg22aIncompleteResultExpectation = XCTestExpectation(description: "showIfsg22aIncompleteResultExpectation")
    
    func showAppInformation(userDefaults: Persistence) {
        
    }
    
    func showCheckSituation(userDefaults: Persistence) -> Promise<Void> {
        .value
    }
    
    func showGproof(boosterAsTest: Bool) {
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
    
    func routeToRulesUpdate(userDefaults: Persistence) -> Promise<Void> {
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
    
    func showMaskRequiredBusinessRules(token: ExtendedCBORWebToken) -> Promise<ValidatorDetailSceneResult> {
        showMaskRequiredBusinessRulesExpectation.fulfill()
        return .value(.close)
    }
    
    func showMaskRequiredBusinessRulesSecondScanAllowed(token: ExtendedCBORWebToken) -> Promise<ValidatorDetailSceneResult> {
        showMaskRequiredBusinessRulesSecondScanAllowedExpectation.fulfill()
        return .value(.close)
    }
    
    func showMaskRequiredTechnicalError(token: ExtendedCBORWebToken?) -> Promise<ValidatorDetailSceneResult> {
        showMaskRequiredTechnicalErrorExpectation.fulfill()
        return .value(.close)
    }
    
    func showMaskOptional(token: ExtendedCBORWebToken) -> Promise<ValidatorDetailSceneResult> {
        showMaskOptionalExpectation.fulfill()
        return .value(.close)
    }
    
    func showNoMaskRules(token: ExtendedCBORWebToken) -> Promise<ValidatorDetailSceneResult> {
        showNoMaskRulesExpectation.fulfill()
        return .value(.close)
    }
    
    func showMaskCheckDifferentPerson(token1OfPerson: ExtendedCBORWebToken, token2OfPerson: ExtendedCBORWebToken) -> Promise<DifferentPersonResult> {
        showDifferentPersonExpectation.fulfill()
        return .value(showDifferentPersonResult)
    }
    
    func showMaskCheckSameCertType() {
        showSameCertTypeExpectation.fulfill()
    }

    func showVaccinationCycleComplete(token: ExtendedCBORWebToken) -> Promise<ValidatorDetailSceneResult> {
        showVaccinationCycleCompleteExpectation.fulfill()
        return .value(.close)
    }
    
    func showNoIfsg22aCheckRulesNotAvailable(token: ExtendedCBORWebToken) -> Promise<ValidatorDetailSceneResult> {
        showIfsg22aNoCheckRulesExpectation.fulfill()
        return .value(.close)
    }
    
    func showIfsg22aCheckDifferentPerson(token1OfPerson: ExtendedCBORWebToken, token2OfPerson: ExtendedCBORWebToken) -> Promise<ValidatorDetailSceneResult> {
        showIfsg22aCheckDifferentPersonExpectation.fulfill()
        return .value(.close)
    }
    
    func showIfsg22aCheckSameCert() {
        showIfsg22aCheckSameCertExpectation.fulfill()
    }

    func showIfsg22aNotComplete(token: ExtendedCBORWebToken, isThirdScan: Bool) -> Promise<ValidatorDetailSceneResult> {
        showIfsg22aNotCompleteExpectation.fulfill()
        return .value(.close)
    }
    
    func showIfsg22aCheckError(token: ExtendedCBORWebToken?) -> Promise<ValidatorDetailSceneResult> {
        showIfsg22aCheckErrorExpectation.fulfill()
        return .value(.close)
    }
    
    func showIfsg22aCheckTestIsNotAllowed(token: ExtendedCBORWebToken?) -> Promise<ValidatorDetailSceneResult> {
        showIfsg22aCheckTestIsNotAllowedExpectation.fulfill()
        return .value(.close)
    }
    
    func showIfsg22aIncompleteResult(token: ExtendedCBORWebToken) -> Promise<ValidatorDetailSceneResult> {
        showIfsg22aIncompleteResultExpectation.fulfill()
        return .value(.close)
    }
}
