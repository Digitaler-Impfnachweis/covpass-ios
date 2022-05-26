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
    let showNextGenericPageExpectation = XCTestExpectation(description: "showNextExpectation")
    let cancelExpectation = XCTestExpectation(description: "cancelExpectation")
    let routeToPrivacyExpectation = XCTestExpectation(description: "routeToPrivacyExpectation")
    let showErrorExpectation = XCTestExpectation(description: "showErrorExpectation")
    var receivedErrorFaqURL: URL?
    var receivedErrorTitle: String?
    var receivedErrorMessage: String?

    func showReissueResultPage(newTokens: [ExtendedCBORWebToken], oldTokens: [ExtendedCBORWebToken], resolver: Resolver<Void>) {
        showNextExpectation.fulfill()
    }
    
    func showGenericResultPage(resolver: Resolver<Void>) {
        showNextGenericPageExpectation.fulfill()
    }
    
    func cancel(resolver:Resolver<Void>)  {
        cancelExpectation.fulfill()
        resolver.fulfill_()
    }
    
    func routeToPrivacyStatement() {
        routeToPrivacyExpectation.fulfill()
    }

    func showError(title: String, message: String, faqURL: URL) {
        receivedErrorTitle = title
        receivedErrorMessage = message
        receivedErrorFaqURL = faqURL
        showErrorExpectation.fulfill()
    }

    func showURL(_ url: URL) {}
}
