//
//  ReissueStartViewRouterMock.swift
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

class ReissueStartRouterMock: ReissueStartRouterProtocol {
    
    var sceneCoordinator: SceneCoordinator = SceneCoordinatorMock()
    let showNextExpectation = XCTestExpectation(description: "showNextExpectation")
    let cancelExpectation = XCTestExpectation(description: "cancelExpectation")

    func showNext(tokens: [ExtendedCBORWebToken], resolver: Resolver<Void>, context: ReissueContext) {
        showNextExpectation.fulfill()
    }
    
    func cancel() {
        cancelExpectation.fulfill()
    }
}
