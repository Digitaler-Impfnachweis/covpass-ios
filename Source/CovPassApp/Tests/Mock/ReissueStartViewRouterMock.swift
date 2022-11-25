//
//  ReissueStartViewRouterMock.swift
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

@testable import CovPassApp
import CovPassCommon
import CovPassUI
import Foundation
import PromiseKit
import XCTest

class ReissueStartRouterMock: ReissueStartRouterProtocol {
    var sceneCoordinator: SceneCoordinator = SceneCoordinatorMock()
    let showNextExpectation = XCTestExpectation(description: "showNextExpectation")
    let cancelExpectation = XCTestExpectation(description: "cancelExpectation")

    func showNext(tokens _: [ExtendedCBORWebToken], resolver _: Resolver<Void>, context _: ReissueContext) {
        showNextExpectation.fulfill()
    }

    func cancel() {
        cancelExpectation.fulfill()
    }
}
