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
    
    func showMaskRequiredBusinessRules(token: ExtendedCBORWebToken) -> Promise<Void> {
        showMaskRequiredBusinessRulesExpectation.fulfill()
        return .value
    }
    
    func showMaskRequiredBusinessRulesSecondScanAllowed(token: ExtendedCBORWebToken) -> Promise<Void> {
        showMaskRequiredBusinessRulesSecondScanAllowedExpectation.fulfill()
        return .value
    }
    
    func showMaskRequiredTechnicalError(token: ExtendedCBORWebToken?) -> Promise<Void> {
        showMaskRequiredTechnicalErrorExpectation.fulfill()
        return .value
    }
    
    func showMaskOptional(token: ExtendedCBORWebToken) -> Promise<Void> {
        showMaskOptionalExpectation.fulfill()
        return .value
    }
    
    func showNoMaskRules(token: ExtendedCBORWebToken) -> Promise<Void> {
        showNoMaskRulesExpectation.fulfill()
        return .value
    }
}
