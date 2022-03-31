//
//  ReissueResultRouterMock.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassApp
import CovPassUI
import PromiseKit
import XCTest

class ReissueResultRouterMock: ReissueResultRouterProtocol {
    let showErrorExpectation = XCTestExpectation(description: "showErrorExpectation")
    var sceneCoordinator: SceneCoordinator = SceneCoordinatorMock()
    var receivedError: Error?

    func showError(_ error: Error, resolver _: Resolver<Void>) {
        receivedError = error
        showErrorExpectation.fulfill()
    }
}
