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
    
    func showCertificate(_ certificate: ExtendedCBORWebToken?, userDefaults: Persistence) {

    }
    
    func showError(_ certificate: ExtendedCBORWebToken?,
                   error: Error,
                   userDefaults: Persistence) -> Promise<ExtendedCBORWebToken> {
        .value(ExtendedCBORWebToken(
            vaccinationCertificate: .mockTestCertificate,
            vaccinationQRCodeData: "")
        )
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
}
