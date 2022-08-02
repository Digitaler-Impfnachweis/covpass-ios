//
//  CheckSituationRouterMock.swift
//
//
//  © Copyright IBM Deutschland GmbH 2021
//  SPDX-License-Identifier: Apache-2.0
//

import Foundation
import XCTest
import CovPassUI

class CheckSituationRouterMock: CheckSituationRouterProtocol {
    
    var sceneCoordinator: SceneCoordinator = SceneCoordinatorMock()
    var noInternetExpecation = XCTestExpectation()
    
    func showNoInternetErrorDialog(_ error: Error) {
        noInternetExpecation.fulfill()
    }
}
