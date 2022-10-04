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
    
    func showDifferentPerson(token1OfPerson: CovPassCommon.ExtendedCBORWebToken, token2OfPerson: CovPassCommon.ExtendedCBORWebToken) -> Promise<DifferentPersonResult> {
        showDifferentPersonExpectation.fulfill()
        return .value(showDifferentPersonResult)
    }
    
    func showSameCertType() {
        showSameCertTypeExpectation.fulfill()
    }
}
