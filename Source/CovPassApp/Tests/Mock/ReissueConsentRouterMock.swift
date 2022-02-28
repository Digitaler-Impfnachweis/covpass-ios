//
//  ReissueConsentRouterMock.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
@testable import CovPassApp
import CovPassUI
import CovPassCommon
import XCTest
import PromiseKit

class ReissueConsentRouterMock: ReissueConsentRouterProtocol {
    var sceneCoordinator: SceneCoordinator = SceneCoordinatorMock()
    let showNextExpectation = XCTestExpectation(description: "showNextExpectation")
    let cancelExpectation = XCTestExpectation(description: "cancelExpectation")
    let routeToPrivacyExpectation = XCTestExpectation(description: "routeToPrivacyExpectation")

    func showNext(newTokens: [ExtendedCBORWebToken], oldTokens: [ExtendedCBORWebToken]) {
        showNextExpectation.fulfill()
    }
    
    func cancel() -> Promise<Bool> {
        cancelExpectation.fulfill()
        return .value(true)
    }
    
    func routeToPrivacyStatement() {
        routeToPrivacyExpectation.fulfill()
    }
}
